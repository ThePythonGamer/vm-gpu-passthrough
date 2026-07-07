# Repository Guidelines

## Project Structure & Module Organization

This is a single-GPU passthrough workspace for a Linux host and Windows VM. Core automation lives in `hooks/`: `qemu` is the libvirt hook entrypoint, while `vfio-startup` and `vfio-teardown` handle GPU binding, CPU isolation, hugepages, display state, and audio/VNC setup. `install_hooks.sh` installs those files into system locations. VM definitions are root-level `*.xml` files, udev rules are `99-*.rules`, and helper recovery scripts are root-level `*.sh` files. `systemd-no-sleep/` contains the libvirt sleep inhibitor service. Notes and setup docs live in `*.md` and `wiki/`; images are under `wiki/images/` and `wiki/uploads/`.

## Build, Test, and Development Commands

There is no compiled build step. Validate scripts and configs before installing:

- `bash -n install_hooks.sh hooks/qemu hooks/vfio-startup hooks/vfio-teardown`: checks Bash syntax.
- `xmllint --noout win11-outlaws.xml`: validates VM XML when `xmllint` is available.
- `sudo ./install_hooks.sh`: installs hooks, service files, and PipeWire EQ config into system paths.
- `sudo virsh define win11-outlaws.xml`: imports a VM XML definition.

Run system-changing commands only on the intended host; scripts write to `/etc`, `/usr/local/bin`, `/sys`, `/tmp`, and libvirt state.

## Coding Style & Naming Conventions

Use Bash for automation scripts and keep `#!/bin/bash` at the top. Prefer explicit variable names, quoted expansions, and timestamped log output where hook behavior affects recovery. Match existing two- or four-space indentation within the edited file; avoid broad reformatting. Keep host-specific constants, such as PCI IDs, VM names, CPU ranges, usernames, and audio devices, near the logic that uses them.

## Testing Guidelines

No formal test suite exists. For script changes, run `bash -n` on every edited shell file and review root commands before executing them. For XML changes, validate with `xmllint --noout` and compare CPU, memory, PCI, disk, and Hyper-V sections carefully. For hook changes, test a full VM start and shutdown cycle, then inspect `/var/log/libvirt/custom_hooks.log`.

## Change Management

Keep changes small and reversible. Document host-specific assumptions in the relevant Markdown note or wiki page when changing PCI devices, CPU topology, audio routing, udev rules, hugepages, or systemd behavior. When sharing changes, include the goal, affected files, validation performed, and recovery steps such as running `recover.sh`.

## Security & Configuration Tips

Do not store private VM secrets, disk paths, license keys, or credentials here. Treat `sudo`, `virsh`, `modprobe`, `/sys` writes, and systemd changes as privileged operations that can disrupt the host display or audio session. Keep a known-good VM XML and recovery path available before modifying hooks.
