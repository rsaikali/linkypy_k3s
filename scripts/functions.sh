#!/bin/bash -e

################################################################################
# Basic RaspberryPi setup
prepare_raspberry() {

    # Parameters
    local NODE_IP=$1
    local NODE_NAME=$2

    # SSH copy id
    ssh-keygen -R $NODE_IP
    while ! sshpass -p "raspberry" ssh-copy-id -o StrictHostKeyChecking=no -o ConnectTimeout=10 pi@$NODE_IP 2>/dev/null; do
        echo "Cannot SSH on $NODE_IP. Retrying in 10s..."
        sleep 1
    done;
    echo "SSH is UP on $NODE_IP"

    # Upgrade packages
    echo "--------------------------------------------------------------------------------"
    echo "apt-get update"
    echo "--------------------------------------------------------------------------------"
    ssh pi@$NODE_IP sudo apt-get -q update
    echo "--------------------------------------------------------------------------------"
    echo "apt-get upgrade"
    echo "--------------------------------------------------------------------------------"
    ssh pi@$NODE_IP sudo apt-get -q --no-install-recommends -y upgrade

    # Disable swap
    ssh pi@$NODE_IP sudo swapoff /var/swap
    ssh pi@$NODE_IP sudo systemctl disable dphys-swapfile
    ssh pi@$NODE_IP sudo rm -f /var/swap

    # Set timezone
    echo "--------------------------------------------------------------------------------"
    echo "Timezone settings"
    echo "--------------------------------------------------------------------------------"
    ssh pi@$NODE_IP sudo rm -Rf /etc/localtime
    ssh pi@$NODE_IP sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
    ssh pi@$NODE_IP sudo rm -Rf /etc/timezone
    ssh pi@$NODE_IP "echo 'Europe/Paris' | sudo tee /etc/timezone"

    # Set hostname
    echo "--------------------------------------------------------------------------------"
    echo "Hostname settings"
    echo "--------------------------------------------------------------------------------"
    ssh pi@$NODE_IP sudo sed -i "s/raspberrypi/$NODE_NAME/g" /etc/hostname
    ssh pi@$NODE_IP sudo sed -i "s/raspberrypi/$NODE_NAME/g" /etc/hosts

    # cgroups for k3s
    echo "--------------------------------------------------------------------------------"
    echo "CGroups settings"
    echo "--------------------------------------------------------------------------------"
    ssh pi@$NODE_IP sudo sed -i "s/rootwait/cgroup_enable=cpuset\ cgroup_memory=1\ cgroup_enable=memory\ quiet rootwait/g" /boot/cmdline.txt

    # Reboot
    echo "--------------------------------------------------------------------------------"
    echo "Reboot"
    echo "--------------------------------------------------------------------------------"
    ssh pi@$NODE_IP sudo reboot || true
    sleep 5

    # Wait for reboot and SSH is up
    while ! ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 pi@$NODE_IP exit 2>/dev/null; do
        echo "Cannot SSH on $NODE_IP. Retrying in 10s..."
        sleep 1
    done;
    echo "SSH is UP on $NODE_IP"

    return 0
}