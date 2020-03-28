# CREATE CLUSTER FOR APP
gcloud container clusters create otus --machine-type=n1-standard-2 --num-nodes=1
gcloud container node-pools create infra \
      --cluster otus \
      --machine-type n1-standard-2 \
      --num-nodes 3 \
      --no-enable-autoupgrade

kubectl taint nodes gke-otus-infra-d7fecccb-5x79 node-role=infra:NoSchedule

kubectl taint nodes gke-otus-infra-d7fecccb-9vv5 node-role=infra:NoSchedule 

kubectl taint nodes gke-otus-infra-d7fecccb-xjg0 node-role=infra:NoSchedule 


# CREATE DEMO APP
kubectl create ns microservices-demo

kubectl apply -f https://raw.githubusercontent.com/express42/otus-platform-snippets/master/Module-02/Logging/microservices-demo-without-resources.yaml -n microservices-demo


kubectl get pods -n microservices-demo -o wide


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

# Результат
1) Создан кластер в GCP
2) Поднят EFK + Grafana + Loki
3) Поднят Ingress
4) Поднят Prometheus
5) Экспортррованны дашборды Kibana и Grafana
