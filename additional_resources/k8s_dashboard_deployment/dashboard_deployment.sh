#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# These variables will be passed as environment variables from the GitHub Actions workflow
# K8S_NAMESPACE
# REMOTE_DASHBOARD_VALUES_PATH
# REMOTE_DASHBOARD_ADMIN_PATH

echo "--- Running on Jump Box: $(hostname) ---"
echo "Using Kubernetes Namespace: ${K8S_NAMESPACE}"
echo "Using dashboard values from: ${REMOTE_DASHBOARD_VALUES_PATH}"
echo "Using dashboard admin from: ${REMOTE_DASHBOARD_ADMIN_PATH}"

# Verify files exist on jump_box
if [ ! -f "${REMOTE_DASHBOARD_VALUES_PATH}" ]; then
  echo "ERROR: ${REMOTE_DASHBOARD_VALUES_PATH} not found on jump_box!"
  exit 1
fi
if [ ! -f "${REMOTE_DASHBOARD_ADMIN_PATH}" ]; then
  echo "ERROR: ${REMOTE_DASHBOARD_ADMIN_PATH} not found on jump_box!"
  exit 1
fi

# 1. Check/Install kubectl
echo "--- Checking/Installing kubectl ---"
if ! command -v kubectl &> /dev/null
then
    echo "kubectl not found. Installing kubectl..."
    if command -v apt-get &> /dev/null; then # Debian/Ubuntu
        sudo apt-get update -y && sudo apt-get install -y apt-transport-https ca-certificates curl
        K8S_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/${K8S_LATEST}/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
    elif command -v yum &> /dev/null; then # Amazon Linux 2 / CentOS / RHEL
        sudo yum update -y
        cat <<EOF_REPO | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF_REPO
        sudo yum install -y kubectl
    else
        echo "Unsupported package manager for kubectl installation on jump_box."
        exit 1
    fi
    echo "kubectl installed successfully."
    kubectl version --client
else
    echo "kubectl is already installed."
    kubectl version --client
fi

# 2. Check/Install Helm
echo "--- Checking/Installing Helm ---"
if ! command -v helm &> /dev/null
then
    echo "Helm not found. Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh && ./get_helm.sh && rm get_helm.sh # Ensure sudo if needed for install location
    echo "Helm installed successfully."
    helm version
else
    echo "Helm is already installed."
    helm version
fi

# 3. Deploy Kubernetes Dashboard using Helm
echo "--- Adding Kubernetes Dashboard Helm Repo ---"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ --force-update
helm repo update

echo "--- Installing/Upgrading Kubernetes Dashboard using ${REMOTE_DASHBOARD_VALUES_PATH} ---"
kubectl create namespace "${K8S_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace "${K8S_NAMESPACE}" \
  -f "${REMOTE_DASHBOARD_VALUES_PATH}" \
  --atomic \
  --timeout 10m0s \
  --wait

echo "--- Verifying Deployment ---"
kubectl get pods -n "${K8S_NAMESPACE}"
kubectl get svc kubernetes-dashboard -n "${K8S_NAMESPACE}"

echo "--- Applying admin configuration from ${REMOTE_DASHBOARD_ADMIN_PATH} ---"
kubectl apply -f "${REMOTE_DASHBOARD_ADMIN_PATH}" -n "${K8S_NAMESPACE}" # Specify namespace for apply too

echo "--- Kubernetes Dashboard Deployment Steps Completed on Jump Box ---"
echo "To get the admin token (if admin-user SA was defined in ${REMOTE_DASHBOARD_ADMIN_PATH} and matches 'admin-user' name):"
echo "kubectl create token admin-user -n ${K8S_NAMESPACE} --duration=8760h"
# Or for older K8s:
# echo "kubectl -n ${K8S_NAMESPACE} get secret \$(kubectl -n ${K8S_NAMESPACE} get sa/admin-user -o jsonpath=\"{.secrets[0].name}\") -o go-template=\"{{.data.token | base64decode}}\""

echo "--- Deployment script finished ---"
