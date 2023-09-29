# OpenShift Network Playground (onp)
[![licence](https://img.shields.io/github/license/kevydotvinu/openshift-network-playground)](https://github.com/kevydotvinu/openshift-network-playground/blob/master/LICENSE)
[![downloads](https://img.shields.io/github/downloads/kevydotvinu/openshift-network-playground/total)](https://github.com/kevydotvinu/openshift-network-playground/releases)
[![artifact](https://img.shields.io/github/actions/workflow/status/kevydotvinu/openshift-network-playground/build-customize-artifact.yaml)](https://github.com/kevydotvinu/openshift-network-playground/actions/workflows/build-customize-artifact.yaml)
[![issues](https://img.shields.io/github/issues/kevydotvinu/openshift-network-playground)](https://github.com/kevydotvinu/openshift-network-playground/issues)
[![pullrequests](https://img.shields.io/github/issues-pr/kevydotvinu/openshift-network-playground)](https://github.com/kevydotvinu/openshift-network-playground/pulls)
[![openshiftlab](https://img.shields.io/badge/openshift%20-lab-orange)](https://github.com/kevydotvinu/openshift-network-playground)

The OpenShift Network Playground is both web-based and cli-based interface built for advanced OpenShift users that makes it easy to quickly build and test different OpenShift network scenarios.

## Architecture
![OpenShift network playground](../media/onp-architecture.png?raw=true)

## Features
- Zero-touch installation (ZTI).
- [Cockpit](https://cockpit-project.org/) cluster deployment.
- Easy NIC addition to the cluster nodes.
- Web-based file manager, VM management and container management.
- RHCOS console login for unreachable nodes.
- Quick Operator installation and sample manifests for test.
- [Network tools](https://github.com/openshift/network-tools).
- [Single-stack IPv6 cluster](#single-stack-ipv6-cluster-architecture).
- Easy RHCOS/FCOS VM provisioning.
- Kind cluster.
- Golang network tools.

## Prerequisites
### OpenShift cluster manager API token
Copy it from [here](https://console.redhat.com/openshift/token/show).

### Machine
|Machine|CPU|RAM|DISK|
|:-:|:-:|:-:|:-:|
|VM or Bare-metal|20|80 GB|320 GB|

> **INFO**: Enable nested virtualization if the host is a VM. In Red Hat Virtualization, enable the `Pass-Through Host CPU` CPU option in the Virtual Machine settings (Under the Host section). In VMware ESXi, enable `Hardware virtualization` (Expose hardware assisted virtualization to the guest OS). This can be checked using the `virt-host-validate` command from the VM itself. The output of the command should provide `QEMU: Checking for hardware virtualization : PASS`.

## Installation
- Download the ISO.
```bash
curl -LO $(curl -s https://api.github.com/repos/kevydotvinu/openshift-network-playground/releases/latest | grep "browser_download_url.*\.iso" | cut -d : -f 2,3 | tr -d \")
```
- Boot it and wait for the installation to complete (Monitor the progress in the machine console).
> **WARNING**: The ISO boot will erase ALL the data on the `/dev/sda` disk and install OpenShift Network Playground automatically.

## OpenShift cluster deployment
### Web-based
- Access Cockpit console (`https://<IP>:9090/`).
- Authenticate using the credentials (username: `onp`, password: `Onp@123`).
- Go to `OpenShift` tab.
- Enter the release (`stable-4.12`, `4.12.2`, etc) and [OCM API token](https://console.redhat.com/openshift/token/show).
- Press the `Deploy` button.

> **INFO**: To monitor the deployment progress, go to `Services` tab and search for `deploy-cluster.service`.

### CLI-based
```bash
onp help
onp deploy RELEASE=<release> OCM_TOKEN=<token>
```
## Single-stack IPv6 cluster architecture
![Single-stack IPv6 cluster architecture](../media/onp-ipv6.png?raw=true)

## Sponsor
Many thanks to **JetBrains** for Open Source development license(s).

[![JetBrains Logo (Main) logo](https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.svg)](https://jb.gg/OpenSourceSupport)
