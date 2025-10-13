## The Why and How of Kubernetes

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch/edit-lesson/sections/761976/lessons/2889184)

### Kubernetes Components
- [https://kubernetes.io/docs/concepts/overview/components/](https://kubernetes.io/docs/concepts/overview/components/)

### Killercoda Lab Environment
- [https://killercoda.com/](https://killercoda.com)

### GitHub Repsitory Used in this Course
- [https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)

### Commands used in this lesson

```bash
# list the nodes in your Kubernetes cluster
kubectl get nodes

# list the pods in the kube-system namespace
kubectl -n kube-system get pods

# see which node the pod is running on
kubectl -n kube-system get pods -o wide
```

---

Go to the next lesson

[Go back to section 00](README.md)