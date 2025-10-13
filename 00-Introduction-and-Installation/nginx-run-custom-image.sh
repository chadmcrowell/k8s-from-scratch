# go to https://labs.play-with-k8s.com

# create a new instance and follow the instructions to initialize the cluster

# view the noSchedule taint
kubectl describe node controplane | grep Taints

# remove the noSchedule taint
kubectl taint no controlplane node-role.kubernetes.io/master:NoSchedule-

# create a deployment with your custom image
kubectl create deploy custom --image chadmcrowell/nginx-custom:latest

# describe why pod is not running
kubectl describe po

# create a service
kubectl expose deploy custom --type=NodePort --port=80 --name=custom-service

# get services
kubectl get svc

# curl the service address
curl http://<ip address of service>

