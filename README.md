# Creating Offline Operator Marketplace

To create an offline marketplace in OCP 4, if you have access to an OpenShift cluster,
the easiest way to create a manifest image is to follow the [official documentation](https://docs.openshift.com/container-platform/4.6/operators/admin/olm-managing-custom-catalogs.html#olm-building-operator-catalog-image_olm-managing-custom-catalogs) using `oc adm`.

To manually build the manifest image:  

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

Once you have a manifest image:

1. Disable external sources for your OCP:

```sh
oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

2. Deploy catalog source using your image:

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

3. Verify that operators are available:

```sh
oc get packagemanifest -n openshift-marketplace
```

## Verifying the content of a manifest image

To verify what a manifest image includes:

1. Download the latest [grpcurl](https://github.com/fullstorydev/grpcurl/releases/latest).

2. Execute the container locally:

```sh
podman run -p 50051:50051 -it $IMAGE_URL
```

3. Query the contents with `grpcurl`:

```sh
grpcurl -plaintext localhost:50051 api.Registry/ListPackages

{
  "name": "elasticsearch-operator"
}
{
  "name": "jaeger-product"
}
{
  "name": "kiali-ossm"
}
{
  "name": "servicemeshoperator"
}
```

## Sources

- https://github.com/ppetko/disconnected-install-service-mesh
- https://docs.openshift.com/container-platform/4.2/operators/olm-restricted-networks.html
- https://docs.openshift.com/container-platform/4.4/operators/olm-restricted-networks.html
- https://docs.openshift.com/container-platform/4.6/operators/admin/olm-managing-custom-catalogs.html#olm-testing-operator-catalog-image_olm-managing-custom-catalogs

## Notes

- The `Dockerfile` uses version `v4.4.0`; keep this version in sync with your OpenShift version
- The `get-operator.sh` script requires `jq`, `curl`, and an environment able to download from quay.io
