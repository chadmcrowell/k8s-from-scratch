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


# List all applications managed by app-of-apps
argocd app list

```




### Resources

- [https://argo-cd.readthedocs.io/en/stable/understand_the_basics/](https://argo-cd.readthedocs.io/en/stable/understand_the_basics/)
- [https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [https://argo-cd.readthedocs.io](https://argo-cd.readthedocs.io/)
- [https://argo-cd.readthedocs.io/en/stable/getting_started/](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [https://www.youtube.com/watch?v=8AJlVQy6Cx0](https://www.youtube.com/watch?v=8AJlVQy6Cx0)
- [https://codefresh.io/learn/argo-cd/](https://codefresh.io/learn/argo-cd/)
- [https://akuity.io/blog/gitops-best-practices-whitepaper](https://akuity.io/blog/gitops-best-practices-whitepaper)
- [https://codefresh.io/blog/argo-cd-best-practices/](https://codefresh.io/blog/argo-cd-best-practices/)
- [https://configu.com/blog/gitops-with-argocd-a-practical-guide/](https://configu.com/blog/gitops-with-argocd-a-practical-guide/)
- [https://www.microtica.com/blog/the-ultimate-list-of-gitops-resources](https://www.microtica.com/blog/the-ultimate-list-of-gitops-resources)
- [https://scalr.com/learning-center/top-10-gitops-tools-for-2025-a-comprehensive-guide/](https://scalr.com/learning-center/top-10-gitops-tools-for-2025-a-comprehensive-guide/)
- [https://www.cncf.io/blog/2025/06/09/gitops-in-2025-from-old-school-updates-to-the-modern-way/](https://www.cncf.io/blog/2025/06/09/gitops-in-2025-from-old-school-updates-to-the-modern-way/)
- [https://github.com/kubernetes-sigs/kustomize/issues/4633](https://github.com/kubernetes-sigs/kustomize/issues/4633)
- [https://github.com/kubernetes/kubernetes/issues/66450](https://github.com/kubernetes/kubernetes/issues/66450)
- [https://github.com/kubernetes-sigs/cluster-api/issues/7913](https://github.com/kubernetes-sigs/cluster-api/issues/7913)
- [https://github.com/kubernetes/kubectl/issues/1766](https://github.com/kubernetes/kubectl/issues/1766)
- [https://github.com/kubernetes-sigs/karpenter/issues/1177](https://github.com/kubernetes-sigs/karpenter/issues/1177)
- [https://kubernetes.io/docs/concepts/extend-kubernetes/operator/](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [https://github.com/kubernetes-sigs/external-dns/issues/4895](https://github.com/kubernetes-sigs/external-dns/issues/4895)
- [https://kubernetes.io/docs/concepts/security/service-accounts/](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [https://github.com/kubernetes-sigs/external-dns/issues/2386](https://github.com/kubernetes-sigs/external-dns/issues/2386)
- [https://kubernetes.io/docs/concepts/cluster-administration/](https://kubernetes.io/docs/concepts/cluster-administration/)
- [https://github.com/kubernetes-sigs/external-dns/issues/3755](https://github.com/kubernetes-sigs/external-dns/issues/3755)
- [https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/)
- [https://github.com/kubernetes-sigs/kustomize/discussions/5046](https://github.com/kubernetes-sigs/kustomize/discussions/5046)
- [https://github.com/kubernetes-sigs/cluster-api/discussions/5501](https://github.com/kubernetes-sigs/cluster-api/discussions/5501)
- [https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/](https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/)
- [https://kubernetes.io/docs/reference/using-api/server-side-apply/](https://kubernetes.io/docs/reference/using-api/server-side-apply/)
- [https://kubernetes.io/docs/concepts/architecture/controller/](https://kubernetes.io/docs/concepts/architecture/controller/)
- [https://github.com/kubernetes-sigs/kubebuilder/discussions/3074](https://github.com/kubernetes-sigs/kubebuilder/discussions/3074)
- [https://github.com/kubernetes-sigs/kustomize/issues/388](https://github.com/kubernetes-sigs/kustomize/issues/388)
- [https://www.reddit.com/r/devops/comments/1dzrep6/mastering_gitops_argocd_vs_fluxcd_complete_guide/](https://www.reddit.com/r/devops/comments/1dzrep6/mastering_gitops_argocd_vs_fluxcd_complete_guide/)
- [https://spacelift.io/blog/gitops-tools](https://spacelift.io/blog/gitops-tools)
- [https://www.youtube.com/watch?v=eqiqQN1CCmM](https://www.youtube.com/watch?v=eqiqQN1CCmM)
- [https://www.reddit.com/r/devops/comments/1hvpejm/open_source_devops_learning_app_with_15_projects/](https://www.reddit.com/r/devops/comments/1hvpejm/open_source_devops_learning_app_with_15_projects/)
- [https://github.com/argoproj/argo-cd/discussions/5667](https://github.com/argoproj/argo-cd/discussions/5667)
- [https://www.trek10.com/blog/exploring-gitops-with-argo-cd](https://www.trek10.com/blog/exploring-gitops-with-argo-cd)
- [https://argoproj.github.io/cd/](https://argoproj.github.io/cd/)
- [https://argo-cd.readthedocs.io/en/latest/user-guide/tracking_strategies/](https://argo-cd.readthedocs.io/en/latest/user-guide/tracking_strategies/)



---

[Next Lesson](metrics-logs-traces-with-opentelemetry.md)

[Section 01 - GitOps and Observability](README.md)