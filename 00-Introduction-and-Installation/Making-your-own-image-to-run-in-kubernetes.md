## Make Your Own Image to Run in Kubernetes

[Access this lesson](https://community.kubeskills.com/c/kubernetes-from-scratch)

---

### GitHub Repository

[https://github.com/chadmcrowell/k8s-from-scratch](https://github.com/chadmcrowell/k8s-from-scratch)


### Commands used in this lesson

```bash
# make a new directory & change into that directory
mkdir -p working && cd working

# pull down the image from dockerhub
docker pull nginx:latest

# list the images
docker images

# download the index.html file
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/refs/heads/main/0-Introduction-and-Installation/index.html

# download the Dockerfile
wget https://raw.githubusercontent.com/chadmcrowell/k8s-from-scratch/refs/heads/main/0-Introduction-and-Installation/Dockerfile

# build the container image
docker build -t chadmcrowell/nginx-custom:v1 .

# list the images
docker images

# push the image to dockerhub
docker push chadmcrowell/nginx-custom:v1

# create deployment in Kubernetes
kubectl create deploy custom --image chadmcrowell/nginx-custom:v1

# create a NodePort type service
kubectl expose deploy custom --type NodePort --port 80

# list pods
kubectl get pods

# list services (get node port)
kubectl get svc
```

---

[Next Lesson](boostrap-cluster-with-kubeadm-on-any-cloud.md)

[Section 00 - Introduction and Installation](README.md)