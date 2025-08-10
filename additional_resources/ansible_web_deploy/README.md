# Ansible Web Server Deployment

This project contains Ansible playbooks and roles to deploy and configure Nginx as a web server on a target machine. It sets up HTTP and HTTPS, serving a static HTML page that displays the server's hostname. A self-signed SSL certificate is generated for HTTPS.

The deployment is automated using a GitHub Actions workflow.

## Prerequisites

### For the GitHub Actions Workflow to Run Successfully:

*   **Target Server:** An existing server (e.g., an AWS EC2 instance) that is accessible via SSH.
*   **SSH Key:** An SSH private key that has authorized access to the target server.
*   **GitHub Secrets:** The following secrets must be configured in your GitHub repository settings (`Settings` > `Secrets and variables` > `Actions`):
    *   `ID_RSA`: The *contents* of your private SSH key for accessing the target server.
    *   `EC2_HOST`: The public IP address or DNS name of the target server.
    *   `EC2_USER`: The SSH username for the target server (e.g., `ubuntu`, `ec2-user`).
*   **Target Server Security Group / Firewall:** The target server's firewall (e.g., AWS Security Group, `ufw`) must allow inbound traffic on:
    *   Port 22 (for SSH by the GitHub Action runner).
    *   Port 80 (for HTTP access to the web server).
    *   Port 443 (for HTTPS access to the web server).

### For the Ansible Playbook on the Target Server:
*   The playbook will attempt to install Python and Ansible if they are not present.

## Deployment Steps (via GitHub Actions)

The Ansible playbook deployment is automated using the GitHub Actions workflow defined in `.github/workflows/deploy_webserver.yml`.

**Ensure Prerequisites are Met:**
    *   Verify that the target server is running and accessible.
    *   Confirm that the necessary GitHub Secrets (`ID_RSA`, `EC2_HOST`, `EC2_USER`) are correctly configured in your repository.
    *   Check that the target server's firewall/security group rules allow inbound traffic on ports 22, 80, and 443.

**The GitHub Action will:**
*   Check out your repository on a GitHub-hosted runner.
*   Set up SSH access to your target server using the provided secrets.
*   Copy the Ansible files from `./ansible_web_deploy/` (or the configured path) to the target server.
*   Execute the `playbook.yml` on the target server. This playbook will:
    *   Install Nginx and its dependencies.
    *   Configure a default Nginx site.
    *   Generate a self-signed SSL certificate for HTTPS.
    *   Serve the sample `index.html` page.

## Accessing the Deployed Web Page

Once the GitHub Actions workflow has completed successfully, you can access your deployed web page.

**Access the Page in Your Web Browser:**
    *   **For Nginx serving on HTTP (port 80):**
        Open your web browser and go to `http://3.255.177.47`
    *   **For Nginx serving on HTTPS (port 443) (we generated a self-signed certificate):**
        Open your web browser and go to `https://3.255.177.47`
    The page should then load, displaying the content from the `index.html.j2` template, which typically shows the server's hostname.

