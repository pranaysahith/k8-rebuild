#!/bin/bash

# This is a placeholder script, you can move your setup script here to install some custom deployment on the VM
# The parent directory of this script will be transferred with its content to the VM under /tmp/setup path
# (i.e: useful for copying configs, scripts, systemd units, etc..)  

# install k3s
curl -sfL https://get.k3s.io | sh -

# install kubectl and helm
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo "Done installing kubectl"

# curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
# echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
# sudo apt-get update
# sudo DEBIAN_FRONTEND=noninteractive apt-get install helm -y
curl -sfL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
echo "Done installing helm"

# install helm chart
git clone https://github.com/k8-proxy/k8-rebuild.git --recursive && cd k8-rebuild && git submodule foreach git pull origin main
mkdir ~/.kube && sudo install -T /etc/rancher/k3s/k3s.yaml ~/.kube/config -m 600 -o $USER
# let k3s cluster is ready
sleep 60s
helm upgrade --install sow-rest kubernetes/
# let helm chart be installed
sleep 60s