# set env variables
resourceGroupName="kubeadm-rg"
location="westus"
deploymentName="vm-deploy"

# download template
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/main/week1/kubeadm-cluster-deploy.json -O template.json

# create resource group
az group create -n $resourceGroupName -l $location

# deploy the vms
az deployment group create \
-g $resourceGroupName \
-n $deploymentName \
--template-file template.json

# list public ip
az vm list-ip-addresses -g kubeadm-rg | grep ipAddress

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the Docker stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Add Kubernetes gpg key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add Kubernetes stable repository
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update the apt package index
sudo apt-get update

# Install the 19.03.4 version of Docker Engine - Community
sudo apt-get install -y containerd.io docker-ce=5:20.10.6~3-0~ubuntu-$(lsb_release -cs)

# Install kubelet, kubeadm and kubectl packages
sudo apt-get install -y kubelet=1.19.9-00 kubeadm=1.19.9-00 kubectl=1.19.9-00

# hold at current versions
sudo apt-mark hold kubelet kubeadm kubectl

# initialize the cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# set config and permissions
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install flannel 
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubeadm join 10.0.0.4:6443 --token idlg06.76ygj6afeta8u4ls \
    --discovery-token-ca-cert-hash sha256:1d1ac1fca599e37e8f7065e3fd9561f67d12545924abba9871dedca21bff2d69

kubectl run nginx --image=nginx

kubectl get po -o wide

kubectl run curlpod --image=nicolaka/netshoot --rm -it -- sh

# curl 10.244.220.65

