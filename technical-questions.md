# Technical Knowledge Questions & Answers

This section outlines key technical questions related to the technologies and practices used in this project or relevant to the domain.

## Terraform

*   **How would you manage Terraform state for a team of engineers?**
    *   *Have a centrally stored state file and lock mechanism to avoid conflicts. e.g S3 bucket (for state) and DynamoDb table (for lock)*
*   **What are modules, and why use them?**
    *   *Modules are reusable and help with code organization, reusability, consistency, and abstraction.*
*   **How do you bring infrastructure deployed without Terraform in under Terraform’s management?**
    *   *I went through a process of having to prepare an IaC using Terraform to mirror the existing infrastructure*

## Kubernetes

*   **How would you troubleshoot a pod that is stuck in `CrashLoopBackOff`?**
    *   *Use the command `kubectl logs <pod-name> [-c <container-name>] [--previous]` to check the logs, checking resource requests/limits, liveness/readiness probes, image issues and configuration errors (ConfigMaps/Secrets).*
*   **What’s the difference between Deployments, StatefulSets, and DaemonSets?**
    *   *Deployments are for stateless applications, managing ReplicaSets, rolling updates, and rollbacks.*
    *   *A StatefulSets are for stateful applications requiring persistent storage, stable network identifiers, and ordered, graceful deployment/scaling.*
    *   *While DaemonSets are to ensures a copy of a pod runs on all (or a subset of) nodes in the cluster, useful for node-level agents like log collectors or monitoring agents.*
*   **How would you implement a rolling upgrade of a Kubernetes cluster (control plane and nodes) without downtime?**
    *   *Upgrade the control plane components one by one (etcd, API server, controller manager, scheduler), ensuring HA setup for control plane. For worker nodes: cordoning nodes, draining workloads, upgrading/replacing the node, and then uncordoning.*

## Helm

*   **How do you provide settings relevant to a specific deployment to Helm?**
    *   *I use the  `values.yaml` files, the `--values` (or `-f`) flag with `helm install/upgrade`, and name the files after their respective environments.*
*   **An application is deployed from an internal Helm chart. You need to add resources settings (requests/limits) on a Kubernetes deployment’s pod template. There is no suitable setting in the `values.yaml` that comes with the chart. How do you add this setting to the chart?**
    *   *Modify and/or fiddle with the Helm chart itself by:
        1.  Edit the relevant Deployment template (e.g., `templates/deployment.yaml`).
        2.  Add the `resources` section to the pod spec's container definition.
        3.  Parameterize these settings by adding new entries in the `values.yaml` file (e.g., `resources.requests.cpu`, `resources.limits.memory`).
        4.  Reference these new values in the Deployment template using `{{ .Values.resources... }}`.
        5.  Increment the chart version and re-package/re-deploy.*

## Ansible

*   **What are the advantages of using roles?**
    *   *They break playbooks into logical units, reusable and maintainable.*
*   **How would you ensure that a service gets restarted if a playbook edits its config file, but not otherwise?**
    *   *By using handlers and the `notify` keyword. The task that modifies the config file would `notify` a handler. The handler (defined in the `handlers` section) would be responsible for restarting the service. Handlers are only triggered if the notifying task reports a change.*

## DevOps Practices

*   **How do you handle secrets in CI/CD pipelines?**
    *   *Depending on your tools stack on the pipeline you use the following:
        *   Use CI/CD secrets management tools (e.g., HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager).
        *   CI/CD platform's built-in secrets storage (e.g., GitHub Actions Secrets, GitLab CI/CD variables).
        *   Injecting secrets as environment variables at runtime.
        *   Avoiding storing secrets directly in code/version control.
        *   Least privilege access for pipelines.*
*   **What tools and strategies do you use to monitor a production Kubernetes cluster?**
    *   *By setting up observability and monitoring tools:
        *   **Metrics Collection:** Prometheus, CloudWatch Container Insights, Datadog, Dynatrace.
        *   **Log Aggregation:** Elasticsearch/Fluentd/Kibana (EFK stack), Loki, Splunk, CloudWatch Logs.
        *   **Visualization & Alerting:** Grafana, Prometheus Alertmanager, CloudWatch Alarms.
        *   **Distributed Tracing:** Jaeger, DynaTrace.
        *   **Key areas to monitor:** Node health (CPU, memory, disk, network), Pod health & resource usage, Control plane health, Application-specific metrics, Kubernetes API server latency, etcd health, Ingress/Service performance.*
