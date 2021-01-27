#!/bin/bash

echo '-- MiniKube Initializing'
#minikube start

echo '-------'
echo '-- Helm Initialize in K8s, setting up Tiller...'
helm init

echo '-- Creating new namespace for Argo Workflow'
kubectl create namespace argo

echo '-- Installing all Argo components (with controller)'
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml

echo '-- Installing NGInx ingress (Local) Controller. For AWS EKS different needs to be installed!'

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.0/deploy/static/provider/cloud/deploy.yaml

#AWS EKS Ingress Controller
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.0/deploy/static/provider/aws/deploy.yaml


echo '-- Installing NFS Data Dynamic provisioning'
helm install stable/nfs-server-provisioner --name nfs-provisioner -f amvox-k8s/nfs_provisioner.yaml