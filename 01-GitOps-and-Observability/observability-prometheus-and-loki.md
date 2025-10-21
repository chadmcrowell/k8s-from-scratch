## Observability in Kubernetes with Prometheus and Loki

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)


### Commands used in this lesson

```bash
#################################################
####### INSTALL PROMETHEUS STACK ################
#################################################

# https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md

# see below for values file
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 76.3.0 \
  --namespace monitoring \
  -f kps-values.yaml

# create an SSH tunnel from your local machine to the control plane server
ssh -L 9090:localhost:9090 root@<control-plane-ip-address>

# proxy communication to the prometheus service and open a browser tab to http://localhost:9090
kubectl port-forward -n monitoring svc/prometheus-stack-prometheus 9090:9090

###########################################
####### Common PromQL Queries #############
###########################################

# Node CPU usage %
100 * sum by (instance) (rate(node_cpu_seconds_total{mode!="idle"}[5m]))
  / sum by (instance) (rate(node_cpu_seconds_total[5m]))

# Node CPU Usage
sum(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (instance)

# memory usage %
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)

# Node Memory usage
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# node disk usage
node_filesystem_size_bytes - node_filesystem_free_bytes

# Node up/down status
up{job="node-exporter"}

# Pod CPU usage
sum(rate(container_cpu_usage_seconds_total{container!="",pod!=""}[5m])) by (namespace, pod)

# Pod memory usage
sum(container_memory_usage_bytes{container!="",pod!=""}) by (namespace, pod)

# Pod restarts
sum(kube_pod_container_status_restarts_total) by (namespace, pod)

# Pod restarts by namespace
topk(5, sum by (namespace) (increase(kube_pod_container_status_restarts_total[1h])))

# running and failed pods by namespace
count(kube_pod_status_phase{phase="Running"}) by (namespace)
count(kube_pod_status_phase{phase="Failed"}) by (namespace)

# deployment health
kube_deployment_status_replicas_available
kube_deployment_status_replicas_unavailable

# daemonset status
kube_daemonset_status_current_number_scheduled
kube_daemonset_status_desired_number_scheduled

# job success/failure
kube_job_status_succeeded
kube_job_status_failed

# NGINX Ingress Error Rate
sum(rate(nginx_ingress_controller_requests{status=~"5.."}[5m])) by (ingress)

# CPU allocated vs. used
sum(kube_pod_container_resource_limits_cpu_cores) by (namespace)
sum(rate(container_cpu_usage_seconds_total{container!="",pod!=""}[5m])) by (namespace)

# MEM allocated vs. used
sum(kube_pod_container_resource_limits_memory_bytes) by (namespace)
sum(container_memory_usage_bytes{container!="",pod!=""}) by (namespace)

# prometheus target health
up{job="prometheus"}

# AlertManager Notifications sent
alertmanager_notification_latency_seconds_average

# K8s API server request rate
sum(rate(apiserver_request_total[5m])) by (verb, resource)

# k8s scheduler latency
histogram_quantile(0.99, sum(rate(scheduler_schedule_latency_seconds_bucket[5m])) by (le))

# ghost app HTTP request rate
sum(rate(http_requests_total{app="ghost"}[5m])) by (instance)

# ghost app HTTP errors
sum(rate(http_requests_total{app="ghost",status=~"5.."}[5m])) by (instance)

# all exported metrics
count({__name__=~".+"})

# All active alerts
ALERTS{alertstate="firing"}


###########################################
####### INSTALL LOKI ######################
###########################################

# see below for values file

# create secret with S3 bucket creds
kubectl create secret generic loki-object-storage \
  --namespace monitoring \
  --from-literal=AWS_ACCESS_KEY_ID=$ACCESS_KEY \
  --from-literal=AWS_SECRET_ACCESS_KEY=$SECRET_KEY


# add charts repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki
helm upgrade --install loki grafana/loki \
  --namespace monitoring \
  --values loki-values.yaml

# view all monitoring pods
k -n monitoring get po




```

```yaml
# kps-values.yaml
fullnameOverride: prometheus-stack

# Discover ServiceMonitors/PodMonitors cluster-wide (not just by Helm labels)
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    retention: 15d
    scrapeInterval: 30s
    ruleSelectorNilUsesHelmValues: false
    resources:
      requests:
        cpu: "250m"
        memory: "1Gi"
      limits:
        memory: "4Gi"

# Alertmanager minimal, add your routes later
alertmanager:
  alertmanagerSpec:
    replicas: 2
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        memory: "1Gi"

# Grafana: set your own admin password and expose via NodeBalancer
grafana:
  adminUser: admin
  adminPassword: "superSecretPassword!!"
  service:
    type: LoadBalancer
    port: 80
  grafana.ini:
    server:
      root_url: "%(protocol)s://%(domain)s/"
  persistence:
    enabled: true
    size: 10Gi
  sidecar:
    dashboards:
      enabled: true
    datasources:
      enabled: true

# kube-state-metrics & node-exporter are on by default in recent releases,
# keep them enabled for cluster debugging:
kubeStateMetrics:
  enabled: true
nodeExporter:
  enabled: true
```

```yaml
# loki-values.yaml
loki:
  commonConfig:
    replication_factor: 1
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: s3
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  pattern_ingester:
      enabled: true
  limits_config:
    allow_structured_metadata: true
    volume_enabled: true
  ruler:
    enable_api: true
  storage:
    type: 's3'
    bucketNames:
      chunks: loki-logs
      ruler: loki-logs
      admin: loki-logs
    s3:
      endpoint: "es-mad-1.linodeobjects.com"
      region: "es-mad-1"
      s3ForcePathStyle: true
      insecure: false
  chunksCache:
    enabled: false

minio:
  enabled: false
      
deploymentMode: SingleBinary

singleBinary:
  replicas: 1
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi
  persistence:
    enabled: true
    size: 10Gi
    storageClass: linode-block-storage-retain
  extraEnv:
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: loki-object-storage
          key: AWS_ACCESS_KEY_ID
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: loki-object-storage
          key: AWS_SECRET_ACCESS_KEY

# Zero out replica counts of other deployment modes
backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0

ingester:
  replicas: 0
querier:
  replicas: 0
queryFrontend:
  replicas: 0
queryScheduler:
  replicas: 0
distributor:
  replicas: 0
compactor:
  replicas: 0
indexGateway:
  replicas: 0
bloomCompactor:
  replicas: 0
bloomGateway:
  replicas: 0

```


---

[Next Lesson] 

[Section 01 - GitOps and Observability](README.md)