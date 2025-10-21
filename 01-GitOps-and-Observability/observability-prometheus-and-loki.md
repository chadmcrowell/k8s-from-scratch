## Observability in Kubernetes with Prometheus and Loki

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)


### Resources
- [Prometheus Stack Overview - GitHub](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md)
- [Prometheus Stack Values File](kps-values.yaml)
- [Loki Values File](loki-values.yaml)

### Commands used in this lesson

```bash
#################################################
####### INSTALL PROMETHEUS STACK ################
#################################################

# https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md

# values file 'kps-values.yaml' in this same directory
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

# values file 'loki-values.yaml' in this same directory (change values for your S3 bucket)

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


### Additional Resources

- [Prometheus Stack Values File - Use with Helm Install](kps-values.yaml)
- [Loki Values File - Use with Helm Install](loki-values.yaml)
- [Prometheus Stack Overview - GitHub](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md)
- [Installing Loki - Grafana Docs](https://grafana.com/docs/loki/latest/setup/install/helm/install-monolithic/)
- [Create S3 Bucket with Access Keys in Linode](https://techdocs.akamai.com/cloud-computing/docs/create-and-manage-buckets)




---

[Next Lesson] 

[Section 01 - GitOps and Observability](README.md)