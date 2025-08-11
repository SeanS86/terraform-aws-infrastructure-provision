# Troubleshooting Kubernetes Dashboard Access via NLB

This section outlines the debugging steps taken to resolve a "Connection refused" error when accessing the Kubernetes Dashboard via a Network Load Balancer (NLB) from the internet, even when internal access to the dashboard's NodePort was successful and NLB target health checks were passing.

## Problem Symptom

Attempts to access the Kubernetes Dashboard using the NLB's public DNS name (`https://ss86-nlb-3ecb186efbab9e44.elb.eu-west-1.amazonaws.com`) from an external PC resulted in a "Connection refused" error.

However, the following were confirmed to be working:
*   Accessing the Kubernetes Dashboard directly on the worker node's IP and NodePort (e.g., `curl -vki https://172.18.3.234:30865`) from within the VPC (e.g., from the jump box) was successful.
*   The AWS NLB target group showed all registered worker nodes as "healthy" for the dashboard's NodePort (e.g., `30865`).

This indicated an issue with the network path or security rules between the internet client, the NLB, and the worker nodes, specifically for client traffic rather than health check traffic.

## Investigation and Analysis

The investigation focused on the AWS Security Groups associated with the Kubernetes worker nodes, as NLBs using TCP listeners preserve the client's source IP address. This means the worker nodes see the connection attempt as originating directly from the external client's IP.

### Security Group Review

Two primary security groups were identified from the Terraform configuration:

1.  **Security Group 1: `sg-0ba04c8dfa841071a`**
    *   **Name:** `Ss86-sg1-bastion-access`
    *   **Description:** "Allow SSH from Tools EC2 to Bastion/Jumpbox"
    *   **Relevant Inbound Rules:**
        *   Allows TCP port `22` (SSH) only from a specific IP (`3.255.177.47/32`).
    *   **Conclusion:** This security group is intended for the jump box and does **not** allow traffic on the Kubernetes Dashboard NodePort (`30865`). If mistakenly attached to worker nodes, it would block dashboard access.

2.  **Security Group 2: `sg-0589df93864dbfd13`**
    *   **Name:** `Ss86-sg2-application`
    *   **Description:** "Application Security Group" (Assumed to be attached to worker nodes for application traffic).
    *   **Relevant Inbound Rules (at the time of investigation):**
        *   Allows TCP port `80` (HTTP) from `0.0.0.0/0`.
        *   *(No rule existed for TCP port `30865`)*.
    *   **Conclusion:** This security group, while allowing general HTTP traffic, was **missing a specific inbound rule for TCP port `30865`**, which is used by the Kubernetes Dashboard (via Kong's NodePort service).

### Root Cause

The "Connection refused" error occurred because the security group(s) attached to the Kubernetes worker nodes did not have an inbound rule allowing TCP traffic on port `30865` from the internet (`0.0.0.0/0`) or the specific client IP.

When a client attempts to connect to the NLB, the NLB forwards this TCP traffic to a healthy target (a worker node) on the configured NodePort (`30865`). Because the NLB preserves the client's IP, the worker node's operating system checks its security group rules to see if traffic from that client IP on port `30865` is permitted. Since no such rule existed, the connection was refused.

## Solution

The solution was to add an inbound rule to the appropriate security group attached to the Kubernetes worker nodes (identified as `sg-0589df93864dbfd13` - `Ss86-sg2-application`).

This new rule allows:
*   **Protocol:** TCP
*   **Port Range:** `30865` (the NodePort for the Kubernetes Dashboard via Kong)
*   **Source:** `0.0.0.0/0` (for general access during testing/development). *For production, this should be restricted to known, trusted IP ranges if possible.*

### Implementation (Terraform)

The change was implemented by modifying the `aws_security_group` resource definition in the Terraform configuration.

1.  **Identify the Worker Node Security Group:**
    The security group `sg-0589df93864dbfd13` (`Ss86-sg2-application`) was confirmed to be the one associated with the Kubernetes worker nodes (`k8s_node1`, `k8s_node2`) in the EC2 instance definitions within the Terraform code.

2.  **Modify the Security Group Resource in Terraform:**
    The following `ingress` block was added to the `aws_security_group` resource corresponding to `sg-0589df93864dbfd13`: