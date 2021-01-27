#!/bin/bash

## Once per Mini Kube install
./install_components.sh

./install_nginx-ingress.sh

## Locally use nfs-server-provisioner
helm install stable/nfs-server-provisioner --name nfs-provisioner -f amvox-k8s/nfs_provisioner.yaml


## Every Time
./init.sh amvox-k8s amvox-k8s/
./prepare_chaincodes.sh amvox-k8s amvox-k8s/

helm install ./hlf-init-kube --name hlf-init-kube -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml -f amvox-k8s/vault.yaml | kubectl get pods --watch

helm template artifacts-flow/ -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml | argo submit - --watch

echo 'Install Helm Chart -> Hyperledger Cluster'
helm install ./hlf-kube --name hlf-kube -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false

./collect_host_aliases.sh amvox-k8s

echo 'Update Cluster with peers and order(s) host addresses'
helm upgrade hlf-kube ./hlf-kube -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml -f amvox-k8s/hostAliases.yaml

echo 'Create channel and join all Organizations to it'
helm template channel-flow/ -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml -f amvox-k8s/hostAliases.yaml | argo submit - --watch

#helm template chaincode-flow/ -f amvox-k8s/network.yaml -f amvox-k8s/crypto-orderer_node_ou-config.yaml -f amvox-k8s/hostAliases.yaml | argo submit - --watch

helm install ./hlf-init-nfs --name hlf-init-nfs -f amvox-k8s/vault.yaml
helm upgrade hlf-init-nfs ./hlf-init-nfs -f amvox-k8s/vault.yaml