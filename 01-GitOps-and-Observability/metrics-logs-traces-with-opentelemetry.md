## Apps Emitting Metrics, Logs, and Traces with OpenTelemetry

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository (including scripts)

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)



## Links

- [Docker container used for the Ghost deployment in this lesson](https://hub.docker.com/repository/docker/chadmcrowell/ghost-otel)


- [OpenTelemetry Operator](https://opentelemetry.io/docs/platforms/kubernetes/operator/)
- [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector)

- [Service Monitors in Prometheus](https://grafana.com/docs/alloy/latest/reference/components/prometheus/prometheus.operator.servicemonitors/)

### Dockerfile

> NOTE: We follow a similar pattern as in a previous lesson here:
[Making your own image to run in Kubernetes](../00-Introduction-and-Installation/Making-your-own-image-to-run-in-kubernetes.md)


- [Dockerfile for a new Ghost image](Dockerfile)

```bash
# replace <your-dockerhub-username> with your Docker Hub username. 
# For a private registry on Linode or elsewhere, use the full registry URL
docker build --platform=linux/amd64 -t <your-dockerhub-username>/ghost-otel:latest .

# push your image to the container registry
docker push <your-dockerhub-username>/ghost-otel:latest

```


### Course structure by the end of this lesson

```
my-gitops-repo/
├── infrastructure/
│   ├── cert-manager/
│   ├── ingress-nginx/
│   └── monitoring/
│       ├── loki/
│       │   └── values.yaml
│       ├── prometheus/
│       │   └── values.yaml
│       ├── opentelemetry-collector/  # NEW
│       │   ├── otel-values.yaml      # NEW
│       │   └── servicemon-otel.yaml  # NEW
│       └── tempo/                    # NEW
│           └── tempo-values.yaml     # NEW
│
├── applications/
│   └── ghost/
│       └── deployment.yaml           # REPLACE
│
├── argocd-apps/
│   ├── infrastructure/
│   │   ├── cert-manager-app.yaml
│   │   ├── ingress-nginx-app.yaml
│   │   ├── loki-app.yaml
│   │   ├── prometheus-app.yaml
│   │   ├── otel-collector-app.yaml    # NEW
│   │   └── tempo-app.yaml             # NEW
│   ├── applications/
│   │   └── ghost-app.yaml             
│   └── app-of-apps.yaml
│
└── README.md
```

### Files to add to the directories above

- [ghost-deploy-with-otel.yaml](ghost-deploy-with-otel.yaml)
- [otel-values.yaml](otel-values.yaml)
- [tempo-values.yaml](tempo-values.yaml)
- [tempo-app.yaml](tempo-app.yaml)
- [servicemon-otel.yaml](servicemon-otel.yaml)

### Commands used in this lesson

```bash

# commit and push to your gitops repo
git add .; git commit -m "Add OpenTelemetry Collector with LGTM"; git push origin main

# OTHER HELPFUL COMMANDS

# Check if the Collector pod is running
kubectl get pods -n monitoring -l app.kubernetes.io/name=opentelemetry-collector

# Check the Collector service
kubectl get svc -n monitoring opentelemetry-collector

# View Collector logs
kubectl logs -n monitoring -l app.kubernetes.io/name=opentelemetry-collector -f

# Verify instrumentation is loaded
kubectl exec -it <ghost-pod> -- env | grep OTEL

# Test OTLP endpoint connectivity
kubectl exec -it <ghost-pod> -- wget -O- http://otel-collector.default.svc.cluster.local:4318

```


### RESOURCES

[https://invisibl.io/blog/kubernetes-observability-loki-cortex-tempo-prometheus-grafana/](https://invisibl.io/blog/kubernetes-observability-loki-cortex-tempo-prometheus-grafana/)

[https://last9.io/blog/opentelemetry-backends/](https://last9.io/blog/opentelemetry-backends/)

[https://github.com/magsther/awesome-opentelemetry](https://github.com/magsther/awesome-opentelemetry)

[https://grafana.com/oss/tempo/](https://grafana.com/oss/tempo/)

[https://signoz.io/blog/opentelemetry-backend/](https://signoz.io/blog/opentelemetry-backend/)

[https://grafana.com/blog/2023/07/28/simplify-managing-grafana-tempo-instances-in-kubernetes-with-the-tempo-operator/](https://grafana.com/blog/2023/07/28/simplify-managing-grafana-tempo-instances-in-kubernetes-with-the-tempo-operator/)

[https://odigos.io/blog/open-source-stack](https://odigos.io/blog/open-source-stack)

[https://www.civo.com/learn/distributed-tracing-kubernetes-grafana-tempo-opentelemetry](https://www.civo.com/learn/distributed-tracing-kubernetes-grafana-tempo-opentelemetry)

[https://n2x.io/docs/integrations-guides/observability/distributed-tracing/](https://n2x.io/docs/integrations-guides/observability/distributed-tracing/)

[https://last9.io/blog/loki-vs-prometheus/](https://last9.io/blog/loki-vs-prometheus/)

[https://grafana.com/docs/loki/latest/configure/storage/](https://grafana.com/docs/loki/latest/configure/storage/)

[https://grafana.com/docs/loki/latest/get-started/overview/](https://grafana.com/docs/loki/latest/get-started/overview/)

[https://www.reddit.com/r/PrometheusMonitoring/comments/qpzmgy/how_is_prometheus_involved_in_loki/](https://www.reddit.com/r/PrometheusMonitoring/comments/qpzmgy/how_is_prometheus_involved_in_loki/)

[https://www.reddit.com/r/devops/comments/154m1d2/what_observability_stack_would_you_recommend_for/](https://www.reddit.com/r/devops/comments/154m1d2/what_observability_stack_would_you_recommend_for/)

[https://uptrace.dev/blog/opentelemetry-backend](https://uptrace.dev/blog/opentelemetry-backend)

[https://signoz.io/comparisons/opentelemetry-vs-loki/](https://signoz.io/comparisons/opentelemetry-vs-loki/)

[https://overcast.blog/kubernetes-distributed-storage-backend-a-guide-0a0a437414b0](https://overcast.blog/kubernetes-distributed-storage-backend-a-guide-0a0a437414b0)

[https://opentelemetry.io/docs/concepts/components/](https://opentelemetry.io/docs/concepts/components/)

[https://www.reddit.com/r/grafana/comments/18ihd6h/how_big_is_the_lift_to_set_upmaintain_lgtm_oss/](https://www.reddit.com/r/grafana/comments/18ihd6h/how_big_is_the_lift_to_set_upmaintain_lgtm_oss/)

[https://www.reddit.com/r/OpenTelemetry/comments/1b18tbn/one_backend_for_all/](https://www.reddit.com/r/OpenTelemetry/comments/1b18tbn/one_backend_for_all/)