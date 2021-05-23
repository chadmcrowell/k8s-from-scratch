# pull the nginx image
docker pull nginx

# create a basic index.html page
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Custom Nginx</title>
</head>
<body>
  <h2>Congrats!! You\'ve created a custom container image and deployed it to Kubernetes!!</h2>
</body>
</html>

# create a Dockerfile
FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html

# build and tag our new image
docker build -t chadmcrowell/nginx-custom:v1 .

# push the image to docker registry
docker push chadmcrowell/nginx-custom:v1



