## What Are Custom Resource Definitions (CRDs)?

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)

---

## Links

- [Custom resources and API extension - Kubernetes Docs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [Create a CustomResourceDefinition - Kubernetes Tasks](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/)
- [CRD validation with OpenAPI schemas](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#validation)
- [CRD versioning and upgrades](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/)
- [CustomResourceDefinition API reference (apiextensions.k8s.io/v1)](https://kubernetes.io/docs/reference/kubernetes-api/extend-resources/custom-resource-definition-v1/)


---

### Commands used in this lesson

```bash
# the certificate resource - created by cert-manager - is one of the many CRDs
k -n ghost get certificate

# view the structure of a Certificate resource in Kubernetes
k -n ghost get certificate -o yaml

# list all the crds in the cluster
kubectl get crds

# list the specification of the certificates resource
kubectl describe crd certificates.cert-manager.io

# create a simple CRD (YAML BELOW)
kubectl apply -f crd.yaml

# once created, view the new crd in the list of crds
kubectl get crds | grep podset 

# create an instance of the PodSet resource (YAML BELOW)
kubectl apply -f my-podset.yaml

# get the podset resources
kubectl get podsets

# list the structure of the podset resource
kubectl describe podset my-podset

# delete the podset resource
kubectl delete podset my-podset


```

> NOTE: A CRD alone is just data sitting in etcd without any behavior. An operator is needed to give that CRD functionality by watching for changes to custom resources and taking action to make things happen in your cluster.

### Create your first simple CRD
Create a basic PodSet CRD that represents a group of identical pods:
```yaml
# crd.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: podsets.example.com
spec:
  group: example.com
  names:
    kind: PodSet
    plural: podsets
    singular: podset
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              replicas:
                type: integer
                minimum: 1
                maximum: 10

```

### Create a PodSet
Create an instance of the PodSet resource:
```yaml
apiVersion: example.com/v1
kind: PodSet
metadata:
  name: my-podset
spec:
  replicas: 3
```

## Key Concepts Recap
- CRDs extend Kubernetes without modifying core code
- They're just YAML definitions that create new API endpoints
- Custom resources work with kubectl like any native resource
- CRDs define the "what" (schema), controllers define the "how" (behavior)
- Real-world examples include Certificates, Ingresses (custom in some clusters), and application-specific resources