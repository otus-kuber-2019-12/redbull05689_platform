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


        lab 10(vault)
macpro:kubernetes-vault maksim.vasilev$ helm status vault
NAME: vault
LAST DEPLOYED: Sat Feb  8 16:57:16 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/

macpro:kubernetes-vault maksim.vasilev$ helm status vault
NAME: vault
LAST DEPLOYED: Sat Feb  8 16:57:16 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
macpro:kubernetes-vault maksim.vasilev$ kubectl exec -ti vault-0 -- vault operator init --key-shares=1 --key-thr
eshold=1
Unseal Key 1: FmAwbPiZCyrbhFjUGekSi6FGzbURYIBcFHb0iVabf7Q=

Initial Root Token: s.n3vUe6sxR8MCWjEXPlci8o0r

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get vault


  kubectl exec -it vault-0 -- vault operator unseal \
'FmAwbPiZCyrbhFjUGekSi6FGzbURYIBcFHb0iVabf7Q='
kubectl exec -it vault-1 -- vault operator unseal \
'FmAwbPiZCyrbhFjUGekSi6FGzbURYIBcFHb0iVabf7Q='
kubectl exec -it vault-2 -- vault operator unseal \
'FmAwbPiZCyrbhFjUGekSi6FGzbURYIBcFHb0iVabf7Q='

kubectl exec -it vault-0 -- vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.3.1
Cluster Name    vault-cluster-f5f7b95a
Cluster ID      ee08c1cc-1eb3-710e-12b0-e37a10e7de0d
HA Enabled      true
HA Cluster      https://10.24.2.5:8201
HA Mode         active

macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.n3vUe6sxR8MCWjEXPlci8o0r
token_accessor       xPTew9HVvt3LZW0i6t44zpor
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault auth list
Path      Type     Accessor               Description
----      ----     --------               -----------
token/    token    auth_token_3b72a28e    token based credentials

kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
username    otus

macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault auth list
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_efb0617e    n/a
token/         token         auth_token_3b72a28e         token based credentials


macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus

macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault auth list
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_c42829c1    n/a
token/         token         auth_token_06720544         token based credentials



# curl --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
{ 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  "request_id": "f44f9da1-9aa2-31d9-2c1c-fc48a4b2b237",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth": {
    "client_token": "s.wtnjHAZQLP48VLV1vcAtYrFq",
    "accessor": "XIYdOYmDhHw02rBN3KhXX0B1",
    "policies": [
      "default",
      "otus-policy"
    ],
    "token_policies": [
      "default",
      "otus-policy"
    ],
    "metadata": {
      "role": "otus",
      "service_account_name": "vault-auth",
      "service_account_namespace": "default",
      "service_account_secret_name": "vault-auth-token-r2x4l",
      "service_account_uid": "3ffafc53-4b63-11ea-96e4-42010a840150"
    },
    "lease_duration": 86400,
    "renewable": true,
    "entity_id": "6fbfea93-9f25-fc5c-f555-bea1bcc80801",
    "token_type": "service",
    "orphan": true
  }
}
100  1547  100   666  100   881   2205   2917 --:--:-- --:--:-- --:--:--  5122
/ # curl --header "X-Vault-Token:s.w5YtO4kAWma7tV7sOfyaLgQ3" $VAULT_ADDR/v1/otus/otus-ro/config
{"request_id":"d3f2ba21-a651-0f82-e9cd-238c28a82b6a","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}
/ # curl --header "X-Vault-Token:s.w5YtO4kAWma7tV7sOfyaLgQ3" $VAULT_ADDR/v1/otus/otus-rw/config
{"request_id":"76b031e4-8a2a-9c58-fe52-6194bd13c5fc","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"asajkjkahs","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}
/ # 

/ # url --request POST --data '{"bar": "baz"}' --header "X-Vaul-tToken:s.w5YtO4kAWma7tV7sOfyaLgQ3" $VAULT_ADDR/v1/otus/otus-ro/config
/bin/sh: url: not found
/ # curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.w5YtO4kAWma7tV7sOfyaLgQ3" $VAULT_ADDR/v1/otus/otus-rw/config
/ # curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:s.w5YtO4kAWma7tV7sOfyaLgQ3" $VAULT_ADDR/v1/otus/otus-rw/config1
/ # 
Почему мы смогли записать otus-rw/config1 но не смогли otusrw/config - не удалось получить ошибку!

Выдача сертификата:

Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIURPz2VD/gznUCeQQ63NBdL6/VxWgwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0xOTExMTAxNzA0MDhaFw0yNDEx
MDgxNzA0MzhaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM6m2wfvUAdS
6tKL0HP8hC2a/K26yjYe6pNneIXoI+6BjXnSVAFuH1x5v8NBn9sgG183t2+JZWRs
4F05O9JtRTXxj6WA9gscsRMk3b3nNSo+ba27BhrHBTOf3Osmza4YA4K6lKQ1fGob
SEza0yEMLGJ/mrr8ZS0hmDSIgsJbZhqfr1vcH03J7Mf+d9JZoxU5fBy5zynyOo5X
ersaGvmhObtdWJG2hCDHYHkPEm5Vc3iNuF2Y2f3vrSkjpW2zADkdIoTm/Lse/CSt
qYpMX7YgVJW3ZHTE5v8bHEnP5TF0H1jKpr7QaBmX06rPWZXnFtK9Q+Yvl3KiPNPn
Hal/bYjwvgECAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUCw9PjI3SxXt3qmfK3+SeXVzT+Z4wHwYDVR0jBBgwFoAU
T7KV0Bm/aN7mJ6MY4ZrRB4KqbykwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
mmOh4THQiPmGO6nJmPsYBJVHL7O3GGru8RhrMK2yKmNaCjLtxcNEpumNCHu966TQ
e8h9FtGVpkbK++kYx5sb0LDE4VyI4WvJhxPwUJXaLRBAxmUAdSTvo8rmzHcV5Sq3
nXWcWB6yiIQUyKZkwoiHG70SVQyeWeEzOAxM3+p68indkJS0UhxeL7JRCk1Due3x
rT+U0A0eXqs4E2XeHTbANFy5zjOuuxVd7+Wnd3iQ14N8eaCd75f3hjLOa0lgFWSa
eqjNpoLr9lccLsmmDbQwheioDMz01Z4yr694s4BFpYZcngel0oSXbxth2OxgaWAV
yPGY0ZKqOrFQuUs8LTqyPA==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUbBUMJp1MUsqvJ4IIDqGHmmXM7f8wDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTE5MTExMDE3MDgxMVoXDTE5MTExMTE3MDg0MVowHDEaMBgGA1UEAxMRZ2l0
bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDj
RdnQLaAU+d4QezrCpt5v+84epgKqAOeteHDW9mfWI2PeURuRJkMFHEc1NPV4AcIk
qsdCHALXKbW9/ZNPO2TB2DwbLaL7ejSnJVrex2QFrzZoMDff27Twk2nOhpnmt6l4
xllI4l5IZ/PuFD6EtEiG7PkBXdsdf/6MsRvFIHv8sY+U0FvYR5xIA4ViFLNXv+Bf
UnW6VArbEZOKNm4QxqsypBL3zoydgDpoKwrnxbhC+D2EYC2Ffk26iIeSVqNHo45D
Bjfpmxw/bMpFBzAZ2IuptfrarzGhX/D0f/J/3RMle1aDNz6ysq4p3HHRdZLPVryK
0EofwwFxZQhDMyw6LE/ZAgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQU979knxz5FwSMY5lM
WJwlOcO/QsYwHwYDVR0jBBgwFoAUCw9PjI3SxXt3qmfK3+SeXVzT+Z4wHAYDVR0R
BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBACHF4cqY
Enqwp8bJSpO885SuQVpXg/PjBJ6JLd4241mr87AxhuJION369ulYBRQC/SW35SVs
rbPtNSgEG1AZUsob/jd6Iwpjw8MKejwdK+nbWb+gvOKoFBQIolfdC0DzFIaBAGQZ
7d13cpbbPNuAgBNngzZ3wI12ENq1KgstNp2xRpuzNpNkqYE4Jdby8ldPzRUEZW7/
z8PfXcilNQ6tUS0yjAhQs01m1i6Qmt22tsoGWBwoX/kELmu17vyVeEaTQn3RDbpL
o1il9uVhOjjjvBv59uWFy2v+aEh9qZFeU5W7ubV9vR4Bdc9iekLQdUy6i9xXzlwW
BtwNMyym1oKdRuA=
-----END CERTIFICATE-----
expiration          1573492121
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIURPz2VD/gznUCeQQ63NBdL6/VxWgwDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0xOTExMTAxNzA0MDhaFw0yNDEx
MDgxNzA0MzhaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM6m2wfvUAdS
6tKL0HP8hC2a/K26yjYe6pNneIXoI+6BjXnSVAFuH1x5v8NBn9sgG183t2+JZWRs
4F05O9JtRTXxj6WA9gscsRMk3b3nNSo+ba27BhrHBTOf3Osmza4YA4K6lKQ1fGob
SEza0yEMLGJ/mrr8ZS0hmDSIgsJbZhqfr1vcH03J7Mf+d9JZoxU5fBy5zynyOo5X
ersaGvmhObtdWJG2hCDHYHkPEm5Vc3iNuF2Y2f3vrSkjpW2zADkdIoTm/Lse/CSt
qYpMX7YgVJW3ZHTE5v8bHEnP5TF0H1jKpr7QaBmX06rPWZXnFtK9Q+Yvl3KiPNPn
Hal/bYjwvgECAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUCw9PjI3SxXt3qmfK3+SeXVzT+Z4wHwYDVR0jBBgwFoAU
T7KV0Bm/aN7mJ6MY4ZrRB4KqbykwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
mmOh4THQiPmGO6nJmPsYBJVHL7O3GGru8RhrMK2yKmNaCjLtxcNEpumNCHu966TQ
e8h9FtGVpkbK++kYx5sb0LDE4VyI4WvJhxPwUJXaLRBAxmUAdSTvo8rmzHcV5Sq3
nXWcWB6yiIQUyKZkwoiHG70SVQyeWeEzOAxM3+p68indkJS0UhxeL7JRCk1Due3x
rT+U0A0eXqs4E2XeHTbANFy5zjOuuxVd7+Wnd3iQ14N8eaCd75f3hjLOa0lgFWSa
eqjNpoLr9lccLsmmDbQwheioDMz01Z4yr694s4BFpYZcngel0oSXbxth2OxgaWAV
yPGY0ZKqOrFQuUs8LTqyPA==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA40XZ0C2gFPneEHs6wqbeb/vOHqYCqgDnrXhw1vZn1iNj3lEb
kSZDBRxHNTT1eAHCJKrHQhwC1ym1vf2TTztkwdg8Gy2i+3o0pyVa3sdkBa82aDA3
39u08JNpzoaZ5repeMZZSOJeSGfz7hQ+hLRIhuz5AV3bHX/+jLEbxSB7/LGPlNBb
2EecSAOFYhSzV7/gX1J1ulQK2xGTijZuEMarMqQS986MnYA6aCsK58W4Qvg9hGAt
hX5NuoiHklajR6OOQwY36ZscP2zKRQcwGdiLqbX62q8xoV/w9H/yf90TJXtWgzc+
srKuKdxx0XWSz1a8itBKH8MBcWUIQzMsOixP2QIDAQABAoIBACClegJDa4lX0yQ+
71PisHUZkKQqaJuPAbiTYnIedw/1iXT35aPWAS6Mv1XPQ6t3ZTHrLjA64dWScj7W
XAC3oWOO8iNdTNoe1c1kukbiEWYXoxMYSg5n+vfL1RkLkLPpkfh9VXn4ul5gQFPk
qI5bb0eiZqphlwYHysLe9gQ9BFJp0c/6yNjQzvz9oLTI0GfGox8mNrg5ftvaJLK8
ZlDloVr3ymRTp75+S9YGVS23aJMRYXVk00Z6hTcM6lVRuNxl+qxyezl77Kw/1hBp
dzxOOx0fXGUM/i7udT1AK7NxfnigDVi9JsVNVdvQc6xDLXLYDPQX+QLvC5SOONrH
HrfdruECgYEA8SxNNd0vAnCDZ6Ds2NORDyyBQupGyPPyHcuFdwuEXP4g++0M+OC9
7kYubPgfAQtKtPgVljAjVjN44Oh6kuiKAyOtJCNVEpItyoeXV8qHMb/ElQo1M4Ik
NHJPfOQKwgjclsy83bcfvE9rbiH0Ly0zyb3ysFqOhujd+zYBtmzKMZ0CgYEA8T7H
+tzdwmuGfN3GvYMRGPDdHOH+YVs2SZzxARntdGxINMne/6MkPVSrw9e0d7wck9bn
GVZk7ZYfcKaYSvFuvSWgHZ6YGogx1CtPxCNxIQrjfN0AkS/N0L+bvT845KkkYPLx
ZB/0wWrilqynd890XxS9e3O7Sk2F3tmGssw68G0CgYEAnNff2sDeuqprevB4N8bX
ltOtuNPddwDXG7NpN/NggI2w68XNYund+2De/nUazLYIPsr8VvE1efD9kt7+IB5k
6we/qTnlMK+qYgVuUmTfKWZ6tSavVLE1VHpm4WT47hmPQ+8ggNyAIhpQVo50XF38
SR5j/3bVLD2zZ5VG5dm4YS0CgYEAgk8vJkp3XrVGB9yjpWpOqfIw/ZD1HxFt2YV0
iOvAX8q9lgYU9nDg+l/qB/dT+/kYVqMWYZFRIyScBvV1/cU709+nBVjNQEeg4sIi
bAfY68g96QxXahUwTzmwniCwUpMqm1OfID5CrtdVXZ4VN5pPeaxyTWTOHeySCzXk
lF/M1mECgYAWLF81xKRlE8PoyefUmcZjNaVEJw7to3La9A4jqaV5yZ88H36AyosV
6EiL1UwkES/AOOw0PWnEYu6xscuWW4xJ5VqI0SKwZ/YQL/27OviXGjhaDnIflqdx
nnYGoPRuZ5cPtJYF5VVRhELFEY9UvqRGMCJnC1eFTKTEf5or1zbDzA==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       6c:15:0c:26:9d:4c:52:ca:af:22:82:08:0e:a1:87:9a:65:cc:ed:ff

