# set env variables
resourceGroupName="week3-rg"
location="southcentralus"
deploymentName="week3-deploy"

# create resource group
az group create -n $resourceGroupName -l $location

# deploy the vms
az deployment group create \
-g $resourceGroupName \
-n $deploymentName \
--template-file kubeadm-two-node.json

# list public ip
az vm list-ip-addresses -g week2-rg | grep ipAddress