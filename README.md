# terraform-azure-k3s-lab

## TL;DR:

- Do not use it in production environments. It's a quick lab.
- It's an IaaS lab foccussed on K3s (so no AKS, AzLoadBalancer...).

## Requirements

- Docker, in order to support DevContainers.
- VSCode with DevContainrs plugin.

## How to

1. Initiate the DevContainer.

2. Authenticate to Azure using `az login` (and select proper subscription with `az account set --subscription <subscription>`).

3. Browse to the `terraform` folder, and check these variables before applying it:

  - `rg_name`: Shouldn't exist in your subscription.
  - `vm_prefix_name`: Shouldn't overlap with current VM's in your subscription.

4. Deploy it with `terraform apply`.

5. Log in to the VM, and have fun (`ssh gw` / `ssh k3s-0` / `ssh k3s-1` / ...).

## Topology

```mermaid
flowchart LR
    C("Gateway<br>") --> D["K3s Server"] & E["K3s Node 1"] & F["K3s Node n"]
    n1[/"Admin (ssh)"\] --> C
    n2[/"User (web)"\] --> C
```

- Server sufixed by (`-gw`) is the proxy for all traffic (`ssh` and `http/https`).
- Server sufixed by (`-0`) is the K3s server.
- Any other server is a K3s node.
