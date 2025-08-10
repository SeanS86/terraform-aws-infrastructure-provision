#!/bin/bash
# prepare-node.sh: Prepares a node for Kubernetes installation (kubeadm)

set -euxo pipefail # Exit on error, print commands, error on unset variables, pipefail

echo "Starting Node Preparation for Kubernetes..."

# 0. System Update and Prerequisite Packages
echo "Updating package list and installing prerequisite packages..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    conntrack # Required by kube-proxy, often missed

# 1. Disable Swap (Kubernetes requirement)
echo "Disabling swap..."
sudo swapoff -a
# Persistently disable swap by commenting it out in /etc/fstab
if [ $(grep -c 'swap' /etc/fstab) -gt 0 ]; then
    sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    echo "Swap entry in /etc/fstab commented out."
else
    echo "No swap entry found in /etc/fstab or already commented."
fi

# 2. Configure Kernel Modules and Parameters for Kubernetes Networking
echo "Configuring kernel modules (overlay, br_netfilter)..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "Configuring sysctl parameters for Kubernetes networking..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters without reboot
sudo sysctl --system
echo "Kernel parameters applied."

# 3. Install Container Runtime (containerd)
echo "Installing containerd..."
# Add Docker's official GPG key (containerd is often packaged with Docker)
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install containerd.io package
sudo apt-get install -y containerd.io

# Configure containerd to use systemd cgroup driver (required by kubelet)
echo "Configuring containerd to use systemd cgroup driver..."
sudo mkdir -p /etc/containerd
# Generate default config and then modify it
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart and enable containerd service
sudo systemctl restart containerd
sudo systemctl enable containerd
echo "Containerd installed and configured."

# 4. Install Kubernetes Components: kubeadm, kubelet, kubectl
echo "Installing Kubernetes components (kubeadm, kubelet, kubectl)..."
# Define Kubernetes version - check for the latest patch for your chosen minor version
# Example: For Kubernetes 1.29.x, find the latest 1.29.Y
K8S_MINOR_VERSION="v1.29" # Change if using a different minor version
K8S_FULL_VERSION="1.29.1-1.1"  # Example: Specify exact version for kubelet, kubeadm, kubectl.
                               # Check available versions with: apt-cache madison kubeadm

# Add Kubernetes GPG key
# Note: The URL might change for different K8s versions. Check official docs.
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
# Install specific versions to ensure consistency across the cluster
sudo apt-get install -y kubelet=${K8S_FULL_VERSION} kubeadm=${K8S_FULL_VERSION} kubectl=${K8S_FULL_VERSION}
# Hold packages to prevent accidental upgrades
sudo apt-mark hold kubelet kubeadm kubectl
echo "Kubernetes components (kubelet, kubeadm, kubectl) version ${K8S_FULL_VERSION} installed and held."

# Enable and start kubelet service
sudo systemctl enable --now kubelet
echo "kubelet service enabled and started."

echo "Node Preparation Complete."
echo "Consider rebooting the node if you encounter issues, though often not strictly necessary."
# sudo reboot
