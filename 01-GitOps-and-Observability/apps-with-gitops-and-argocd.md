## Deploying Applications with GitOps and ArgoCD

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)


### Links
- [https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [Server Side Apply - Kubernetes docs](https://kubernetes.io/docs/reference/using-api/server-side-apply/)
- [App of Apps Pattern - ArgoCD Docs](https://argo-cd.readthedocs.io/en/latest/operator-manual/cluster-bootstrapping/)
- [Sync Phases and Waves - ArgoCD Docs](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/)

### GitOps Repo Structure

```bash
my-gitops-repo/
├── infrastructure/
│   ├── cert-manager/
│   │   └── clusterissuer.yaml
│   ├── ingress-nginx/
│   │   └── ingress-nginx.yaml
│   └── monitoring/
│       ├── loki/
│       │   └── values.yaml
│       └── prometheus/
│           └── values.yaml
│
├── applications/
│   └── ghost/
│       ├── namespace.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── pvc.yaml
│
├── argocd-apps/
│   ├── infrastructure/
│   │   ├── cert-manager-app.yaml
│   │   ├── ingress-nginx-app.yaml
│   │   ├── loki-app.yaml
│   │   └── prometheus-app.yaml
│   ├── applications/
│   │   └── ghost-app.yaml
│   └── app-of-apps.yaml                    # ← Parent application
│
└── README.md
```


### Commands used in this lesson

```bash

# create namespace
kubectl create ns argocd

# install argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# wait for pods
kubectl -n argocd get pods

# get admin password for argo UI
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode ; echo

# create an SSH tunnel from your local machine to the control plane server
# ssh -L 8080:localhost:8080 root@<control-plane-ip-address>
ssh -L 8080:localhost:8080 root@172.233.98.105

# port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# open browser to https://localhost:8080

# username is admin
# password is from the secret above

# clone down the course repo
git clone https://github.com/chadmcrowell/k8s-from-scratch.git

# set this to your own gitops repo
MY_GITOPS_REPO="https://github.com/<your-github-username>/my-gitops-repo.git"

git clone $MY_GITOPS_REPO

# script to create directory strcuture for ArgoCD
cp k8s-from-scratch/01-GitOps-and-Observability/setup-repo.sh my-git-repo/
./setup-repo.sh

# copy all the files from the course repo into your gitops repo
cp ./01-GitOps-and-Observability/clusterissuer.yaml ../my-gitops-repo/infrastructure/cert-manager/
cp ./01-GitOps-and-Observability/ingress-nginx.yaml ../my-gitops-repo/infrastructure/ingress-nginx/
cp ./01-GitOps-and-Observability/kps-values.yaml ../my-gitops-repo/infrastructure/monitoring/prometheus/
cp ./01-GitOps-and-Observability/loki-values.yaml ../my-gitops-repo/infrastructure/monitoring/loki/
cp ./01-GitOps-and-Observability/ingress.yaml ../my-gitops-repo/applications/ghost/
cp ./01-GitOps-and-Observability/namespace.yaml ../my-gitops-repo/applications/ghost/
cp ./01-GitOps-and-Observability/deployment.yaml ../my-gitops-repo/applications/ghost/
cp ./01-GitOps-and-Observability/service.yaml ../my-gitops-repo/applications/ghost/
cp ./01-GitOps-and-Observability/pvc.yaml ../my-gitops-repo/applications/ghost/


```

- [app-of-apps.yaml](app-of-apps.yaml)
- [cert-manager-app.yaml](cert-manager-app.yaml)
- [ingress-nginx-app.yaml](ingress-nginx-app.yaml)
- [prometheus-app.yaml](prometheus-app.yaml)
- [loki-app.yaml](loki-app.yaml)
- [ghost-app.yaml](ghost-app.yaml)

```bash
# commit and push
git add .
git commit -m "Prepare repo for ArgoCD"
git push origin main

kubectl apply -f argocd-apps/app-of-apps.yaml
```

