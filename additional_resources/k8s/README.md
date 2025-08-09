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
7.  [Phase 4: Verify Cluster](#phase-4-verify-cluster)
    *   [Configuring `kubectl` Access](#configuring-kubectl-access)
    *   [Verification Commands](#verification-commands)

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

## Phase 4: Verify Cluster

Perform these steps from the **control-plane node** or any machine configured with `kubectl` access to the new cluster (e.g., the Jump Box).

### Configuring `kubectl` Access
To use `kubectl` from a machine other than the control-plane node (e.g., the Jump Box):
1.  Copy the kubeconfig file from the control-plane node:
To manage your Kubernetes cluster from a remote machine using `kubectl`, you need the `kubeconfig` file. This file contains the cluster connection information and credentials.

The primary administrative `kubeconfig` file on a control-plane node initialized with `kubeadm` is located at:

*   `/etc/kubernetes/admin.conf`

This file grants cluster-admin privileges and is typically the one you'll want to copy for external administrative access.


2.  On the Jump Box (or your local machine):
Once you have obtained the `admin.conf` file from your control-plane node, you can use it to access your Kubernetes cluster from a Jump Box or your local machine using `kubectl`.

The `admin.conf` file should typically be placed at `~/.kube/config` on the machine where you intend to run `kubectl` commands, or its path should be pointed to by the `KUBECONFIG` environment variable.

- **Set the `KUBECONFIG` Environment Variable (if not using the default path):**
    If you've placed the configuration file at a location other than `~/.kube/config`, or if you manage multiple cluster configurations, you'll need to tell `kubectl` where to find it.

- **To test:**
    `kubectl get nodes -o wide`,
    `kubectl get pods -A` &
    `kubectl top pods -A`

## Expected Terminal Outputs

*(This section is a placeholder. You need to capture the actual output from your cluster after successful deployment and paste it here within code blocks.)*
