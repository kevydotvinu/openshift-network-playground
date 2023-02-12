# OpenShift Network Playground (onp)

The OpenShift Network Playground is both web-based and cli-based interface built for advanced OpenShift users that makes it easy to quickly build and test different OpenShift network scenarios.

## Architecture
![OpenShift network playground](../media/onp-architecture.png?raw=true)

## Features
- Zero-touch installation (ZTI).
- [Cockpit](https://cockpit-project.org/) cluster deployment.
- Easy NIC addition to the cluster nodes.
- Quick Operator installation.
- Web-based file manager, VM management and container management.
- RHCOS console login for unreachable nodes.

## Prerequisites
### OpenShift cluster manager API token
Copy it from [here](https://console.redhat.com/openshift/token/show).

### Machine
|Machine|CPU|RAM|DISK|
|:-:|:-:|:-:|:-:|
|VM or Bare-metal|20|80 GB|320 GB|

> **Important**: Enable nested virtualization if the host is a VM. In Red Hat Virtualization, enable the `Pass-Through Host CPU` CPU option in the Virtual Machine settings (Under the Host section). In VMware ESXi, enable `Hardware virtualization` (Expose hardware assisted virtualization to the guest OS). This can be checked using the `virt-host-validate` command from the VM itself. The output of the command should provide `QEMU: Checking for hardware virtualization : PASS`.

## Installation
- Download the ISO from [here](https://drive.google.com/file/d/1VT7Eec9iw_ocAMcYBbQzqpWg5Jqs98m2).
- Boot it and wait for the installation to complete (Monitor the progress in the machine console).

## OpenShift cluster deployment
### Web-based
- Access Cockpit console (`https://<IP>:9090/`).
- Authenticate using the credentials (username: `onp`, password: `Onp@123`).
- Go to `OpenShift` tab.
- Enter the release (`stable-4.12`, `4.12.2`, etc) and [OCM API token](https://console.redhat.com/openshift/token/show).
- Press the `Deploy` button.

> **Info**: To monitor the deployment progress, go to `Services` tab and search for `deploy-cluster.service`.

### CLI-based
```bash
$ onp help
$ onp deploy RELEASE=<release> OCM_TOKEN=<token>
```
