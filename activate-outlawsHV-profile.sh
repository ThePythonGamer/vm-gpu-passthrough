#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_NAME="win11"
XML_FILE="$ROOT_DIR/win11-outlawsHV.xml"
STARTUP_HOOK="$ROOT_DIR/hooks/profiles/current-outlawsHV/vfio-startup"
TEARDOWN_HOOK="$ROOT_DIR/hooks/profiles/current-outlawsHV/vfio-teardown"
KVM_CONF="$ROOT_DIR/modprobe-profiles/current-outlawsHV/kvm.conf"

if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo $0"
    exit 1
fi

VM_STATE="$(virsh --connect qemu:///system domstate "$VM_NAME" 2>/dev/null || true)"
if [ "$VM_STATE" != "shut off" ]; then
    echo "$VM_NAME is not shut off. Current state: ${VM_STATE:-unknown}"
    echo "Shut it down before changing profiles."
    exit 1
fi

install -m 0755 "$STARTUP_HOOK" /usr/local/bin/vfio-startup
install -m 0755 "$TEARDOWN_HOOK" /usr/local/bin/vfio-teardown
install -m 0644 "$KVM_CONF" /etc/modprobe.d/kvm.conf
virsh --connect qemu:///system define "$XML_FILE"

SESSION_USER="${SUDO_USER:-}"
if [ -n "$SESSION_USER" ] && [ "$SESSION_USER" != "root" ]; then
    runuser -u "$SESSION_USER" -- virsh --connect qemu:///session define "$XML_FILE" >/dev/null 2>&1 || \
        echo "Skipped qemu:///session define; system profile was activated."
fi

echo "Activated $VM_NAME with win11-outlawsHV.xml and current hugepage hooks."
echo "Installed OutlawsHV /etc/modprobe.d/kvm.conf. Reboot or reload KVM modules before final testing."
