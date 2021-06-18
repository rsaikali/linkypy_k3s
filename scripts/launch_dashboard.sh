#!/bin/bash

token=`kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user-token | awk '{print $1}') | egrep '^token' | tr -s ' ' | cut -d' ' -f2`
echo "###############################################################################"
echo "# AUTHENTICATE WITH TOKEN (copied to clipboard):"
echo "#------------------------------------------------------------------------------"
echo $token
echo $token | pbcopy
echo "###############################################################################"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview"
kubectl proxy

