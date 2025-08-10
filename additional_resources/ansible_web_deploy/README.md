# Ansible Web Server Deployment

This project contains Ansible playbooks and roles to deploy and configure Nginx as a web server on a target machine. It sets up HTTP and HTTPS, serving a static HTML page that displays the server's hostname. A self-signed SSL certificate is generated for HTTPS.

## Prerequisites

*   Ansible installed on the control node.
*   SSH access (key-based recommended) to the target server(s) from the control node.
*   Python installed on the target server(s).
*   The target server's security group must allow inbound traffic on ports 80 (HTTP) and 443 (HTTPS).
*   If using the `community.crypto` modules for SSL, ensure the collection is installed: