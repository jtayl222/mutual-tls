oc new-build --name=client registry.access.redhat.com/ubi8/openjdk-11~https://github.com/jtayl222/mutual-tls.git --context-dir=/quarkus-client-mtls
oc new-build --name=server registry.access.redhat.com/ubi8/openjdk-11~https://github.com/jtayl222/mutual-tls.git --context-dir=/quarkus-server-mtls

