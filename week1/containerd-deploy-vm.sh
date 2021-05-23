# set env variables
resourceGroupName="containerd-rg"
location="southcentralus"
deploymentName="vm-deploy"

# download template
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/main/week1/containerd-single-node.json -O template.json

# create resource group
az group create -n $resourceGroupName -l $location

# deploy the vms
az deployment group create \
-g $resourceGroupName \
-n $deploymentName \
--template-file template.json

# list public ip
az vm list-ip-addresses -g containerd-rg | grep ipAddress