# terraform-aws-infrastructure-provision

This Terraform project provisions the foundational AWS infrastructure required to later deploy a Kubernetes cluster. It sets up networking (VPC, subnets, gateways), security groups, EC2 instances (including a jump box), and a Network Load Balancer in the `eu-west-1` AWS region.

## Project Structure

The project is organized into the following Terraform modules:

*   `./modules/vpc/`: Manages the Virtual Private Cloud, subnets, route tables, Internet Gateway, and NAT Gateway.
*   `./modules/security_groups/`: Defines the necessary security groups for the EC2 instances.
*   `./modules/ec2/`: Provisions the EC2 instances (jump box and Kubernetes worker nodes).
*   `./modules/load_balancer/`: Sets up the Network Load Balancer to expose services.

The root directory contains the main configuration files that orchestrate these modules.

## Infrastructure Provisioned

This project will create the following resources in the `eu-west-1` region:

1.  **VPC:**
    *   CIDR Block: `172.18.0.0/16`
    *   **Public Subnets (x2):**
        *   Size: `/24` each
        *   Deployed in two different Availability Zones.
        *   Associated with a route table allowing internet access via an Internet Gateway.
    *   **Private Subnets (x2):**
        *   Size: `/24` each
        *   Deployed in the same two Availability Zones as the public subnets.
        *   Associated with a route table routing internet-bound traffic through a NAT Gateway (located in one of the public subnets).
    *   **Internet Gateway (IGW):** Attached to the VPC for public subnet internet access.
    *   **NAT Gateway (NGW):** Deployed in one public subnet to allow private subnet instances outbound internet access.
    *   **Route Tables:** Configured for public and private subnets.

2.  **Security Groups:**
    *   **Group 1 (Jump Box SG):**
        *   Ingress: SSH (port 22) allowed from *Your Specified IP Address*.
        *   Egress: All outbound traffic allowed.
    *   **Group 2 (Kubernetes Nodes SG):**
        *   Ingress:
            *   SSH (port 22) from hosts in Group 1 (Jump Box SG).
            *   HTTP (port 80) from the internet (`0.0.0.0/0`).
            *   HTTPS (port 443) from the internet (`0.0.0.0/0`).
            *   Kubernetes API Server (port 6443) from within the VPC's CIDR range (`172.18.0.0/16`).
            *   Kubernetes NodePorts (ports 30000-32767) from within the VPC's CIDR range (`172.18.0.0/16`).
            *   (Note: The SG is designed to be extensible for other ports if needed).
        *   Egress: All outbound traffic allowed.
        *   Self-referencing rule: Allows all traffic from other instances within this same security group (Group 2).

3.  **EC2 Instances (Ubuntu 24.04 LTS):**
    *   **Jump Box (x1):**
        *   Launched in one of the public subnets.
        *   Associated with Group 1 Security Group.
        *   Used to SSH into the private Kubernetes nodes.
    *   **Kubernetes Nodes (x2):**
        *   Launched into the two different private subnets (one per AZ).
        *   Associated with Group 2 Security Group.
        *   Intended to act as Kubernetes worker nodes (cluster configuration is a separate task).

4.  **Network Load Balancer (NLB):**
    *   Public-facing (internet).
    *   Deployed across the two public subnets.
    *   Listens on:
        *   Port 80 (TCP), forwarding to the Kubernetes nodes on port 80.
        *   Port 443 (TCP), forwarding to the Kubernetes nodes on port 443.
    *   Target groups will point to the two Kubernetes nodes.
