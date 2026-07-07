# VFIO Profile Recovery

This workspace now has two local hook profiles for the `win11` VM.

## Current OutlawsHV Profile

- XML: `win11-outlawsHV.xml`
- Hooks: `hooks/profiles/current-outlawsHV/vfio-startup` and `hooks/profiles/current-outlawsHV/vfio-teardown`
- KVM module config: `modprobe-profiles/current-outlawsHV/kvm.conf`
- Behavior: keeps the current Hyper-V-enlightened performance setup with fixed 32GB explicit hugepages.

To re-activate it after testing recovery:

```bash
sudo ./activate-outlawsHV-profile.sh
```

## Nohyper Recovery Profile

- XML: `win11_nohyper.xml`
- Hooks: `hooks/profiles/nohyper-recovery/vfio-startup` and `hooks/profiles/nohyper-recovery/vfio-teardown`
- KVM module config: `modprobe-profiles/nohyper-recovery/kvm.conf`
- Behavior: restores the original nohyper VM XML and avoids startup hugepage allocation or inactive-domain memory rewrites.

To roll back safely:

```bash
sudo ./recover-nohyper-profile.sh
```

## Safety Notes

Run either switch script only while `win11` is shut off. The recovery script releases any leftover 2MB hugepage pool, removes `/tmp/vfio-restore-vm-ram`, restores THP to `madvise`, installs the nohyper hook pair, installs the nohyper `kvm.conf`, and defines `win11_nohyper.xml` in system libvirt. If a user-session libvirt connection is available, it also attempts to define the same XML there. KVM module option changes require a reboot or KVM module reload before they fully apply.

## OutlawsHV Nohuge Test Profile

- XML: `win11-outlawsHV-nohuge.xml`
- Hooks: `hooks/profiles/outlawsHV-nohuge/vfio-startup` and `hooks/profiles/outlawsHV-nohuge/vfio-teardown`
- Behavior: keeps the OutlawsHV Hyper-V/vapic setup at 32GB RAM, but removes explicit hugetlb hugepages and uses THP-friendly runtime settings.

To activate it:

```bash
sudo ./activate-outlawsHV-nohuge-profile.sh
```
