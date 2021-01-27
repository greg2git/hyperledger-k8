# Deploying Hyperledger Fabric on Kubernetes using Helm & Argo (with Fabric-CA instead of cryptogen)
* [Introduction](#intro) 
* [What is this?](#what-is-this)
* [Who made this?](#who-made-this)
* [License](#License)
* [Requirements](#requirements)
* [Network Architecture](#network-architecture)
* [Go over the samples](#go-over-samples)
  * [Launching the network](#launching-the-network)
  * [Creating channels](#creating-channels)
  * [Installing chaincodes](#installing-chaincodes)
  * [Scaled-up Kafka network](#scaled-up-kafka-network)
  * [Scaled-up Raft network](#scaled-up-raft-network)
  * [Adding new peer organizations](#adding-new-peer-organizations)
  * [Adding new peers to organizations](#adding-new-peers-to-organizations)
* [Configuration](#configuration)
* [TLS](#tls)
* [Backup-Restore](#backup-restore)
  * [Requirements](#backup-restore-requirements)
  * [Flow](#backup-restore-flow)
  * [Backup](#backup)
  * [Restore](#restore)
* [Limitations](#limitations)
* [Conclusion](#conclusion)

## [Introduction](#intro) 
This repository is a fork of https://github.com/APGGroeiFabriek/PIVT. I have done changes to use Fabric CA to generate certificates and private keys than using cryptogen (not recommended for production) and migrate to the new LTS HLF 2.x.x
## [What is this?](#what-is-this)
This repository contains a couple of Helm charts to:
* Configure and launch the whole HL Fabric network
* Register identities with Fabric CA and generate necessary artifacts to setup up blockchain network

## [Who made this?](#who-made-this)
This is a fork of https://github.com/APGGroeiFabriek/PIVT. Additional customizations are done to use Fabric CA to generate certificates and private keys than using cryptogen

## [License](#License)
This work is licensed under the same license with HL Fabric; [Apache License 2.0](LICENSE).

## [Requirements](#requirements)
* A running Kubernetes cluster, developed with with AKS v1.13 . Minikube should also work, but not tested
* [MiniKube](https://minikube.sigs.k8s.io/docs/start/), 
* [Helm](https://github.com/helm/helm/releases/tag/v2.17.0), developed with 2.17.0, newer 2.xx versions should also work
* [jq](https://stedolan.github.io/jq/download/) 1.6+ and 
* [yq](https://pypi.org/project/yq/) 2.6+
* [Argo](https://github.com/argoproj/argo/blob/master/demo.md), both CLI and Controller
* [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) to store crypto data and generated assets – Locally we use NFS server running on K8s
* [nfs-server-provisioner](https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner) Helm Chart to start custom PV and connect it with the NFS server. 
* Run all the commands in *fabric-kube* folder
* nfs-server-provisioner chart is set as deprecated, you need to add this to your helm registry: `helm repo add stable https://charts.helm.sh/stable`  

Most components should be installed by running the `./bootstrap.sh` script, it uses *brew* as the package manager so if you run this on non osx systems you need to use a different dedicated tool and install the components manually. 

### [Launching The Network](#launching-the-network)
First install chart dependencies, you need to do this only once:
`./install_components.sh`

Initialize the network and start CA server
```
./init.sh amvox-k8s amvox-k8s/
helm install ./hlf-init-kube --name hlf-init-kube -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml -f amvox-k8s/vault.yaml
```
This script:
* creates PVC for all organizations (Orderer/Peer) , CA’s and peers/hosts associated to those organizations 
* Start Fabric CA for each organization configured in crypto-config.yaml

Wait for all pods are up and running:
```
kubectl get pod --watch
```
### Register Identities with Fabric CA and generate artifacts
```
helm template artifacts-flow/ -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml | argo submit - --watch
```
Now, we are ready to launch the network:
```
helm install ./hlf-kube --name hlf-kube -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false

./collect_host_aliases.sh amvox-k8s

helm upgrade hlf-kube ./hlf-kube -f amvox-k8s/network.yaml -f amvox-k8s/crypto-config.yaml -f amvox-k8s/hostAliases.yaml
```
This part creates all the above mentioned secrets, pods, services, mount required persistent volume claims, etc. cross configures them 
and launches the network in unpopulated state. Retrives the IP addresses from the created pods and then updates the existing infrastructure, so the services can communicate with each other.


### Current problem 
1. The Orderer is not able to starup. 
if you will run: 
```
kubectl logs hlf-orderer--amvoxdlt--orderer0-0 orderer
```
You should see something of the following error: 
```
[orderer.common.server] Main -> PANI 113 Failed validating bootstrap block: initializing channelconfig failed: could not create channel Orderer sub-group config: setting up the MSP manager failed: administrators must be declared when no admin ou classification is set
panic: Failed validating bootstrap block: initializing channelconfig failed: could not create channel Orderer sub-group config: setting up the MSP manager failed: administrators must be declared when no admin ou classification is set

```

-----------

How to tear down everything?
```
./clean.sh
```
Wait a bit until all pods are terminated:
```
kubectl  get pod --watch
```

