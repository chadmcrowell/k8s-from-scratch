# add k8s repository GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

# add k8s repository
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# install kubelet, kubeadm and kubectl
sudo apt-get install -y kubelet=1.20.2-00 kubeadm=1.20.2-00 kubectl=1.20.2-00

# enable bridge networking
sudo vi /etc/sysctl.conf

# add the following at the bottom
net.bridge.bridge-nf-call-iptables = 1

# enable ip forwarding
sudo -s
sudo echo '1' > /proc/sys/net/ipv4/ip_forward

# Reload the configurations
sudo sysctl --system

# load modules for storage overlay and packet filter
sudo modprobe overlay
sudo modprobe br_netfilter

# disable swap
sudo swapoff -a

# pull containers for kubeadm
sudo kubeadm config images pull

# initialize the cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# set config and permissions
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install flannel 
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# view the taints
kubectl get nodes -o=custom-columns=NODE:.metadata.name,KEY:.spec.taints[*].key,VALUE:.spec.taints[*].value,EFFECT:.spec.taints[*].effect

# untaint the node
kubectl taint no containerdvm node-role.kubernetes.io/master:NoSchedule-

# create a deployment
kubectl create deploy connector --image gcr.io/google-samples/kubernetes-bootcamp:v1

# poke a hole into the cluster and open a new tab
kubectl proxy

# curl localhost
curl http://localhost:8001/version

# get the pod name
kubectl get po

# access the pod from outside the cluster
curl http://localhost:8001/api/v1/namespaces/default/pods/connector-5b6c6d8d55-p6rjf