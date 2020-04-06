# В процессе сделано:
Подготовлен файл cluster.yaml с необходимой конфигурацией для kind;
В директории hw созданы манифесты для создания объектов StorageClass, PVC и pod;
# Как запустить проект:
Из директории kubernetes-storage/cluster и создать кластер с помощью kind с кастомным конфигом: kind create cluster --config cluster.yaml --name otus
Задать переменную окружения, для использования конфига kind: export KUBECONFIG="$(kind get kubeconfig-path)"
Установить CSI Host Path Driver:
git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
./csi-driver-host-path/deploy/kubernetes-1.15/deploy-hostpath.sh
# Как проверить работоспособность:
Перейти в директорию kubernetes-storage/hw и последовательно выполнить:
kubectl apply -f sc.yaml
kubectl apply -f pvc.yaml
kubectl apply -f pod.yaml

# Удалить кластер
kind delete cluster --name otus