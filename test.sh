#!/usr/bin/bash
minikube_ip=$(minikube service ingress-nginx-controller --url -n ingress-nginx | head -n 1)
for i in $(seq 1 10); do curl $minikube_ip; done
