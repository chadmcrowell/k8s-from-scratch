# Finally Understand Kubernetes from Scratch (2025) | Hands-On in Any Cloud

Learn **how Kubernetes works — from the ground up - in any cloud**  
This repository is a complete hands-on lab that helps you understand Kubernetes primitives, custom controllers, Helm, Kustomize, CRDs, and cluster security using Kyverno and Falco — **all without relying on managed services.**

---

## 📘 Overview

This repository demonstrates how to:

- Bootstrap Kubernetes components manually or via kubeadm
- Apply and extend **Custom Resource Definitions (CRDs)**
- Manage manifests declaratively using **Kustomize**
- Configure applications dynamically using **Helm**
- Implement **security and compliance** controls with Kyverno and Falco
- Enforce **Network Policies and RBAC** at scale

Every YAML file in this repo is handcrafted for learning and production awareness.

---

## 🗂 Repository Structure

```bash
k8s-from-scratch/
├── helm-values-examples.yaml           # Helm values for multiple tools (Kyverno, ArgoCD, Prometheus, Cilium, etc.)
├── kustomization-examples.yaml         # 50+ Kustomize environments with environment labels and patches
├── kustomization-patches.yaml          # Individual deployment patches per environment
├── custom-resource-definitions.yaml    # 30+ CRDs (ArgoCD, Prometheus, LokiStack, cert-manager, Postgres Operator)
├── kyverno-falco-policies.yaml         # Kyverno + Falco security policies and detection rules
├── networkpolicy-rbac-examples.yaml    # Deny-all NetworkPolicies and namespace-level RBAC
├── networkpolicy-rbac-variations.yaml  # Ingress-allowed NetworkPolicies and cluster-wide RBAC bindings
├── awesome-k8s-resources.md            # Curated list of awesome CNCF tools and learning resources
└── combined_output.yaml                # Aggregated manifest for testing or demo purposes
```

---

## 🧱 Core Components

### 1. **Helm Charts**
`helm-values-examples.yaml` includes example `values.yaml` configurations for:

| Tool | Purpose |
|------|----------|
| **Kyverno** | Admission controller for policy enforcement |
| **ArgoCD** | GitOps deployment engine |
| **Prometheus** | Monitoring stack with Alertmanager |
| **Cilium** | eBPF-based networking and observability |
| **Example Tools (5–50)** | Placeholder services for testing resource templates |

Use these with:
```bash
helm install kyverno kyverno/kyverno -f helm-values-examples.yaml
```

Each block is separated by `---` to support direct `kubectl apply -f` parsing.

---

### 2. **Custom Resource Definitions (CRDs)**

`custom-resource-definitions.yaml` defines multiple CRDs across popular operators and example APIs.

Key CRDs include:

* `Pgcluster` — Crunchy Postgres Operator
* `Prometheus`, `Alertmanager`, `ServiceMonitor` — monitoring.coreos.com
* `Certificate` — cert-manager.io
* `LokiStack` — loki.grafana.com
* `Application` — argoproj.io
* `GrafanaDashboard` — integreatly.org
* Example CRDs (`example0.kubeskills.io` → `example30.kubeskills.io`) for operator-building exercises

Validate with:

```bash
kubectl get crds | grep kubeskills.io
```

---

### 3. **Kustomize Environments**

`kustomization-examples.yaml` and `kustomization-patches.yaml` illustrate **multi-environment overlays**.

Each environment (env1 → env50):

* Has its own `kustomization.yaml` overlay.
* Applies a corresponding patch (`envX-patch.yaml`).
* Changes replicas, image tags, and resource limits per environment.

Example:

```bash
# Build and preview env3 manifest
kubectl kustomize overlays/env3
```

Sample patch:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 4
  template:
    spec:
      containers:
      - name: my-app
        image: my-app:3.0
```

---

### 4. **Security Policies**

#### 🔒 Kyverno

`kyverno-falco-policies.yaml` includes multiple ClusterPolicies to enforce best practices:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-hostpath
spec:
  validationFailureAction: enforce
  rules:
  - name: host-path
    match:
      resources:
        kinds: ["Pod"]
    validate:
      message: HostPath volumes are not allowed.
      pattern:
        spec:
          volumes:
          - hostPath:
              path: '!*'
```

#### 🐺 Falco

The same file defines Falco rules for runtime detection:

```yaml
apiVersion: falco.org/v1alpha1
kind: FalcoRule
metadata:
  name: write-outside-container
spec:
  rules:
  - rule: Write below root
    desc: Detect writes below root directory
    condition: evt.type = write and fd.name startswith /root
    output: 'Writing below root directory detected'
    priority: Warning
```

To apply both:

```bash
kubectl apply -f kyverno-falco-policies.yaml
```

---

### 5. **Network Policies & RBAC**

#### Egress Deny-All

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-egress
spec:
  podSelector: {}
  policyTypes: ["Egress"]
```

#### HTTP-Allow per Namespace

`networkpolicy-rbac-variations.yaml` defines namespace-isolated ingress rules:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-http
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
  ingress:
  - from:
      - namespaceSelector:
          matchLabels:
            name: namespace-3
    ports:
    - protocol: TCP
      port: 80
```

#### RBAC

Each namespace defines a Role + RoleBinding pair:

```yaml
kind: Role
metadata:
  name: read-pods
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

Cluster-wide permissions:

```yaml
kind: ClusterRole
metadata:
  name: cluster-admin-lite
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```

---

## 🧩 Learning Path

| Step | Topic                | File                               | Command             |
| ---- | -------------------- | ---------------------------------- | ------------------- |
| 1    | CRDs and Operators   | `custom-resource-definitions.yaml` | `kubectl apply -f`  |
| 2    | Helm configuration   | `helm-values-examples.yaml`        | `helm install`      |
| 3    | Kustomize overlays   | `kustomization-examples.yaml`      | `kubectl kustomize` |
| 4    | Security enforcement | `kyverno-falco-policies.yaml`      | `kubectl apply -f`  |
| 5    | Networking and RBAC  | `networkpolicy-rbac-examples.yaml` | `kubectl apply -f`  |

---

## 🧠 Best Practices Demonstrated

* **Declarative configuration** via YAML and overlays
* **Layered management** with Helm + Kustomize
* **Security-first defaults** (deny-all + hostPath restrictions)
* **Operator extensibility** through CRDs
* **GitOps-ready** manifests for ArgoCD or FluxCD
* **Multi-environment parity** using strategic merge patches

---

## 🧰 Prerequisites

* Kubernetes cluster (v1.28+)
* `kubectl`, `helm`, and `kustomize` installed
* (Optional) Kyverno, Falco, and ArgoCD for full workflow

```bash
kubectl version --short
helm version
kustomize version
```

---

## 🚀 Quickstart

```bash
# Clone the repo
git clone https://github.com/<your-org>/k8s-from-scratch.git
cd k8s-from-scratch

# Deploy base CRDs
kubectl apply -f custom-resource-definitions.yaml

# Apply sample Helm values
helm install kyverno kyverno/kyverno -f helm-values-examples.yaml

# Apply Kustomize overlays
kubectl apply -k overlays/env1

# Enforce security rules
kubectl apply -f kyverno-falco-policies.yaml

# Apply network and RBAC configs
kubectl apply -f networkpolicy-rbac-examples.yaml
```

---

## 🧩 Integrations

* Works with [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
* Supports [FluxCD](https://fluxcd.io)
* Uses [Kyverno](https://kyverno.io) for admission policies
* Uses [Falco](https://falco.org) for runtime detection
* Compatible with [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) clusters and [Kind](https://kind.sigs.k8s.io/)

---

## 🧾 License

MIT License © 2025 [KubeSkills](https://kubeskills.com)

---

## 🙌 Contributing

Contributions are welcome!
To add new examples or CRDs:

1. Fork this repo.
2. Add your YAML file to the appropriate directory.
3. Submit a PR with a short description of your addition.

---

## 📚 References

See [`awesome-k8s-resources.md`](awesome-k8s-resources.md) for a curated list of:

* CNCF tools
* GitOps platforms
* Security and observability stacks
* Operator frameworks
* Exam prep and certification materials

---

> ⚙️ Built by **KubeSkills** to help learners, engineers, and SREs understand Kubernetes from first principles.


