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
    *   `EC2_USER`: The SSH username for the target server (`ubuntu`).

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
*   Copy the Ansible files from `./additional_resources/ansible_web_deploy/` to the target server.
*   Execute the `playbook.yml` on the target server. This playbook will:
    *   Install Nginx and its dependencies.
    *   Configure a default Nginx site.
    *   Generate a self-signed SSL certificate for HTTPS.
    *   Serve the sample `index.html` page.

## Accessing the Deployed Web Page

Once the GitHub Actions workflow has completed successfully, you can access the deployed web page.

**Access the Page in Your Web Browser:**
*   **For Nginx serving on HTTP (port 80):**
    Open your web browser and go to `http://3.255.177.47`

*   **For Nginx serving on HTTPS (port 443) (we generated a self-signed certificate):**
    Open your web browser and go to `https://3.255.177.47`

The page should then load, displaying the content from the `index.html.j2` template, which typically shows the server's hostname.

## Terminal Output

```
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.14.0-1010-aws x86_64)
 * Documentation:  https://help.***.com
 * Management:     https://landscape.canonical.com
 * Support:        https://***.com/pro
 System information as of Sun Aug 10 23:14:16 UTC 2025
  System load:           0.0
  Usage of /:            70.3% of 6.71GB
  Memory usage:          15%
  Swap usage:            0%
  Temperature:           -273.1 C
  Processes:             123
  Users logged in:       1
  IPv4 address for ens5: 172.19.0.96
  IPv6 address for ens5: 2a05:d018:1eea:600:6423:4676:4266:fcfb
 * Ubuntu Pro delivers the most comprehensive open source security and
   compliance features.
   https://***.com/aws/pro
Expanded Security Maintenance for Applications is not enabled.
7 updates can be applied immediately.
To see these additional updates run: apt list --upgradable
Enable ESM Apps to receive additional future security updates.
See https://***.com/esm or run: sudo pro status
--- Current location on EC2 before cd ---
/home/***
--- Attempting to cd to /home/***/ansible_deployment/ansible_web_deploy ---
--- Current location on EC2 after cd ---
/home/***/ansible_deployment/ansible_web_deploy
--- Listing files in /home/***/ansible_deployment/ansible_web_deploy on EC2 ---
total 28
drwxrwxr-x 3 *** *** 4096 Aug 10 21:32 .
drwxrwxr-x 3 *** *** 4096 Aug 10 21:32 ..
-rw-r--r-- 1 *** ***  689 Aug 10 23:14 README.md
-rw-r--r-- 1 *** ***  303 Aug 10 23:14 ansible.cfg
-rw-r--r-- 1 *** ***  206 Aug 10 23:14 inventory.ini
-rw-r--r-- 1 *** ***  146 Aug 10 23:14 playbook.yml
drwxr-xr-x 3 *** *** 4096 Aug 10 21:32 roles
--- Checking and Installing Dependencies on EC2 (if playbook.yml is found) ---
--- Dependency check complete ---
Ensuring inventory.ini is set for local execution in /home/***/ansible_deployment/ansible_web_deploy...
Updated inventory.ini for local execution:
[webservers]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3
Running Ansible playbook from /home/***/ansible_deployment/ansible_web_deploy...
PLAY [Deploy and Configure Web Server] *****************************************
TASK [Gathering Facts] *********************************************************
ok: [localhost]
TASK [webserver : Include OS-specific variables] *******************************
ok: [localhost]
TASK [webserver : Install Nginx] ***********************************************
included: /home/***/ansible_deployment/ansible_web_deploy/roles/webserver/tasks/install_nginx.yml for localhost
TASK [webserver : Update apt cache (Debian/Ubuntu)] ****************************
changed: [localhost]
TASK [webserver : Install Nginx (Debian/Ubuntu)] *******************************
ok: [localhost]
TASK [webserver : Configure SSL] ***********************************************
included: /home/***/ansible_deployment/ansible_web_deploy/roles/webserver/tasks/configure_ssl.yml for localhost
TASK [webserver : Create SSL directory] ****************************************
ok: [localhost]
TASK [webserver : Generate self-signed SSL certificate key] ********************
ok: [localhost]
TASK [webserver : Generate self-signed SSL certificate (CSR)] ******************
ok: [localhost]
TASK [webserver : Generate self-signed SSL certificate from CSR] ***************
ok: [localhost]
TASK [webserver : Configure Nginx site] ****************************************
included: /home/***/ansible_deployment/ansible_web_deploy/roles/webserver/tasks/configure_site.yml for localhost
TASK [webserver : Create web root directory] ***********************************
ok: [localhost]
TASK [webserver : Create index.html from template] *****************************
ok: [localhost]
TASK [webserver : Configure Nginx default site] ********************************
ok: [localhost]
TASK [webserver : Ensure default site is enabled] ******************************
ok: [localhost]
TASK [webserver : Ensure Nginx is started and enabled] *************************
ok: [localhost]
PLAY RECAP *********************************************************************
localhost                  : ok=16   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
Ansible playbook execution finished.
--- Nginx Status ---
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Sun 2025-08-10 22:32:03 UTC; 42min ago
       Docs: man:nginx(8)
    Process: 49386 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 49387 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 51821 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
   Main PID: 49416 (nginx)
      Tasks: 3 (limit: 4515)
     Memory: 3.5M (peak: 5.4M)
        CPU: 86ms
     CGroup: /system.slice/nginx.service
             ├─49416 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─51823 "nginx: worker process"
             └─51824 "nginx: worker process"
Aug 10 22:32:03 ip-172-19-0-96 systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
Aug 10 22:32:03 ip-172-19-0-96 systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
Aug 10 22:43:53 ip-172-19-0-96 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Aug 10 22:43:53 ip-172-19-0-96 nginx[50765]: 2025/08/10 22:43:53 [emerg] 50765#50765: unknown directive "nginx" in /etc/nginx/sites-enabled/default:2
Aug 10 22:43:53 ip-172-19-0-96 systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
Aug 10 22:43:53 ip-172-19-0-96 systemd[1]: Reload failed for nginx.service - A high performance web server and a reverse proxy server.
Aug 10 23:03:23 ip-172-19-0-96 systemd[1]: Reloading nginx.service - A high performance web server and a reverse proxy server...
Notice: 3:03:23 ip-172-19-0-96 nginx[51821]: 2025/08/10 23:03:23 [notice] 51821#51821: signal process started
Aug 10 23:03:23 ip-172-19-0-96 systemd[1]: Reloaded nginx.service - A high performance web server and a reverse proxy server.
--- End of Nginx Status ---
```

