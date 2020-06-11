# Creating Offline Operator Marketplace

To create an offline marketplace in OCP 4:

1. Download all operators you require, for example:

```sh
./get-operator.sh redhat-operators elasticsearch-operator
./get-operator.sh redhat-operators kiali-ossm
./get-operator.sh redhat-operators jaeger-product
./get-operator.sh redhat-operators servicemeshoperator
```
Check the _Sources_ section on how to get a list of all the operators (the 4.2 documentation version).

2. Create a manifest directory:

```sh
mkdir manifests ; for f in *.tar.gz; do tar -C manifests/ -xvf $f ; done && rm -rf *tar.gz
```

3. Create the marketplace container:

```sh
export REGISTRY="YOUR_REGISTRY_URL"

podman build --no-cache -f Dockerfile \
    -t ${REGISTRY}/mirrored-operator-catalog

podman push ${REGISTRY}/mirrored-operator-catalog
```

4. Disable external sources for your OCP:

```sh
oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

5. Deploy catalog source using your image:

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: OSSM-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: YOUR_REGISTRY/mirrored-operator-catalog
  displayName: My Operator Catalog
  publisher: grpc
```

6. Verify that operators are available:

```sh
oc get packagemanifest -n openshift-marketplace
```

## Sources

- https://github.com/ppetko/disconnected-install-service-mesh
- https://docs.openshift.com/container-platform/4.2/operators/olm-restricted-networks.html
- https://docs.openshift.com/container-platform/4.4/operators/olm-restricted-networks.html

## Notes

- The `Dockerfile` uses version `v4.4.0`; keep this version in sync with your OpenShift version
- The `get-operator.sh` script requires `jq`, `curl`, and an environment able to download from quay.io

