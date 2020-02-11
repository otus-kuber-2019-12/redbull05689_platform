# redbull05689_platform
redbull05689 Platform repository


                                Lab 2 Kubernetes controllers
В процессе сделано:
Вопрос про округление у Max Unavailable и Max Surge:
Max Unavailable округляется в меньшую сторону. "The absolute number is calculated from percentage by rounding down."
Max Surge округляется в большую сторону. "The absolute number is calculated from the percentage by rounding up."
Вопрос почему ReplicaSet не обновляется.
ReplicaSet не обновляется потому, что он следит только за количеством реплик в наборе и поддерживает их в актуальном состоянии.
При попытке обновить ReplicaSet ничего не произойдет. Если мы попробуем от(scale)ить количество реплик в большую сторону, то новые экземпляры появятся обновленные. Однако если мы от(scale)им обратно вниз, то ReplicaSet удалит последние добавленные экземпляры и останутся реплики со старой версией.
В процессе выполнения HW созданы Replicaset и Deployment с readiness probe для микросервиса frontend.
Написаны манифесты ReplicaSet и Deployment в 3 стратегиях развертывания (default rolling update, blue/green, reverse update) для микросервиса paymentservice.
Написан манифест для развертывания DaemonSet с node_exporter на всех узлах кластера, включая master.
Как запустить проект:
kubectl apply -f kubernetes-controllers/frontend-deployment.yaml

kubectl apply -f kubernetes-controllers/paymentservice-deployment.yaml

kubectl apply -f kubernetes-controllers/node-exporter-daemonset.yaml

Как проверить работоспособность:
kubectl port-forward frontend-* 80:8080

                                Lad 3 Kubernetes security

В процессе сделано:
В папке task01 созданы 2 манифеста для создания serviceAccounts  c различными правами
В папке task02 созданы N манифестов для создания  nameSpace prometheus и serviceAccounts  c  правами get, list, watch в отношении Pods всего кластера. А также Service Account carol в этом же nameSpace.
В папке task03 создан манифест для serviceAccount ken и jane в новом namespace dev

-------
Полезные команды для создания шаблонов:
#Create serviceaccount
kubectl create serviceaccount michelle --dry-run -o yaml > michelle.yamlkube
#Create a role
kubectl create clusterrole crmichelle --verb=get,list,watch,create,delete --resource=nodes  --dry-run -o yaml > clusterRole.yaml

#Create rolebinding
kubectl create clusterrolebinding rbmichele --clusterrole=crmichelle --user=michelle  --dry-run -o yaml > roleBinding.yaml


--------

Как запустить проект:
cd /kubernetes-security/task01
kubectl apply -f bob.yaml # Создать Service Account bob, дать ему роль admin в рамках всего
кластера

kubectl apply -f #Создать Service Account dave без доступа к кластеру

Как проверить работоспособность:
kubectl auth can-i create pods --as bob
kubectl auth can-i create pods --as dave
kubectl auth can-i create pods --as jane -n dev
kubectl auth can-i get pods --as ken -n dev
                                    Lab4 networks
В процессе сделано:
В папке kubernetes-networks созданны манифесты:
    web-deploy.yaml с добавленными liavenessProbe и readynessProbe
    Созданы сервисы ClusterIP и LoadBalancer(MetalLB)
    В процессе был включен IPVS
    Создан Ingress прокси
            Lab 5
В процессе сделано:
    Создано локально хранилище Minio
Запустить:
   cd kubernetes-volumes && kubectl apply -f *


   

            Lab 6
В процессе сделано:
    Создан кластер в GCP
    Создан ingress , chartmuseum , harbor , hipster shop helm , hipster-shop kubecfg
Запустить:
    gcloud container clusters create otus 

    gcloud container clusters get-credentials otus

    helm upgrade --install nginx-ingress stable/nginx-ingress --wait --namespace=nginx-ingress --version=1.11.1
    kubectl create secret generic chartmuseum-secret --from-file=credentials.json -n chartmuseum
    kubectl create ns chartmuseum
    helm upgrade --install chartmuseum stable/chartmuseum --wait --namespace=chartmuseum --version=2.3.2 -f kubernetes-templating/chartmuseum/values.yaml
   
    kubectl apply -f kubernetes-templating/cert-manager/issuer-staging.yaml 
    kubectl apply -f kubernetes-templating/cert-manager/issuer-prod.yaml 

   helm upgrade --install harbor harbor/harbor --wait --namespace=harbor --version=1.1.2 -f kubernetes-templating/harbor/values.yaml 

    helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop

    kubecfg show kubernetes-templating/kubecfg/services.jsonnet 
              lab7 Operators
   В процессе седлано:
    Оператор Mysql
   Запустить:
     kubectl apply -f deploy/role.yml 
     kubectl apply -f deploy/ClusterRoleBinding.yml 
     kubectl apply -f deploy/deploy-operator.yml 
     kubectl apply -f deploy/cr.yml
     kubectl apply -f deploy/crd.yml
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
   echo $MYSQLPOD
    kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
    export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}")
    kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE test ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );" otus-database
    kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( null, 'some data' );" otus-database
    kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO test ( id, name ) VALUES ( null, 'some data-2' );" otus-database
    kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
    Проверить:
    macpro:kubernetes-operators maksim.vasilev$ kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from test;" otus-database
mysql: [Warning] Using a password on the command line interface can be insecure.
+----+-------------+
| id | name        |
+----+-------------+
|  1 | some data   |
|  2 | some data-2 |
+----+-------------+
