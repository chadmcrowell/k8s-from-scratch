# download the template
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/main/week1/containerd-single-node.json -O template.json

# set env variables
resourceGroupName="sidecar-rg"
location="southcentralus"
deploymentName="sidecar-deploy"

# create resource group
az group create -n $resourceGroupName -l $location

# deploy the vms
az deployment group create \
-g $resourceGroupName \
-n $deploymentName \
--template-file template.json

# list public ip
az vm list-ip-addresses -g containerd-rg | grep ipAddress

# download the yml
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/main/week1/sidecar-pod.yml

# remove taint from controller node
kubectl taint no node1 node-role.kubernetes.io/master:NoSchedule-

# deploy the pod
kubectl create -f sidecar-pod.yml

# access logs from the first container
kubectl logs counter count-log-1

# access logs from the second container
kubectl logs counter count-log-2

