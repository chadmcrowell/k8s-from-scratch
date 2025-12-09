## Visualize Observability Data with Grafana

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)

---

## Links

- [Prometheus data source - Grafana Docs](https://grafana.com/docs/grafana/latest/datasources/prometheus/)
- [Loki data source - Grafana Docs](https://grafana.com/docs/grafana/latest/datasources/loki/)
- [Tempo data source - Grafana Docs](https://grafana.com/docs/grafana/latest/datasources/tempo/)
- [Grafana Explore for metrics, logs, and traces](https://grafana.com/docs/grafana/latest/explore/)
- [Grafana Dashboards Library](https://grafana.com/grafana/dashboards/)


---

### Commands used in this lesson

```bash
# create ssh tunnel
ssh -L 3000:localhost:3000 -N -f root@172.233.98.105
# Stop it with: pkill -f "ssh.*3000:localhost:3000"
# pkill -f "ssh.*8080:localhost:3000"

# port forward to access Grafana UI
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Access: http://localhost:3000

# retreive Grafana login creds
# The Helm chart creates a secret with the password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d && echo
# Expected output: prom-operator


# Find Loki service
kubectl get svc -n monitoring | grep loki

# Get Loki URL
kubectl get svc -n monitoring loki -o jsonpath='http://{.metadata.name}:{.spec.ports[?(@.name=="http-metrics")].port}'
# Expected: http://loki:3100 (adjust based on your actual service name)




```

### PromQL Queries

```promql
# PANEL: Cluster Node Health
# Explanation:# - up: Built-in metric (1 = target reachable, 0 = down)# - job="node-exporter": Filter to cluster nodes
up{job="node-exporter"}

# PANEL: Control Plane API Server Requests
# apiserver_request_total: Counter of all API server requests# - rate([5m]): Calculate per-second rate over 5 minutes# - sum by (verb, code): Group by HTTP method and status code
sum(rate(apiserver_request_total[5m])) by (verb, code)

# Error rate (4xx and 5xx)
sum(rate(apiserver_request_total{code=~"^(4|5).*"}[5m])) by (verb, code)

# PANEL: Node CPU Usage
# CPU usage percentage by node and mode
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   
# Alternative: Break down by CPU mode
avg by (instance, mode) (rate(node_cpu_seconds_total[5m])) * 100

# PANEL: Pod Status Across Cluster
# Count pods by phase
count by (phase, namespace) (kube_pod_status_phase)


```