# download the yml
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/main/week1/sidecar-pod.yml

# (OPTIONAL)remove taint from controller node
# kubectl taint no node1 node-role.kubernetes.io/master:NoSchedule-

# deploy the pod
kubectl create -f sidecar-pod.yml

# access logs from the first container
kubectl logs counter count-log-1

# access logs from the second container
kubectl logs counter count-log-2

