#!/bin/bash
# join-worker-node.sh: Joins a worker node to an existing Kubernetes cluster.

set -euxo pipefail

echo "Starting Worker Node Join Process..."

# Ensure prepare-node.sh has been run successfully on this node.

echo ""
echo "This script will join the current node as a worker to your Kubernetes cluster."
echo "You need the 'kubeadm join' command that was outputted when you initialized the control plane."
echo "It looks something like: "
echo "  sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
echo ""

# Prompt the user for the join command
read -p "Please paste the full 'kubeadm join' command here and press [ENTER]: " KUBEADM_JOIN_COMMAND

# Validate that some input was given
if [[ -z "$KUBEADM_JOIN_COMMAND" ]]; then
  echo "Error: No 'kubeadm join' command was entered. Exiting."
  exit 1
fi

# Ensure the command starts with 'sudo kubeadm join' for basic validation
if [[ ! "$KUBEADM_JOIN_COMMAND" == sudo\ kubeadm\ join* ]]; then
    echo "Warning: The command entered does not look like a standard 'sudo kubeadm join ...' command."
    read -p "Are you sure you want to proceed? (yes/no): " confirmation
    if [[ "$confirmation" != "yes" ]]; then
        echo "Exiting without joining."
        exit 1
    fi
fi

# Append --cri-socket if not already present, as we are using containerd
# kubeadm should detect this, but being explicit can avoid issues.
if [[ ! "$KUBEADM_JOIN_COMMAND" == *"--cri-socket"* ]]; then
  # Check if there are other options after the hash already
  if [[ "$KUBEADM_JOIN_COMMAND" == *--* && ! "$KUBEADM_JOIN_COMMAND" == *--discovery-token-ca-cert-hash\ sha256:[0-9a-f]*\ --* ]]; then
    # If there are no options after the hash, just append
    KUBEADM_JOIN_COMMAND="${KUBEADM_JOIN_COMMAND} --cri-socket unix:///var/run/containerd/containerd.sock"
  else
    # If there are options after the hash, this logic might need to be smarter,
    # but for now, we'll just append. This might be an edge case.
    # A more robust way would be to parse options properly.
    echo "Note: Appending --cri-socket. Please verify the final command structure if other options were present."
    KUBEADM_JOIN_COMMAND="${KUBEADM_JOIN_COMMAND} --cri-socket unix:///var/run/containerd/containerd.sock"
  fi
fi

echo ""
echo "The following command will be executed to join the cluster:"
echo "  ${KUBEADM_JOIN_COMMAND}"
echo ""
read -p "Confirm to proceed? (yes/no): " CONFIRM_JOIN

if [[ "$CONFIRM_JOIN" != "yes" ]]; then
  echo "Join process aborted by user."
  exit 0
fi

# Execute the join command
echo "Attempting to join the Kubernetes cluster..."
eval "${KUBEADM_JOIN_COMMAND}" # Using eval because the command is provided as a string with sudo

echo ""
echo "Worker node join process has been initiated."
echo "On the control-plane node, you can verify the new node by running 'kubectl get nodes' after a few moments."
echo "It may take a minute or two for the node to appear and become 'Ready'."
