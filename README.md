# Single GPU Passthrough (KVM/QEMU)

A robust, high-performance Windows 11 gaming virtual machine setup on a Linux host using Single GPU Passthrough.

## Overview
This repository contains the core configuration files and libvirt hooks needed to seamlessly detach the host GPU, pass it to the Windows guest, and reattach it upon shutdown. The configuration is specifically tuned for performance, low latency, and maximum stealth (hiding the KVM hypervisor).

## Project Structure
- `win11.xml`: The primary Windows 11 VM definition.
- `hooks/`: Libvirt hook scripts (`qemu`, `vfio-startup`, `vfio-teardown`) that handle GPU binding, CPU isolation, and audio routing.
- `install_hooks.sh`: An automated script to install the hooks into system locations and register the VM.

## Installation
Run the install script with root privileges to deploy the hook scripts to `/etc/libvirt/hooks` and `/usr/local/bin`, and define the VM configuration:
```bash
sudo ./install_hooks.sh
```

## Documentation
Detailed setup notes, research, benchmarks, and troubleshooting logs are maintained in the local `wiki/` folder.
