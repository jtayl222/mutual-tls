
mkdir -p tls/{ca,server,client}

# Certificate Authority (CA) and Truststore

CA_PASSWORD=ca-password
CA_KS_PASSWORD=ca-keystore-password
SVR_KS_PASSWORD=svr-keystore-password
CLNT_KS_PASSWORD=clnt-keystore-password
OPENSHIFT_DOMAIN=3node.example.com

#CA_PASSWORD=password
#CA_KS_PASSWORD=password
#SVR_KS_PASSWORD=password
#CLNT_KS_PASSWORD=password
OPENSHIFT_DOMAIN=3node.example.com


# Create:
#  tls/ca/ca.crt
#  tls/ca/ca.key
openssl req -new -newkey rsa:2048 -x509 \
    -keyout tls/ca/ca.key \
    -out tls/ca/ca.crt -passout "pass:$CA_PASSWORD" \
    -days 365 \
    -subj "/CN=$OPENSHIFT_DOMAIN"

# Create:
#  tls/ca/truststore
keytool \
    -import \
    -noprompt \
    -file tls/ca/ca.crt -storepass $CA_KS_PASSWORD \
    -alias 3node.example.com \
    -keystore tls/ca/truststore

# Create:
#   tls/server/server.keystore
keytool -genkeypair -keyalg RSA -keysize 2048 \
    -dname "CN=server" \
    -alias server \
    -keystore tls/server/server.keystore -storepass $SVR_KS_PASSWORD \
    -ext "SAN:c=DNS:server.jeff-tls.svc.cluster.local"

# Verify tls/server/server.keystore
openssl x509 -text -noout \
    -in tls/server/server.keystore -passin "pass:$SVR_KS_PASSWORD"

# Server's CSR - create:
#   tls/server/server.csr
keytool -certreq -keyalg rsa \
    -alias server \
    -keystore tls/server/server.keystore -storepass $SVR_KS_PASSWORD\
    -file tls/server/server.csr

# Server's CA - create:
#   tls/server/server.crt
openssl x509 -req \
    -CA tls/ca/ca.crt -passin "pass:$CA_PASSWORD" \
    -CAkey tls/ca/ca.key \
    -in tls/server/server.csr \
    -out tls/server/server.crt \
    -extfile <(printf "subjectAltName=DNS:example.com,DNS:server.jeff-tls.svc.cluster.local") \
    -days 365 -CAcreateserial

# Update tls/server/server.keystore
keytool -import -v -trustcacerts \
    -noprompt \
    -alias root \
    -keystore tls/server/server.keystore -storepass $SVR_KS_PASSWORD \
    -file tls/ca/ca.crt 

# Update tls/server/server.keystore
keytool -import -v -trustcacerts \
    -alias server \
    -keystore tls/server/server.keystore -storepass $SVR_KS_PASSWORD \
    -file tls/server/server.crt

# Verify the chain
keytool -list -v -keystore tls/server/server.keystore -storepass $SVR_KS_PASSWORD

# Import to truststore
keytool -import \
    -storepass $CA_KS_PASSWORD \
    -file tls/server/server.crt \
    -alias server \
    -keystore tls/ca/truststore


#######

keytool -genkeypair -keyalg RSA -keysize 2048 \
    -dname "CN=client" \
    -alias client \
    -keystore tls/client/client.keystore -storepass $CLNT_KS_PASSWORD


keytool -certreq -keyalg rsa \
    -alias client \
    -keystore tls/client/client.keystore -storepass $CLNT_KS_PASSWORD \
    -file tls/client/client.csr 

openssl x509 -req \
    -CA tls/ca/ca.crt -passin "pass:$CA_PASSWORD" \
    -CAkey tls/ca/ca.key \
    -in tls/client/client.csr \
    -out tls/client/client.crt \
    -days 365 \
    -CAcreateserial

keytool -import -v -trustcacerts \
    -alias root \
    -noprompt \
    -file tls/ca/ca.crt \
    -keystore tls/client/client.keystore -storepass $CLNT_KS_PASSWORD

keytool -import -v -trustcacerts \
    -alias client \
    -file tls/client/client.crt \
    -keystore tls/client/client.keystore -storepass $CLNT_KS_PASSWORD

keytool -list -v -keystore tls/client/client.keystore -storepass $CLNT_KS_PASSWORD

keytool -import \
    -file tls/client/client.crt \
    -alias client \
    -keystore tls/ca/truststore -storepass $CA_KS_PASSWORD 



