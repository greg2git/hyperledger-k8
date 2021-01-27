#!/bin/bash

argo delete --all
helm delete hlf-init-kube --purge
helm delete hlf-kube --purge
#minikube stop