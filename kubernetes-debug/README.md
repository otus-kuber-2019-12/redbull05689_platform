##Создал тренировочный кластер 
gcloud container clusters create otus --machine-type=n1-standard-2 --num-nodes=2

##Для запуска strace внутри пода изменил версию образа на latest.
kubectl apply -f kubernetes-debug/strace/agent_daemonset.yml 
#Развернул под с вебсервером на борту
kubectl run --generator=run-pod/v1 websrv --image=nginx

#Запустил kubectl debug и получил достур к шелу
kubectl debug websrv --port-forward
#Запустил strace
bash-5.0# strace -p 1
strace: Process 1 attached
rt_sigsuspend([], 8^Cstrace: Process 1 detached
 <detached ...>

bash-5.0# exit
end port-forward...

# Развернул кластер с Calico
gcloud container clusters create otus --enable-network-policy

#Установим netperf оператор
git clone https://github.com/piontec/netperf-operator.git 

kubectl apply -f ./deploy/crd.yaml
kubectl apply -f ./deploy/rbac.yaml
kubectl apply -f ./deploy/operator.yaml

# Запустил пример
kubectl apply -f ./deploy/cr.yaml
  # Результат до мприменения политики
macpro:kit maksim.vasilev$  kubectl describe netperf.app.example.com/example
Name:         example
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"app.example.com/v1alpha1","kind":"Netperf","metadata":{"annotations":{},"name":"example","namespace":"default"
}}
API Version:  app.example.com/v1alpha1
Kind:         Netperf
Metadata:
  Creation Timestamp:  2020-04-02T11:01:55Z
  Generation:          4
  Resource Version:    10840
  Self Link:           /apis/app.example.com/v1alpha1/namespaces/default/netperfs/example
  UID:                 5d54d5b9-74d1-11ea-81a7-42010a84019a
Spec:
  Client Node:  
  Server Node:  
Status:
  Client Pod:          netperf-client-42010a84019a
  Server Pod:          netperf-server-42010a84019a
  Speed Bits Per Sec:  16164.76
  Status:              Done
Events:                <none>

# Результат после мприменения политики

maksim.vasilev$ kubectl describe netperf.app.example.com/example
Name:         example
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"app.example.com/v1alpha1","kind":"Netperf","metadata":{"annotations":{},"name":"example","namespace":"default"
}}
API Version:  app.example.com/v1alpha1
Kind:         Netperf
Metadata:
  Creation Timestamp:  2020-04-02T14:51:38Z
  Generation:          3
  Resource Version:    9941
  Self Link:           /apis/app.example.com/v1alpha1/namespaces/default/netperfs/example
  UID:                 74d3a792-74f1-11ea-b0ef-42010a840209
Spec:
  Client Node:  
  Server Node:  
Status:
  Client Pod:          netperf-client-42010a840209
  Server Pod:          netperf-server-42010a840209
  Speed Bits Per Sec:  0
  Status:              Started test
Events:                <none>

!!! Если после применения политики результаты теста в статусе Done, то нужно перезапустить тест netperf kubectl delete -f kit/netperf-operator/deploy/cr.yaml && kubectl apply -f kit/netperf-operator/deploy/cr.yaml 

# Скачал iptailer
git clone https://github.com/box/kube-iptables-tailer.git
Собрал и запушил образ

# Запустим iptailer 

kubectl apply -f kit/kit-serviceaccount.yaml
kubectl apply -f kit/kit-clusterrole.yaml
kubectl apply -f kit/kit-clusterrolebinding.yaml
kubectl apply -f kit/iptables-tailer.yaml 

# Вывод kubectl describe pod --selector=app=netperf-operator

...
Events:
  Type     Reason      Age   From                                          Message
  ----     ------      ----  ----                                          -------
  Normal   Scheduled   17s   default-scheduler                             Successfully assigned default/netperf-server-42010a840209 to gke-otus-default-pool-c5c1a12a-5d4s
  Normal   Pulled      16s   kubelet, gke-otus-default-pool-c5c1a12a-5d4s  Container image "tailoredcloud/netperf:v2.7" already present on machine
  Normal   Created     16s   kubelet, gke-otus-default-pool-c5c1a12a-5d4s  Created container netperf-server-42010a840209
  Normal   Started     16s   kubelet, gke-otus-default-pool-c5c1a12a-5d4s  Started container netperf-server-42010a840209
  Warning  PacketDrop  13s   kube-iptables-tailer                          Packet dropped when receiving traffic from client (10.24.1.15)

# Удалим кластер
gcloud beta container clusters delete otus