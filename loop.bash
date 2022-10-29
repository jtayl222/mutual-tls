rm tls/server/server.csr
rm tls/server/server.crt
rm tls/server/server.keystore
rm tls/client/client.keystore
rm tls/client/client.csr
rm tls/client/client.crt
rm tls/ca/truststore
rm tls/ca/ca.crt
rm tls/ca/ca.key

ocp-installation/cert.bash

oc delete secret server client truststore
ocp-installation/secret.bash 

