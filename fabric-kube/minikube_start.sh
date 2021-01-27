#!/bin/bash
minikube start --vm=true --driver=hyperkit --cpus 8 --memory 8192

# If running on minikube enable ingress!
minikube addons enable ingress

# update Service Account to use default namespace:
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default
