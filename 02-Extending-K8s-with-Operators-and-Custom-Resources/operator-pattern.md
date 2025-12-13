## The Operator Pattern: Controllers That Watch and Act

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)

---

## Links

- [Kubernetes Operator pattern overview](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Controllers in Kubernetes](https://kubernetes.io/docs/concepts/architecture/controller/)
- [Custom Resource Definitions (CRDs)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)


---

### Commands used in this lesson

```bash
# operator for cert-manager 
k -n cert-manager get po
# 'cert-manager-d6746cf45-fl4lg' is the main controller
# 'cert-manager-cainjector' injects the CA bundles into CRDs
# 'cert-manager-webhook' validates the certificte before stored in etcd

# operator for servicemonitor
k -n monitoring get po
# 'prometheus-stack-operator-65c5cdd76f-4dglb' is the main controller
# generates prometheus scrape configs
# updates prometheus config when servicemonitors change


# download binaries
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"

# move into /usr/local/bin
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

# Create project directory
mkdir myoperator && cd myoperator

# Initialize the project (scaffolds entire structure)
# --repo specifies your Go module path
# This creates a local Go module - no GitHub repo needed yet
kubebuilder init --domain example.com --repo github.com/chadmcrowell/myoperator

# Create your first API/CRD
# scaffolds a new CRD and controller for our operator project
kubebuilder create api --group apps --version v1 --kind MyApp


```

### Scaffolding that Kubebuilder creates

```bash
.
├── api
│   └── v1
│       ├── groupversion_info.go
│       ├── myapp_types.go
│       └── zz_generated.deepcopy.go
├── bin
│   ├── controller-gen -> /root/myoperator/bin/controller-gen-v0.19.0
│   └── controller-gen-v0.19.0
├── cmd
│   └── main.go
├── config
│   ├── crd
│   │   ├── kustomization.yaml
│   │   └── kustomizeconfig.yaml
│   ├── default
│   │   ├── cert_metrics_manager_patch.yaml
│   │   ├── kustomization.yaml
│   │   ├── manager_metrics_patch.yaml
│   │   └── metrics_service.yaml
│   ├── manager
│   │   ├── kustomization.yaml
│   │   └── manager.yaml
│   ├── network-policy
│   │   ├── allow-metrics-traffic.yaml
│   │   └── kustomization.yaml
│   ├── prometheus
│   │   ├── kustomization.yaml
│   │   ├── monitor_tls_patch.yaml
│   │   └── monitor.yaml
│   ├── rbac
│   │   ├── kustomization.yaml
│   │   ├── leader_election_role_binding.yaml
│   │   ├── leader_election_role.yaml
│   │   ├── metrics_auth_role_binding.yaml
│   │   ├── metrics_auth_role.yaml
│   │   ├── metrics_reader_role.yaml
│   │   ├── myapp_admin_role.yaml
│   │   ├── myapp_editor_role.yaml
│   │   ├── myapp_viewer_role.yaml
│   │   ├── role_binding.yaml
│   │   ├── role.yaml
│   │   └── service_account.yaml
│   └── samples
│       ├── apps_v1_myapp.yaml
│       └── kustomization.yaml
├── Dockerfile
├── go1.23.4.linux-amd64.tar.gz
├── go.mod
├── go.sum
├── hack
│   └── boilerplate.go.txt
├── internal
│   └── controller
│       ├── myapp_controller.go
│       ├── myapp_controller_test.go
│       └── suite_test.go
├── Makefile
├── PROJECT
├── README.md
└── test
    ├── e2e
    │   ├── e2e_suite_test.go
    │   └── e2e_test.go
    └── utils
        └── utils.go

```

## Key Takeaways

- Kubebuilder scaffolds CRDs, controllers, RBAC, and sample manifests so you can focus on reconciling business logic.
- The Operator Framework adds lifecycle tooling (OLM) to package, install, and upgrade operators in clusters.
- Both approaches standardize controller patterns: a reconcile loop watches resources, compares desired vs. actual state, and issues Kubernetes API updates.
- Choose Kubebuilder for Go-first controller development; use Operator Framework when you also need cataloging, versioning, and cluster-wide operator distribution.
