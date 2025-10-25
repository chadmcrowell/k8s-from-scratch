#!/bin/bash

# Create directory structure
mkdir -p infrastructure/cert-manager \
         infrastructure/ingress-nginx \
         infrastructure/monitoring/prometheus \
         infrastructure/monitoring/loki \
         applications/ghost \
         argocd-apps/infrastructure \
         argocd-apps/applications

# Create placeholder files
touch infrastructure/cert-manager/{values.yaml,clusterissuer.yaml}
touch infrastructure/ingress-nginx/deploy.yaml
touch infrastructure/monitoring/prometheus/values.yaml
touch infrastructure/monitoring/loki/values.yaml
touch applications/ghost/{namespace.yaml,deployment.yaml,service.yaml,ingress.yaml,pvc.yaml}
touch argocd-apps/infrastructure/{cert-manager-app.yaml,ingress-nginx-app.yaml,prometheus-app.yaml,loki-app.yaml}
touch argocd-apps/applications/ghost-app.yaml
touch argocd-apps/app-of-apps.yaml
touch README.md

echo "✅ GitOps repository structure created successfully!"
tree -L 3
