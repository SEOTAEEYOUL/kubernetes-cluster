#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm pull ingress-nginx/ingress-nginx --untar
cd ingress-nginx
helm install ingress-nginx . -f values.yaml --namespace ingress-nginx --create-namespace
cd ..