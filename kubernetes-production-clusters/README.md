# В процессе сделано:
Подняты 4 ноды в GCP

gcloud compute instances create  master --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type n1-standard-2 \
&& gcloud compute instances create  node1 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type n1-standard-2 \
&& gcloud compute instances create  node2 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type n1-standard-2 \
&& gcloud compute instances create  node3 --image-family ubuntu-minimal-1804-lts --image-project ubuntu-os-cloud --machine-type n1-standard-2

Отключим swap:

swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

 Включим маршрутизатию:

 cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

Установим docker:

apt-get update && apt-get install -y \
apt-transport-https ca-certificates curl software-properties-common gnupg2

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

apt-get update && apt-get install -y \
containerd.io=1.2.13-1 \
docker-ce=5:19.03.8~3-0~ubuntu-$(lsb_release -cs) \
docker-ce-cli=5:19.03.8~3-0~ubuntu-$(lsb_release -cs)

#Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
#Restart docker.
systemctl daemon-reload
systemctl restart docker

Утсановим kubeadm, kubelet, kubectl:

apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.17.4-00 kubeadm=1.17.4-00 kubectl=1.17.4-00

На мастере:
kubeadm init --pod-network-cidr=192.168.0.0/24

Копируем конфиг kubectl:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Установим сетевой плагин:
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

Присоединим оставшиеся(воркер) ноды к кластеру:
kubeadm join --token mwnmu7.rqgmu34mrf1e24qw 34.77.216.85:6443 --discovery-token-ca-cert-hash sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

Для этого на мастере нужно плучить хэш и токен лист:
Получить хэш:
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

 Получить токен лист:
 kubeadm token list

или

kubeadm join --token mwnmu7.rqgmu34mrf1e24qw 34.77.216.85:6443 --discovery-token-unsafe-skip-ca-verification

https://prnt.sc/rv9ap5

Для проверки работы кластера развернем тестовый deployment:
https://prnt.sc/rv9f1z

Обновим кластер:

На мастере:
apt-get update && apt-get install -y kubeadm=1.18.0-00 \
kubelet=1.18.0-00 kubectl=1.18.0-00

https://prnt.sc/rv9jh8

kubeadm upgrade plan
kubeadm upgrade apply v1.18.0

Обновим рабочие ноды:

kubectl drain node1 --ignore-daemonsets

На ноде выполним:
apt-get install -y kubelet=1.18.0-00 kubeadm=1.18.0-00 && systemctl restart kubelet

kubectl uncordon node1
https://prnt.sc/rv9qxv

Аналогично обновим оставшиеся ноды:
https://prnt.sc/rv9xhw

