# Manual Kubernetes Cluster Deployment on AWS EC2

This document outlines the steps taken to manually deploy a Kubernetes cluster (using `kubeadm`) on EC2 instances provisioned in private subnets within AWS. The cluster consists of one control-plane node and one worker node.

**Orchestration Tool Choice:** `kubeadm`

## Table of Contents

1.  [Prerequisites](#prerequisites)
2.  [Overview of Deployment Phases](#overview-of-deployment-phases)
3.  [Shell Scripts Used](#shell-scripts-used)
4.  [Phase 1: Prepare All Nodes (Control-Plane & Worker)](#phase-1-prepare-all-nodes-control-plane--worker)
    *   [Script: `prepare-node.sh`](#script-prepare-nodesh)
    *   [Execution](#execution-prepare)
5.  [Phase 2: Initialize Control-Plane Node](#phase-2-initialize-control-plane-node)
    *   [Script: `initialize-control-plane.sh`](#script-initialize-control-planesh)
    *   [Execution](#execution-control-plane)
6.  [Phase 3: Join Worker Node to Cluster](#phase-3-join-worker-node-to-cluster)
    *   [Script: `join-worker-node.sh`](#script-join-worker-nodesh)
    *   [Execution](#execution-worker)
7.  [Phase 4: Verify Cluster & Install Metrics Server](#phase-4-verify-cluster--install-metrics-server)
    *   [Configuring `kubectl` Access](#configuring-kubectl-access)
    *   [Verification Commands](#verification-commands)
    *   [Install Metrics Server](#install-metrics-server)
    *   [Verify Metrics Server](#verify-metrics-server)
8.  [Phase 5: Accessing the Kubernetes Dashboard](#phase-5-accessing-the-kubernetes-dashboard)
    *   [Deploy Dashboard](#deploy-dashboard)
    *   [Create Admin Service Account](#create-admin-service-account)
    *   [Get Bearer Token](#get-bearer-token)
    *   [Access via `kubectl proxy`](#access-via-kubectl-proxy)
9.  [Expected Terminal Outputs](#expected-terminal-outputs)
    *   [`kubectl get nodes -o wide`](#kubectl-get-nodes--o-wide)
    *   [`kubectl get pods -A`](#kubectl-get-pods--a)
    *   [`kubectl top nodes`](#kubectl-top-nodes)
    *   [`kubectl top pods -A`](#kubectl-top-pods--a)

## Prerequisites

*   AWS infrastructure provisioned by the preceding Terraform task (VPC, subnets, EC2 instances, Security Groups, NLB).
*   Two Ubuntu 24.04 LTS EC2 instances in private subnets:
    *   One designated as `control-plane`.
    *   One designated as `worker-node`.
*   SSH access to these instances via a Jump Box.
*   Outbound internet connectivity for nodes (via NAT Gateway).
*   `kubectl` utility installed on the Jump Box or local machine for cluster interaction.

## Overview of Deployment Phases

1.  **Node Preparation:** Install container runtime (`containerd`), `kubeadm`, `kubelet`, `kubectl`, and configure necessary kernel parameters on all nodes.
2.  **Control-Plane Initialization:** Use `kubeadm init` on the control-plane node to bootstrap the cluster.
3.  **Worker Node Join:** Use the join command (outputted by `kubeadm init`) on the worker node to add it to the cluster.
4.  **Network Plugin Installation:** Deploy a CNI plugin (Calico) to enable pod-to-pod communication.
5.  **Metrics Server Installation:** Deploy the Metrics Server for resource usage monitoring (`kubectl top`).
6.  **Dashboard Deployment (Optional):** Deploy and configure access to the Kubernetes Dashboard.

## Shell Scripts Used

The following scripts automate parts of the installation process. They should be placed on the respective nodes and made executable (`chmod +x <script_name>.sh`).

*(Note: The content of these scripts will be detailed in the subsequent sections. You would typically either include the full script content directly in the README within code blocks or state that they are separate files in the repository, e.g., in a `scripts/` directory.)*

## Phase 1: Prepare All Nodes (Control-Plane & Worker)

This script (`prepare-node.sh`) must be run on **both** the control-plane and worker nodes.

### Script: `prepare-node.sh`
<a name="execution-prepare"></a>
### Execution
1.  Copy `prepare-node.sh` to both the control-plane and worker nodes (e.g., using `scp` from the Jump Box).
2.  Make it executable: `chmod +x prepare-node.sh`.
3.  Run as root: `sudo ./prepare-node.sh`.

## Phase 2: Initialize Control-Plane Node

This script (`initialize-control-plane.sh`) is run **only** on the designated control-plane node.

### Script: `initialize-control-plane.sh`
<a name="execution-control-plane"></a>
### Execution
1.  Copy `initialize-control-plane.sh` to the control-plane node.
2.  Make it executable: `chmod +x initialize-control-plane.sh`.
3.  Run as root: `sudo ./initialize-control-plane.sh`.
4.  **Crucially, copy the `kubeadm join ...` command printed at the end of the output. This is required for worker nodes.**

## Phase 3: Join Worker Node to Cluster

This script (`join-worker-node.sh`) is run **only** on the designated worker node.

### Script: `join-worker-node.sh`
<a name="execution-worker"></a>
### Execution
1.  Copy `join-worker-node.sh` to the worker node.
2.  Make it executable: `chmod +x join-worker-node.sh`.
3.  Run as root: `sudo ./join-worker-node.sh`.
4.  When prompted, paste the full `kubeadm join ...` command obtained from the control-plane initialization.

## Phase 4: Verify Cluster & Install Metrics Server

Perform these steps from the **control-plane node** or any machine configured with `kubectl` access to the new cluster (e.g., the Jump Box).

### Configuring `kubectl` Access
To use `kubectl` from a machine other than the control-plane node (e.g., the Jump Box):
1.  Copy the kubeconfig file from the control-plane node:
2.  On the Jump Box (or your local machine):

## Phase 5: Accessing the Kubernetes Dashboard

The Kubernetes Dashboard provides a web-based UI for managing the cluster.

### Deploy Dashboard
### Create Admin Service Account
For administrative access to the dashboard (for testing/development purposes only; use fine-grained RBAC for production).

Create `dashboard-adminuser.yaml`:

Copy the output token. This will be used to log in to the Dashboard.

### Access via `kubectl proxy`
This method makes the dashboard accessible on `localhost` via the `kubectl` utility.
1.  Run `kubectl proxy` in a terminal:
2.  Open a web browser and navigate to:
    `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/`
3.  When prompted, select "Token" and paste the bearer token obtained earlier.

## Expected Terminal Outputs

*(This section is a placeholder. You need to capture the actual output from your cluster after successful deployment and paste it here within code blocks.)*

<a name="kubectl-get-nodes--o-wide"></a>
### `kubectl get nodes -o wide`
<a name="kubectl-get-pods--a"></a>
### `kubectl get pods -A`