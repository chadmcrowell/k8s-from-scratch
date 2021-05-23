# install the containerd runtime
sudo apt-get install containerd -y

# Configure containerd and start the service
sudo mkdir -p /etc/containerd
sudo su -
containerd config default  /etc/containerd/config.toml

