adminUsername="azureuser"
adminPassword=$(openssl rand -base64 16)

wget https://gist.githubusercontent.com/chadmcrowell/441058e5fd9379b64b7c875b521564f5/raw/0db25244f66f99af3bf24f812cb537635d15f295/ubuntu-microk8s.json-O template.json