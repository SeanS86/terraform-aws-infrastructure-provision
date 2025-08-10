#!/bin/bash
# initialize-control-plane.sh: Initializes the Kubernetes control plane using kubeadm.

set -euxo pipefail

echo "Starting Kubernetes Control-Plane Initialization..."

# Ensure prepare-node.sh has been run successfully on this node.

# 1. Define Network Configuration
#    Ensure this Pod Network CIDR does NOT overlap with your VPC CIDR (e.g., 172.18.0.0/16)
#    Or any other network ranges your nodes might need to communicate with.
POD_NETWORK_CIDR="192.168.0.0/16" # Default for Calico, adjust if using another CNI or different range
echo "Using Pod Network CIDR: ${POD_NETWORK_CIDR}"

# 2. Determine the Control Plane Node's Private IP Address
#    This IP is used for the API server to advertise itself to other members of the cluster.
#    This command assumes the primary private IP is the correct one. Verify for your environment.
CONTROL_PLANE_PRIVATE_IP=$(hostname -I | awk '{print $1}')
if [ -z "${CONTROL_PLANE_PRIVATE_IP}" ]; then
    echo "Error: Could not determine Control Plane Private IP."
    exit 1
fi
echo "Control Plane Advertise IP: ${CONTROL_PLANE_PRIVATE_IP}"

# 3. (Optional but Recommended) Pull required Kubernetes images beforehand
echo "Pulling required Kubernetes images for control plane..."
sudo kubeadm config images pull --cri-socket unix:///var/run/containerd/containerd.sock

# 4. Initialize the Kubernetes Control Plane
#    --kubernetes-version can be omitted to use the version of kubeadm itself,
#    but specifying it explicitly (matching the installed version) is good practice.
K8S_VERSION_SHORT=$(kubeadm version -o short) # Gets something like v1.29.1
echo "Initializing Kubernetes control plane (version ${K8S_VERSION_SHORT})..."
sudo kubeadm init \
  --pod-network-cidr="${POD_NETWORK_CIDR}" \
  --apiserver-advertise-address="${CONTROL_PLANE_PRIVATE_IP}" \
  --cri-socket unix:///var/run/containerd/containerd.sock \
  --kubernetes-version "${K8S_VERSION_SHORT}"
  # Add --upload-certs if you plan to add more control plane nodes later (for HA)

# 5. Set up kubectl access for the current non-root user (e.g., 'ubuntu')
echo "Setting up kubectl access for the '$(whoami)' user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config # Set for current session
echo "kubectl configuration copied to $HOME/.kube/config"
echo "You may need to run 'export KUBECONFIG=\$HOME/.kube/config' in new shells or add it to your .bashrc/.zshrc"

# 6. (CRITICAL) Display and instruct to save the `kubeadm join` command
echo ""
echo "----------------------------------------------------------------------------------------------------"
echo "IMPORTANT: The Kubernetes control plane has been initialized."
echo "To join worker nodes to this cluster, run the following command on each worker node:"
echo "(This command is also saved in the output of 'kubeadm init' above)"
echo ""
# The join command is typically the last significant output of 'kubeadm init'
# This is a placeholder; the actual command will be shown by kubeadm init itself.
echo "Example: sudo kubeadm join ${CONTROL_PLANE_PRIVATE_IP}:6443 --token <your_token> \\"
echo "              --discovery-token-ca-cert-hash sha256:<your_ca_cert_hash>"
echo ""
echo "PLEASE COPY THE EXACT 'kubeadm join ...' COMMAND FROM THE OUTPUT ABOVE THIS MESSAGE."
echo "----------------------------------------------------------------------------------------------------"
echo ""

# 7. Install a Pod Network Add-on (CNI Plugin - e.g., Calico)
#    The cluster will not be fully functional (e.g. CoreDNS won't start) until a CNI is installed.
echo "Installing Calico Pod Network Add-on..."
# Ensure kubectl is using the correct config (should be, due to export above)
# Refer to Calico's official documentation for the latest manifest URL and recommended version.
CALICO_VERSION="v3.27.0" # Example version, check for latest stable for your K8s version
echo "Applying Calico manifest (version ${CALICO_VERSION})..."
kubectl apply -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml"

echo "Calico installation initiated."
echo "Wait for Calico and CoreDNS pods in 'kube-system' namespace to be in 'Running' state."
echo "You can check with: kubectl get pods -n kube-system -w"
echo ""
echo "Control-Plane Initialization Complete."
echo "You can now join worker nodes using the 'kubeadm join' command that was printed."
