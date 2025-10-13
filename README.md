# Finally Understand Kubernetes from Scratch (2025) | Hands-On in Any Cloud

Learn **how Kubernetes works — from the ground up - in any cloud**  
This repository is a complete hands-on lab that helps you understand Kubernetes primitives, custom controllers, Helm, Kustomize, CRDs, and cluster security using Kyverno and Falco — **all without relying on managed services.**

![kubernetes from scratch cover image](kubernetes-from-scratch-cover.png)

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

[00-Introduction-and-Installation](00-Introduction-and-Installation/README.md)



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


