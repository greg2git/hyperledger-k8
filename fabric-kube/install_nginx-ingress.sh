#!/bin/bash

echo '-- Waiting 5 second before attempt to install nginx-ingress controllers for Amvxox CA, Orderer Service and Organization Peer(s)'
sleep 5

helm install stable/nginx-ingress --name hlf-ca-ingress --namespace kube-system --set controller.service.type=LoadBalancer --set controller.ingressClass=hlf-ca --set controller.service.ports.https=7054 --set controller.service.enableHttp=false --set controller.extraArgs.enable-ssl-passthrough=''
helm install stable/nginx-ingress --name hlf-peer-ingress --namespace kube-system --set controller.service.type=LoadBalancer --set controller.ingressClass=hlf-peer --set controller.service.ports.https=7051 --set controller.service.enableHttp=false --set controller.extraArgs.enable-ssl-passthrough=''
helm install stable/nginx-ingress --name hlf-orderer-ingress  --namespace kube-system --set controller.service.type=LoadBalancer --set controller.ingressClass=hlf-orderer --set controller.service.ports.https=7050 --set controller.service.enableHttp=false --set controller.extraArgs.enable-ssl-passthrough=''

echo 'Patching ConfigMap so the NGInx Controller can forward TCP connections to dedicated tcp services'
kubectl patch configmap tcp-services -n kube-system --patch '{"data":{"7054":"default/hlf-ca--amvox:7054"}}'
kubectl patch configmap tcp-services -n kube-system --patch '{"data":{"7051":"default/hlf-peer--amvox--peer0:7051"}}'
kubectl patch configmap tcp-services -n kube-system --patch '{"data":{"7050":"default/hlf-orderer--amvoxdlt--orderer0:7050"}}'

kubectl get configmap tcp-services -n kube-system -o json

echo 'Deploy updated ingress-nginx-controller with patch to forward the configured tcp ports to ingress backends'

kubectl patch deployment ingress-nginx-controller --patch "$(cat nginx-ingress-controller.yaml)" -n kube-system


echo '-- List NGINX Ingress service'
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx


echo '-- List NGINX Ingress Controllers'
kubectl -n kube-system get svc -l app=nginx-ingress,component=controller