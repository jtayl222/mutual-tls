kubectl create secret generic server --from-file=tls/server/
kubectl create secret generic client --from-file=tls/client/
kubectl create secret generic truststore --from-file=tls/ca/truststore

