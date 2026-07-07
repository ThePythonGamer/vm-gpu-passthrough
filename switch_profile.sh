#!/bin/bash
# switch_profile.sh

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo ./switch_profile.sh)"
  exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: sudo ./switch_profile.sh <branch_or_tag_name> [xml_filename]"
    echo "Example: sudo ./switch_profile.sh v1.0-outlaws-archive win11-outlaws.xml"
    echo "Example: sudo ./switch_profile.sh master"
    exit 1
fi

PROFILE="$1"
XML_FILE="${2:-win11.xml}"

if ! git rev-parse --verify "$PROFILE" >/dev/null 2>&1; then
    echo "Error: Branch or tag '$PROFILE' not found."
    exit 1
fi

echo "Deploying profile from: $PROFILE"

# Create a temporary staging directory
TMP_DIR=$(mktemp -d)

# Extract the entire target branch into the temporary directory
# This prevents modifying your current active workspace!
git archive --format=tar "$PROFILE" | tar -x -C "$TMP_DIR"

cd "$TMP_DIR" || exit 1

# Run the installation script from the target branch
if [ -f "install_hooks.sh" ]; then
    chmod +x install_hooks.sh
    ./install_hooks.sh
else
    echo "Warning: No install_hooks.sh found in this profile."
fi

# Explicitly define the XML (this ensures older tags that didn't auto-define still work)
if [ -f "$XML_FILE" ]; then
    echo "Defining VM from $XML_FILE..."
    virsh define "$XML_FILE"
else
    echo "Warning: XML file '$XML_FILE' not found in $PROFILE. Hooks were updated, but XML was skipped."
fi

# Clean up
cd - >/dev/null || exit 1
rm -rf "$TMP_DIR"

echo "Successfully switched system to profile: $PROFILE"
