# Using a sidecar container to collect logs from two separate streams in Kubernetes

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
sudo apt-get install -y kubelet=1.20.2-00 kubeadm=1.20.2-00 kubectl=1.20.2-00

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

