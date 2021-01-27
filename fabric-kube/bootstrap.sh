#!/bin/bash

echo '-- Downloading HyperLedger Fabric binaries and 3-party binaries (2.2.1 and HLF-CA: 1.4.9)'
curl -sSL https://bit.ly/2ysbOFE | bash -s -- -d -s 2.2.1 1.4.9

echo '-- installing command-line tools: Helm v2, jq and yq (Python,pip3 required)'
brew install helm@2
brew install jq
pip3 install yq


echo '-- Downloading and installing Argo CLI binaries and moving them to user /usr/local/bin/argo directory...'
# Install Argo CLI
# Download the binary
curl -sLO https://github.com/argoproj/argo/releases/download/v2.11.7/argo-darwin-amd64.gz

# Unzip
gunzip argo-darwin-amd64.gz

# Make binary executable
chmod +x argo-darwin-amd64

# Move binary to path
mv ./argo-darwin-amd64 /usr/local/bin/argo

# Test installation
argo version

#minikube
brew install hyperkit minikube

minikube start --vm=true --driver=hyperkit --cpus 8 --memory 8192

# If running on minikube enable ingress!
minikube addons enable ingress

# update Service Account to use default namespace:
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default

docker build -t amvox-tools/fabric-tools:2.2.1 docker/fabric-tools/.