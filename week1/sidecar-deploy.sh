# download the yml
wget https://yaml.com/fsi/six/fee

# deploy the pod
kubectl create -f sidecar-pod.yml

# access logs from the first container
kubectl logs counter count-log-1

# access logs from the second container
kubectl logs counter count-log-2

