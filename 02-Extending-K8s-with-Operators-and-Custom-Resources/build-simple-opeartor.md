## Building a Simple Operator with Kubebuilder

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)

---

## Links

- [What are Kubernetes Operators?](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Kubebuilder quick start](https://book.kubebuilder.io/quick-start.html)


## Files Modified in this Lessson

- [podset_types.go](podset_types.go)
- [podset_controller.go](podset_controller.go)
- [Makefile](Makefile)
- [Dockerfile](Dockerfile)
- [registries.conf](registries.conf)
- [my-podset.yaml](my-podset.yaml)

## Commands Run in this Lesson

```bash

# Delete the old CRD
kubectl delete crd podsets.example.com

# Verify it's gone
kubectl get crds | grep podset

# Delete any existing PodSet instances (if any)
kubectl delete podsets --all -A

# Create project directory
mkdir podset-operator && cd podset-operator

# Initialize Kubebuilder project
kubebuilder init --domain example.com --repo github.com/chadmcrowell/podset-operator

# Create the API and controller
kubebuilder create api --group apps --version v1 --kind PodSet
# Answer 'y' to both prompts

# Open api/v1/podset_types.go and add fields to the spec and status
vim api/v1/podset_types.go

# Generate the CRD manifests
make manifests

# Show the generated YAML in config/crd/bases/
ls config/crd/bases

# Open internal/controller/podset_controller.go and implement the Reconcile function
vim internal/controller/podset_controller.go

# RUN LOCALLY (before building the operator container)

# Install the CRD into your cluster
make install

# Verify CRD exists
kubectl get crds | grep podsets

# Run the operator locally (in your terminal)
make run

# create a test PodSet
kubectl apply -f test-podset.yaml

# Watch the operator logs in the first terminal

# Check if ConfigMap was created
kubectl get configmap test-podset-config -o yaml

# BUILD THE OPERATOR CONTAINER

# FIRST, stop the 'make run' command with ctrl + c

# Install Podman
sudo apt install -y podman

# Alias it to docker
alias docker=podman

# Login to Docker Hub first
docker login

# Build and push Docker image (or use kind load for local testing)
make docker-build docker-push IMG=chadmcrowell/podset-operator:v1

# Deploy the operator to cluster
make deploy IMG=chadmcrowell/podset-operator:v1

# Verify operator pod is running
kubectl get pods -n podset-operator-system

# The operator is just a pod
kubectl get pods -n podset-operator-system

# With a Go binary watching the API
kubectl logs -n podset-operator-system deployment/podset-operator-controller-manager

# It has RBAC permissions to watch PodSets and create ConfigMaps
kubectl get clusterrole | grep podset


```

## Key Takeaways

- Operators aren't magic—they're regular programs running in Pods
- They use the Kubernetes client library to watch resources via the API server
- The reconcile loop runs whenever resources change (informers/watches)
- Kubebuilder generated all the boilerplate (RBAC, deployment manifests, Docker setup)