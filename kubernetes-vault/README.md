

helm upgrade --install consul ./kubernetes-vault/consul-helm
helm upgrade --install vault ./kubernetes-vault/vault-helm -f kubernetes-vault/vault-helm/values.yaml

macpro:redbull05689_platform maksim.vasilev$ helm status vault
NAME: vault
LAST DEPLOYED: Sun Mar  8 15:01:20 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing HashiCorp Vault!


Инициализация vault
macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1
Unseal Key 1: s2lHxDKzT85Hv2u+1gArxfD2V1f4jljVymZekO9EbhU=

Initial Root Token: s.WhBek1L8K6xaH5omHi4ZmS0y

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

#Распечатаем поды
kubectl exec -it vault-0 -- vault operator unseal 's2lHxDKzT85Hv2u+1gArxfD2V1f4jljVymZekO9EbhU='
kubectl exec -it vault-1 -- vault operator unseal 's2lHxDKzT85Hv2u+1gArxfD2V1f4jljVymZekO9EbhU='
kubectl exec -it vault-2 -- vault operator unseal 's2lHxDKzT85Hv2u+1gArxfD2V1f4jljVymZekO9EbhU=‘

#Вывод после распечатки контейнеров
macpro:redbull05689_platform maksim.vasilev$ k exec -ti vault-0 -- vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.3.1
Cluster Name    vault-cluster-ad94ee80
Cluster ID      b6b166f2-4226-14bc-3d5f-d0c902a42531
HA Enabled      true
HA Cluster      https://10.24.0.11:8201
HA Mode         active


#Вывод после логина через root token
macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.WhBek1L8K6xaH5omHi4ZmS0y
token_accessor       o4U3bWesk0eLDbSFpnE1s6TY
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root”]


#Список авторизаций после логина через root token
macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault auth list
Path      Type     Accessor               Description
----      ----     --------               -----------
token/    token    auth_token_61837593    token based credentials

#  Выводы команд чтения секретов

kubectl exec -it vault-0 -- vault secrets list --detailed
Path          Plugin       Accessor              Default TTL    Max TTL    Force No Cache    Replication    Seal Wrap    External Entropy Access    Options    Description                                                UUID
----          ------       --------              -----------    -------    --------------    -----------    ---------    -----------------------    -------    -----------                                                ----
cubbyhole/    cubbyhole    cubbyhole_dccc341f    n/a            n/a        false             local          false        false                      map[]      per-token private secret storage                           8d26397a-937c-4583-006b-127492805767
identity/     identity     identity_2e5df040     system         system     false             replicated     false        false                      map[]      identity store                                             b0dab0e9-006c-290f-7f3c-6809aa79c06d
otus/         kv           kv_9ab1f521           system         system     false             replicated     false        false                      map[]      n/a                                                        5e8f4222-4aaf-efa1-b8d7-0f660fb2432b
sys/          system       system_ee893594       n/a            n/a        false             replicated     false        false                      map[]      system endpoints used for control, policy and debugging    d3705f87-21c1-c76c-5198-bd25d193305f

macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
username            otus
macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
username    otus


#Обновленный список после подключения авторизации через k8s
macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault auth list
Path           Type          Accessor                    Description
----           ----          --------                    -----------
kubernetes/    kubernetes    auth_kubernetes_f7f9b7e9    n/a
token/         token         auth_token_61837593         token based credentials


Вопрос:Почему мы смогли записать otus-rw/config1 но не смогли otusrw/config?
    Потому что политика позволяла создавать, но не позволяла перезаписывать.



#Обновил секрет и вывел index.html из тестового пода
macpro:redbull05689_platform maksim.vasilev$ kubectl exec -it vault-0 -- vault read otus/otus-rw/config
Key                 Value
---                 -----
refresh_interval    768h
password            P@$$W0RD
username            otus
macpro:redbull05689_platform maksim.vasilev$ 
macpro:redbull05689_platform maksim.vasilev$ k exec -ti vault-agent-example -- cat /etc/secrets/index.html
Defaulting container name to consul-template.
Use 'kubectl describe pod/vault-agent-example -n default' to see all of the containers in this pod.
  <html>
  <body>
  <p>Some secrets:</p>
  <ul>
  <li><pre>username: otus</pre></li>
  <li><pre>password: P@$$W0RD</pre></li>
  </ul>
  
  </body>
  </html>


Создание и отзыв сертификата:
macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUJNtQBkMSqAme1LNcxD3cXi/rnzowDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAzMDgxNDUzNDJaFw0yNTAz
MDcxNDU0MTJaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMHXztIF21d0
iJBAppBfaVZaS9B0qJk5lTBEiX8VF8ybD+pQnZOtCBnYvFxpdx0NEKqkxyL+Fz4L
+G+b8ouyxCgtXMGLCpQbid6+TDj6xuNbPtM1vcu0sZnqHEcesBt1sHmCCQzBthdC
ng9dlxKRiIEjJi5vsjvuEfpV7ZFGMIFgVYjo12QU7vEcFy4fWpX/LdVfhym0JqSf
YrYBTMWVjiD+wGsSXQiZqi398aCb2a/O4jqeU/fuI1lnBAWcbmCAKVaB3iYRSubG
lB6kWhDR7tYuIszawGjEoDWXq2qG0k9axNqUC9XVnPRIyy/g+YoGpMfYUJVFwItM
ZfldVGvuDU0CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUaHQyL5PjzfT5tFtzEvg1BnLDUVUwHwYDVR0jBBgwFoAU
zUHjkFVZ4hmNsAGwonzJv4bQvAQwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
Ybpq4qxJiN6J0Y8YoNKvjpoeVHW3rdsoTxFz67B7zw+Ebx6NGDxLV1I8X/yxgtd5
DGr7UHD8qWqdkA5L4Z36ZZHcWMRNbXzMHewDlojuweC0ESrP0CJS5jLXu9D5yg/u
BE8LGO6BU+2nlbxCbVhIiMQrAQelZF33G/7P6QuZ/C3gR1tPQBv3eaRUk9YyOymS
77S8VndDYWzQ8xur1HM4taheFRp+grmlV+H1I0l8MW/OHFfNYrYe4Gg7LdThv5MF
Ul8yWjI+9WutSlyc3EYcKO0T0KohcOxqX+e7Ej6bbqhHjhl2nNYXoPN9gF0QMute
IfSbThcbxxa2r3mno2nANQ==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUVw/yHQ7rxGWECQ6cyt2hSjOCnT0wDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIwMDMwODE0NTcxNVoXDTIwMDMwOTE0NTc0NVowHDEaMBgGA1UEAxMRZ2l0
bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDP
nCUEtCWSoeNoN+aRIVX3DGRKub1B681J5PAc5BLOWm1wSGOJUtGbbUPMNp0iQaqL
n8tHj9xL25fLKJELL0qaxiiOC7XpFjAnn47ztFeeS8HpbnKfWtMf2vruPrjnbrem
TeyaZtKGDE6pU3SvzTkle2HyYx3cSKSnvbYBsmg2Qcx+vjR7OAyKOyv1AVLkHHp1
9tPLbXKZTXG7WyFilbgnYzPWKq1rfTqHq4OoJp21HLw5mVKARUW1G3nPs+8bmvIr
GXx9lvm1I+cYU4PX2xYz2yuYCCcsRJVHgvZ/2i5ZuVsCI3rC77SJgZTZEhvQGuke
0O2sEx8Xhi2N38SASiDVAgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUoOqgZWoVQzBZW5tt
e3Ln2/JUf4UwHwYDVR0jBBgwFoAUaHQyL5PjzfT5tFtzEvg1BnLDUVUwHAYDVR0R
BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBAGDdl0fQ
/iKHfhb0cSo/q2Br+xVqwAZnde2w4jCDPgbX+25gsl5lTARqAYtaPmLc5VbAVMMp
1DsX3XKRVCivu+zrE6n9FA7oU50OkDeHlNkm4z7b3b1sTuxPQhUAbIhy6bOTE7Cu
F4gIVaCgIbcH5G0abugn54USPOxF8Ch4HpDZMZ8hWs2kULDKoCBaSDQyr2aF72bF
EwD2P/YQUZDsHcK9CSjB6VSg3T3d5chmf6RvCAcXTwWDtqZMLkvF0CNvo08gfIGq
b7cQ7SVDycap0+I0VnlSvOnAvdn85xewJ9SaExxySenE3gPzuB4YKmwKbmHiEARb
Ix+7MOwvqZu3RcQ=
-----END CERTIFICATE-----
expiration          1583765865
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUJNtQBkMSqAme1LNcxD3cXi/rnzowDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAzMDgxNDUzNDJaFw0yNTAz
MDcxNDU0MTJaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMHXztIF21d0
iJBAppBfaVZaS9B0qJk5lTBEiX8VF8ybD+pQnZOtCBnYvFxpdx0NEKqkxyL+Fz4L
+G+b8ouyxCgtXMGLCpQbid6+TDj6xuNbPtM1vcu0sZnqHEcesBt1sHmCCQzBthdC
ng9dlxKRiIEjJi5vsjvuEfpV7ZFGMIFgVYjo12QU7vEcFy4fWpX/LdVfhym0JqSf
YrYBTMWVjiD+wGsSXQiZqi398aCb2a/O4jqeU/fuI1lnBAWcbmCAKVaB3iYRSubG
lB6kWhDR7tYuIszawGjEoDWXq2qG0k9axNqUC9XVnPRIyy/g+YoGpMfYUJVFwItM
ZfldVGvuDU0CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUaHQyL5PjzfT5tFtzEvg1BnLDUVUwHwYDVR0jBBgwFoAU
zUHjkFVZ4hmNsAGwonzJv4bQvAQwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
Ybpq4qxJiN6J0Y8YoNKvjpoeVHW3rdsoTxFz67B7zw+Ebx6NGDxLV1I8X/yxgtd5
DGr7UHD8qWqdkA5L4Z36ZZHcWMRNbXzMHewDlojuweC0ESrP0CJS5jLXu9D5yg/u
BE8LGO6BU+2nlbxCbVhIiMQrAQelZF33G/7P6QuZ/C3gR1tPQBv3eaRUk9YyOymS
77S8VndDYWzQ8xur1HM4taheFRp+grmlV+H1I0l8MW/OHFfNYrYe4Gg7LdThv5MF
Ul8yWjI+9WutSlyc3EYcKO0T0KohcOxqX+e7Ej6bbqhHjhl2nNYXoPN9gF0QMute
IfSbThcbxxa2r3mno2nANQ==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAz5wlBLQlkqHjaDfmkSFV9wxkSrm9QevNSeTwHOQSzlptcEhj
iVLRm21DzDadIkGqi5/LR4/cS9uXyyiRCy9KmsYojgu16RYwJ5+O87RXnkvB6W5y
n1rTH9r67j645263pk3smmbShgxOqVN0r805JXth8mMd3Eikp722AbJoNkHMfr40
ezgMijsr9QFS5Bx6dfbTy21ymU1xu1shYpW4J2Mz1iqta306h6uDqCadtRy8OZlS
gEVFtRt5z7PvG5ryKxl8fZb5tSPnGFOD19sWM9srmAgnLESVR4L2f9ouWblbAiN6
wu+0iYGU2RIb0BrpHtDtrBMfF4Ytjd/EgEog1QIDAQABAoIBABqNf/aQC9YrOmiT
7btWJiaIwTMFen056XGwBD3NtdIKosCfoYtoukJEwU0XFxXQjD17XIZ0kdpp5Yoo
UBS8IbCV843nVYbQPaxzrdbhk+s9CToP1D0pYqNKYJmkEAYZlQeCI+bDi911KYJi
mCP7/XkbxLU5lBIegGCr1OF2rflySb0e4gkqEdOm8q2G6b5bpbR00+ftOnC7JOmW
bUAj+smcNVGB6Wr+mFdHbXnDbXNKviUr/qU/2+LU3M/WGgVTpD/5Wo8w41Lc6DsR
ZWmNgdFZuN924K64gLE9bGODgWwgtmnej4mK88wlmV+i78bZX2IN62CywnEl2DwQ
ANb48EECgYEA/E/Iltw3H5lXyPibyg8zJtWw2akD18jHe7ipmQjEuMxBgQFNHoPB
kPglW1vRkRCEj84lZxbDwsuQqhtwqGXM2s/dR55Nj3p/NrGi7rJE0NJuH6nddmEW
gU3NV7vRrdqsyHxOSWfYu7DVy9tatiQ+wPSZ2JRFVTAgpeECF4ULFykCgYEA0qUT
U/QHP3kUjHJsCBck8SgbNS3M6jla2Nn4m6LF+WHhp6l1ca4CS38J5BfF5Oq2TgSl
OCfjFnfni/EDQ+r1MozYzskRwJvCOE/qx8GBJ8pCSA+l5B2q0/fP9VpsZ9RwfPFP
QVtCDlBppYZpSiEa0jz9MVsNZxLwslBwja1Pjc0CgYEAhBsaAbMnwYm+ZuGUYEV5
GNpGEJDoDDF6ERNs6U2oAsIfgfY2dMWzsb3bgWwf2/50Cf97ofBPa0y+X/KiF+nF
SsQPLhJ6tacDuJVlo+j/Ev863aVI6VSIPgeIfmk+rfKTCR3ct56B4jQCnQwrALcV
jF4Ft1pauvHKBlA7kij815ECgYEAoqa+xuu+kP+Ao3ZS/uhIKUKrx6NnAFFrWdjt
macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUJNtQBkMSqAme1LNcxD3cXi/rnzowDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAzMDgxNDUzNDJaFw0yNTAz
MDcxNDU0MTJaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMHXztIF21d0
iJBAppBfaVZaS9B0qJk5lTBEiX8VF8ybD+pQnZOtCBnYvFxpdx0NEKqkxyL+Fz4L
+G+b8ouyxCgtXMGLCpQbid6+TDj6xuNbPtM1vcu0sZnqHEcesBt1sHmCCQzBthdC
ng9dlxKRiIEjJi5vsjvuEfpV7ZFGMIFgVYjo12QU7vEcFy4fWpX/LdVfhym0JqSf
YrYBTMWVjiD+wGsSXQiZqi398aCb2a/O4jqeU/fuI1lnBAWcbmCAKVaB3iYRSubG
lB6kWhDR7tYuIszawGjEoDWXq2qG0k9axNqUC9XVnPRIyy/g+YoGpMfYUJVFwItM
ZfldVGvuDU0CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUaHQyL5PjzfT5tFtzEvg1BnLDUVUwHwYDVR0jBBgwFoAU
zUHjkFVZ4hmNsAGwonzJv4bQvAQwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
Ybpq4qxJiN6J0Y8YoNKvjpoeVHW3rdsoTxFz67B7zw+Ebx6NGDxLV1I8X/yxgtd5
DGr7UHD8qWqdkA5L4Z36ZZHcWMRNbXzMHewDlojuweC0ESrP0CJS5jLXu9D5yg/u
BE8LGO6BU+2nlbxCbVhIiMQrAQelZF33G/7P6QuZ/C3gR1tPQBv3eaRUk9YyOymS
77S8VndDYWzQ8xur1HM4taheFRp+grmlV+H1I0l8MW/OHFfNYrYe4Gg7LdThv5MF
Ul8yWjI+9WutSlyc3EYcKO0T0KohcOxqX+e7Ej6bbqhHjhl2nNYXoPN9gF0QMute
IfSbThcbxxa2r3mno2nANQ==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUJJ6kRU1m34veWMF5mCA+pahvcUQwDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIwMDMwODE1MDE0NFoXDTIwMDMwOTE1MDIxM1owHDEaMBgGA1UEAxMRZ2l0
bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDX
V5oGPSZqXYMXZo0RnHDvQOadokYSxdDWssboq5VKHHdlBPJcVn6N2y3WmWGxAOvU
fjhokDFl6q3sfBPV3jv3TYgGZPNU9qFMKpXjk1ymqHSPdDTzxYgvxboMK5wy+XSp
5rgf1t/j2QdLhrpZTaUu6LtJ2lNZVveFcp6ckyTJJNs/flKJf3djxtQesH6UhVX0
E7tK+htnNT66Tg6QOu0+SgB5UPlaeqRpgzF9iOztVT3PWzwHk5eyIRViJjSWIpuv
fwQ1NwHd69sHYLb01pnxUCvp+KlHaS4KyuXNyilwPtKJwe434c5prm2vcylnB5Hn
hj69UH5Fm3Kmce5Ww/GNAgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUCBxbsc8bTDbwR6UC
Be7pIrBcn/QwHwYDVR0jBBgwFoAUaHQyL5PjzfT5tFtzEvg1BnLDUVUwHAYDVR0R
BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBABF9lw5z
9aQvOZok/YPC8BBVWHJeMAIsxeLiKhuQ6UAgDKnrih3nKeeDQ69hbcfFnPfIuyey
ql3sjn+hzh17DBQdT7DjseeV4aShx72rgPDVHRWaMyNfx7iMQzh3yqWrvFovFQpJ
gBckLZO9EAK30j9Az+G0zfCfJIBzy3rbHkourAaQ5zV9bV17FpcThXaQJ0jHDMUu
hBdSH3HmbhL1i9didhFCzbRcaTp0E7ZyKFUFqw7PimavKXI/ZEp2x3Rkz+fprRd/
FcX7n83IcgoAUj2npS5WE5xACVUXEkTq5pih1Ci0uZGtXSlrw5W29amFZNEjOOvm
fxcsaHAtcK5t4Rk=
-----END CERTIFICATE-----
expiration          1583766133
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUJNtQBkMSqAme1LNcxD3cXi/rnzowDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMDAzMDgxNDUzNDJaFw0yNTAz
MDcxNDU0MTJaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMHXztIF21d0
iJBAppBfaVZaS9B0qJk5lTBEiX8VF8ybD+pQnZOtCBnYvFxpdx0NEKqkxyL+Fz4L
+G+b8ouyxCgtXMGLCpQbid6+TDj6xuNbPtM1vcu0sZnqHEcesBt1sHmCCQzBthdC
ng9dlxKRiIEjJi5vsjvuEfpV7ZFGMIFgVYjo12QU7vEcFy4fWpX/LdVfhym0JqSf
YrYBTMWVjiD+wGsSXQiZqi398aCb2a/O4jqeU/fuI1lnBAWcbmCAKVaB3iYRSubG
lB6kWhDR7tYuIszawGjEoDWXq2qG0k9axNqUC9XVnPRIyy/g+YoGpMfYUJVFwItM
ZfldVGvuDU0CAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQUaHQyL5PjzfT5tFtzEvg1BnLDUVUwHwYDVR0jBBgwFoAU
zUHjkFVZ4hmNsAGwonzJv4bQvAQwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
Ybpq4qxJiN6J0Y8YoNKvjpoeVHW3rdsoTxFz67B7zw+Ebx6NGDxLV1I8X/yxgtd5
DGr7UHD8qWqdkA5L4Z36ZZHcWMRNbXzMHewDlojuweC0ESrP0CJS5jLXu9D5yg/u
BE8LGO6BU+2nlbxCbVhIiMQrAQelZF33G/7P6QuZ/C3gR1tPQBv3eaRUk9YyOymS
77S8VndDYWzQ8xur1HM4taheFRp+grmlV+H1I0l8MW/OHFfNYrYe4Gg7LdThv5MF
Ul8yWjI+9WutSlyc3EYcKO0T0KohcOxqX+e7Ej6bbqhHjhl2nNYXoPN9gF0QMute
IfSbThcbxxa2r3mno2nANQ==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA11eaBj0mal2DF2aNEZxw70DmnaJGEsXQ1rLG6KuVShx3ZQTy
XFZ+jdst1plhsQDr1H44aJAxZeqt7HwT1d47902IBmTzVPahTCqV45Ncpqh0j3Q0
88WIL8W6DCucMvl0qea4H9bf49kHS4a6WU2lLui7SdpTWVb3hXKenJMkySTbP35S
iX93Y8bUHrB+lIVV9BO7SvobZzU+uk4OkDrtPkoAeVD5WnqkaYMxfYjs7VU9z1s8
B5OXsiEVYiY0liKbr38ENTcB3evbB2C29NaZ8VAr6fipR2kuCsrlzcopcD7SicHu
N+HOaa5tr3MpZweR54Y+vVB+RZtypnHuVsPxjQIDAQABAoIBAQCilPktDK4cUE3R
NRP83+hEOvPiv8m4ErIB5yhWMnWcZrGeC4YQQR17bKfHBjbDtLZY0JM2Hues0upN
ScCQECGmLVstuLoew7Y0E1LnZzLkgPq/9DSmd9TCfL5iwepEciKqxA7vuwN+uzTO
yQGYuw6jxALjV3rmUMrAbjFidZWoZk+618f53jidk9DmGN61wM6CvghlSgFJekQS
iUN6CAGgLULf1+WJEFfjOZI74c6xPJX9DERZj78sjpuCZ2M0fEesKxu8QsiXqJoF
cEebGB2/cupIzddz8BIovCLJkFAvtl0cLr1+kkW+EP0baMLS1Joz5zZQ0gdW3awA
L+cSUtkBAoGBANnkqoJmYRGz0tFTZ/1mkB3evh6fmtTNvvSA6d6+c/8tTwR1CQ2u
Vs+W8sftfxEwsDztqUtlJsE38ryj6rqgAMlUXeISQKG8JsEXgNS8+fWoAOWYdhQF
Ab3v+OuXAJrsHSzeKlY+Xu8LFhAQsDBHB5tp5Qej+Bp58tuppb0F+m9JAoGBAP0A
uQ9qJ3LpoOgg88t7hq86ZZKNjwGf+77WcMefYwktFx06Ev7p/QCNw/99+KsBK5Fe
BTXZvjUoCE74PywrMoWdoSeP3k1zwhzNl2IDthpVjszRcoWv95HAREeVrftKRmsW
8Git5F27mynxLllhcO7KHKvnGHDUM1DXfBCF1vwlAoGBAMGc2I4KXtKWEQwDqvGV
wxVnqVQYykGxmK42JpnQbc4e+omhXSwU7/qBzLUuKayisNdS7w2Zkfg6uKw6kwbF
yi0blFifk2Kjh2QoeEeQrCNG55UcBj//uu6FX5Anm1gN2lbWCpSb00thdHdN/ODJ
HM9SJzrEzl7oYY4ijq0JtOBRAoGAZkJ5ijJ02Wx2vfw7rd4ytPacgVy4FYcNYLga
A4V3qQjRk92aOfBnc2bZdpX7AVtKucnPv1FQIPoaSZjrJ7YaCImKzovG5XVJWwz6
CALKAuDcBAsQB9r07LNSpcBo/u2pgrVV3GmUqRIgCBbUjgnldI66gfy5EzmhuCYw
nhkKqQUCgYAFqBnrerjdQJvXD8x7JJjt/YFfRTtIco+O6R5f7u/LiSvtHNo8lsYM
BKoN9DgW7R3NkUYweSCQQZFhGHvs+fzuJG3266L6v0/syvXXcRQizhVV9IZTxKpi
O3FfgUk/yf5xUPv/DJfNGbTxFotMB5JoTnnKGcHfKF4W30/9WIQJBQ==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       24:9e:a4:45:4d:66:df:8b:de:58:c1:79:98:20:3e:a5:a8:6f:71:44
macpro:kubernetes-vault maksim.vasilev$ kubectl exec -it vault-0 -- vault write pki_int/revoke serial_number="24:9e:a4:45:4d:66:df:8b:de:58:c1:79:98:20:3e:a5:a8:6f:71:44"
Key                        Value
---                        -----
revocation_time            1583679764
revocation_time_rfc3339    2020-03-08T15:02:44.760722998Z
macpro:kubernetes-vault maksim.vasilev$

#Сгенерировал ключи и обновил values.yml для helm cогласно данной инструкции
https://www.vaultproject.io/docs/platform/k8s/helm/examples/standalone-tls/

! tls_disable=0 для работы https

#Для проверки поднял под
kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image alpine:3.7
apk add curl jq
VAULT_ADDR=https://vault:8200
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 
# curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/
v1/auth/kubernetes/login
{"request_id":"de01cee8-f36b-86bd-76e2-b8bf3a3422d3","lease_id":"","renewable":false,"lease_duration":0,"data":null,"wrap_info":null,"warnings":null,"a
uth":{"client_token":"s.qpjYyW0JHOLoxaYsphwUlEXq","accessor":"JKk8B8spaQwXo1q52wMVgDbG","policies":["default","otus-policy"],"token_policies":["default
","otus-policy"],"metadata":{"role":"otus","service_account_name":"vault-auth","service_account_namespace":"default","service_account_secret_name":"vau
lt-auth-token-pch8h","service_account_uid":"b55a52ec-613d-11ea-8d8e-42010af00230"},"lease_duration":86400,"renewable":true,"entity_id":"f7d60355-f73f-7
221-0028-bd90cffd5f3e","token_type":"service","orphan":true}}



#Динамические сертификаты для nginx
Добавил в политику права на изменения PKI








