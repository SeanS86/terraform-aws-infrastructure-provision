# 1. Troubleshooting: Kong Configuration for Kubernetes Dashboard NodePort Access

This section details the Kubernetes and Kong configurations that enable access to the Kubernetes Dashboard via Kong on a specific NodePort (e.g., `30865`). This setup is common when using Kong as an Ingress controller or an API gateway in front of services like the Kubernetes Dashboard.

## Objective

The goal is to expose the Kubernetes Dashboard, which typically runs on HTTPS (port 443) within the cluster, to the external network via Kong using a `NodePort` service. This means Kong will listen on a specific port on each Kubernetes worker node (e.g., `30865`), and traffic hitting that port will be routed by Kong to the Dashboard.

## Key Configuration Components

The setup relies on two main parts:

1.  **Kong's Kubernetes Service (`kubernetes-dashboard-kong-proxy`):**
    This is the Kubernetes `Service` object that exposes the Kong proxy itself. To make the Kubernetes Dashboard accessible via a NodePort through Kong, this service needs to be of type `NodePort`.

2.  **Kong's Routing Configuration (Ingress or KongIngress/TCPIngress):**
    Kong needs to be told how to route traffic that arrives on the port exposed by its `NodePort` service to the actual Kubernetes Dashboard service.

## Configuration Details

### 1. Exposing Kong via a NodePort Service

The primary step is ensuring that the Kubernetes `Service` for Kong (specifically the one intended to proxy traffic to the dashboard) is configured as `type: NodePort`.

**Example Kubernetes Service Manifest (Conceptual):**

If you're managing Kong via direct Kubernetes manifests or a customized Helm chart, the service definition would look something like this:

**Key fields in the Service manifest:**

*   `spec.type: NodePort`: This makes the service accessible on a static port on each node.
*   `spec.ports[].port`: The port the service is exposed on *within* the cluster's internal network (ClusterIP). For HTTPS traffic to the dashboard, this is typically Kong's internal HTTPS proxy port (e.g., 443 if Kong itself terminates SSL for the dashboard, or the dashboard's actual port if Kong is doing TCP passthrough).
*   `spec.ports[].targetPort`: The port on the Kong Pods that the service should forward traffic to. For Kong, this is often `8443` (secure proxy) or `8000` (insecure proxy).
*   `spec.ports[].nodePort: 30865`: This is the explicit port number (`30865` in our case) that will be opened on all worker nodes. If not specified, Kubernetes assigns a random port from the NodePort range. Specifying it ensures a predictable access point.

**Verification (using `kubectl`):**
You confirmed this setup with:
Output:
```
ubuntu@ip-172-18-1-83:~/scripts$ kubectl get svc kubernetes-dashboard-kong-proxy -n kubernetes-dashboard -o wide
NAME                              TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE   SELECTOR
kubernetes-dashboard-kong-proxy   NodePort   10.100.206.159   <none>        443:30865/TCP   64m   app.kubernetes.io/component=app,app.kubernetes.io/instance=kubernetes-dashboard,app.kubernetes.io/name=kong
```
This output shows that the `kubernetes-dashboard-kong-proxy` service is indeed a `NodePort` service, mapping internal port `443` to NodePort `30865`.

### 2. Kong's Internal Routing to the Kubernetes Dashboard

Once traffic hits Kong on port `30865` (which is then directed to its internal port, e.g., `443`), Kong needs to know how to route this traffic to the actual `kubernetes-dashboard` service. This is typically handled by:

*   **Kong Ingress Resource (for HTTP/HTTPS routing):** If Kong is acting as an Ingress controller and the dashboard is exposed via an Ingress object that Kong manages. The Ingress resource would define rules based on hostname or path to route to the `kubernetes-dashboard` service.
*   **Kong `TCPIngress` Custom Resource (for L4 TCP routing):** If Kong is proxying raw TCP traffic directly to the dashboard service (especially if the dashboard handles its own TLS termination or if you want TLS passthrough at the Kong level).
*   **Kong's Static Configuration (`kong.conf` or environment variables):** Less common in Kubernetes but possible, where Kong might have predefined upstream services.

**Conceptual TCPIngress (if Kong is handling raw TCP forwarding for the dashboard's HTTPS):**

If Kong is handling TLS termination itself *before* proxying to the dashboard (e.g., NodePort `30865` (HTTPS) -> Kong (terminates TLS) -> Dashboard (HTTP or HTTPS)), then a standard `Ingress` resource might be used, or Kong's configuration would involve setting up an upstream service pointing to the dashboard and associating an SSL certificate with the listening route/service in Kong.

The `curl -vki https://172.18.4.193:30865` test successfully returning the dashboard page (after an initial `400 Bad Request` when using HTTP) indicates that Kong is indeed listening for HTTPS traffic on the port mapped by NodePort `30865` and is correctly proxying it to the Kubernetes Dashboard.

## Summary

The ability for Kong to listen on port `30865` and serve the Kubernetes Dashboard is achieved by:
1.  Defining the Kong proxy's Kubernetes `Service` as `type: NodePort` with `nodePort: 30865` and mapping it to Kong's internal HTTPS listener port. And this was achieved by applying yaml files in `./adhoc` subdirectory.
2.  Ensuring Kong has the necessary routing rules (via Ingress, TCPIngress, or its configuration) to forward requests received on that internal port to the upstream `kubernetes-dashboard` service.
    The following `ingress` block was added to the `aws_security_group` resource corresponding to `sg-0589df93864dbfd13`:


# 2. Troubleshooting: Kubernetes Dashboard Access via NLB

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
    The following `ingress` block was added to the `aws_security_group` resource corresponding to `sg-0589df93864dbfd13`.