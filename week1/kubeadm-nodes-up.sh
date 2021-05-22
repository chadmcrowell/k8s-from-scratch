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