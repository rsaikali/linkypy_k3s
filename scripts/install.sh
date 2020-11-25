#!/bin/bash -e

source ./config.sh
source ./functions.sh

echo "###############################################################################"
echo "                                  WARNING"
echo "###############################################################################"
echo "This will install k3s on $K3S_NODES !!!"
read -n 1 -s -r -p "Press any key to continue or Ctrl-C to exit"

###############################################################################
# INSTALL K3S ON ALL RASPBERRYs
###############################################################################
for i in "${!K3S_NODES[@]}" ; do

    K3S_IP=${K3S_NODES[i]}
    K3S_NAME=${K3S_NAMES[i]}

    prepare_raspberry $K3S_IP $K3S_NAME

    if (( $i == 0 )) ; then
        echo "--------------------------------------------------------------------------------"
        echo "k3sup install $K3S_IP"
        echo "--------------------------------------------------------------------------------"
        k3sup install --ip $K3S_IP --user pi
    else
        echo "--------------------------------------------------------------------------------"
        echo "k3sup join $K3S_IP"
        echo "--------------------------------------------------------------------------------"
        k3sup join --ip $K3S_IP --server-ip ${K3S_NODES[0]} --user pi
    fi
done

###############################################################################
# INSTALL kubernetes-dashboard
###############################################################################
arkade install kubernetes-dashboard

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
---
EOF
