
gcloud container clusters create otus --machine-type=n1-standard-2 --num-nodes=1
gcloud container node-pools create infra \
      --cluster otus \
      --machine-type n1-standard-2 \
      --num-nodes 3 \
      --no-enable-autoupgrade

kubectl taint nodes gke-otus-infra-d7fecccb-5x79 node-role=infra:NoSchedule
kubectl taint nodes gke-otus-infra-d7fecccb-9vv5 node-role=infra:NoSchedule
kubectl taint nodes gke-otus-infra-d7fecccb-xjg0 node-role=infra:NoSchedule

macpro:redbull05689_platform maksim.vasilev$ kubectl get nodes
NAME                                  STATUS   ROLES    AGE   VERSION
gke-otus-default-pool-a78dc33f-c1vm   Ready    <none>   78m   v1.14.10-gke.17
gke-otus-infra-d7fecccb-5x79     Ready    <none>   74m   v1.14.10-gke.17
gke-otus-infra-d7fecccb-9vv5     Ready    <none>   74m   v1.14.10-gke.17
gke-otus-infra-d7fecccb-xjg0     Ready    <none>   74m   v1.14.10-gke.17

kubectl create ns microservices-demo
kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml -n microservices-demo


macpro:redbull05689_platform maksim.vasilev$ kubectl get pods -n microservices-demo -o wide
NAME                                     READY   STATUS             RESTARTS   AGE     IP           NODE                                  NOMINATED NODE   RE
ADINESS GATES
adservice-6898984d4c-ccmkz               1/1     Running            0          2m39s   10.24.0.24   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
cartservice-86854d9586-x9r4g             1/1     Running            2          2m41s   10.24.0.19   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
checkoutservice-85597d98b5-5t7z5         1/1     Running            0          2m44s   10.24.0.14   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
currencyservice-c97fb88c9-fxjqw          1/1     Running            0          2m40s   10.24.0.21   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
emailservice-c6958d989-xxfnl             1/1     Running            0          2m45s   10.24.0.13   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
frontend-756f85785-8h7qz                 1/1     Running            0          2m43s   10.24.0.16   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
loadgenerator-755dcf9f5d-kjnnv           0/1     CrashLoopBackOff   3          2m41s   10.24.0.20   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
paymentservice-66fbfd9d8f-gbcxf          1/1     Running            0          2m42s   10.24.0.17   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
productcatalogservice-78694d9b67-7v8p6   1/1     Running            0          2m42s   10.24.0.18   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
recommendationservice-948bbf47c-ph428    1/1     Running            0          2m44s   10.24.0.15   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
redis-cart-6cf575c898-8mggm              1/1     Running            0          2m39s   10.24.0.22   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>
shippingservice-7fc8b8d49f-zmxv6         1/1     Running            0          2m40s   10.24.0.23   gke-otus-default-pool-a78dc33f-c1vm   <none>           <n
one>

#Добавим репозиторий
helm repo add elastic https://helm.elastic.co

# EFK
kubectl create ns observability
# ElasticSearch
helm upgrade --install elasticsearch elastic/elasticsearch --namespace observability -f kubernetes-logging/elasticsearch.values.yaml

# Ingress
helm upgrade --install nginx-ingress stable/nginx-ingress --namespace observability -f kubernetes-logging/nginx-ingress.values.yaml

# Kibana
helm upgrade --install kibana elastic/kibana --namespace observability -f kubernetes-logging/kibana.values.yaml

# Fluent Bit
helm upgrade --install fluent-bit stable/fluent-bit --namespace observability -f kubernetes-logging/fluent-bit.values.yaml



# Prometheus
helm upgrade --install prometheus-operator stable/prometheus-operator --namespace=observability -f kubernetes-logging/prometheus-operator.values.yaml

# Prometheus node-exporter
helm upgrade --install elasticsearch-exporter stable/elasticsearch-exporter --set es.uri=http://elasticsearch-master:9200 --set serviceMonitor.enabled=true --namespace=observability

Результат:
1) Создан кластер в GCP
2) Поднят EFK + Grafana + Loki
3) Поднят Ingress
4) Поднят Prometheus
5) Экспортррованны дашборды Grafana и Loki
