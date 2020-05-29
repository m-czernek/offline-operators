FROM registry.redhat.io/openshift4/ose-operator-registry:v4.4.0

COPY manifests manifests
RUN /bin/initializer -o ./bundles.db
EXPOSE 50051
ENTRYPOINT ["/bin/registry-server"]

CMD ["--database", "bundles.db"]
