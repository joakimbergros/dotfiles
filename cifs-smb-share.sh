#!/usr/bin/env bash

# Usage:
# ./add-network-share.sh [-d] [-f] <share_name> [mount_point]
#   -d  Dry-run (show actions but do not execute them)
#   -f  Force replace existing entry in /etc/fstab
#
# Example:
# ./add-network-share.sh -d -f //nas.local/share1 /mnt/test

set -e

DRY_RUN=false
FORCE=false

usage() {
    cat <<EOF
Usage: $0 [-d] [-f] [-h] <share_name> [mount_point]

Options:
  -d    Dry-run (show actions but do not execute them)
  -f    Force replace existing entry in /etc/fstab
  -h    Show this help message and exit

Arguments:
  share_name   The network share path, e.g. //nas.local/share1
  mount_point  Optional local mount point (default: /mnt/<share_name_leaf>)

Examples:
  $0 //nas.local/share1
  $0 -d -f //nas.local/share1 /mnt/test
EOF
}

# Parse options
while getopts ":hdf" opt; do
    case $opt in
        d) DRY_RUN=true ;;
        f) FORCE=true ;;
        h) usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

SHARE="$1"
MOUNT_POINT="$2"
CREDENTIALS_FILE="$HOME/.smbcredentials"

if [[ -z "$SHARE" ]]; then
    usage
    exit 1
fi

# Extract default mount point from the share path
if [[ -z "$MOUNT_POINT" ]]; then
    LEAF_NAME="$(basename "$SHARE")"
    MOUNT_POINT="/mnt/$LEAF_NAME"
fi

# Expand tilde in credentials path
CREDENTIALS_FILE="${CREDENTIALS_FILE/#\~/$HOME}"

# Build mount options
OPTIONS="credentials=$CREDENTIALS_FILE,_netdev,x-systemd.automount,iocharset=utf8"
FSTAB_LINE="$SHARE  $MOUNT_POINT  cifs  $OPTIONS  0  0"

# Check if fstab already contains this share
if grep -qF "$SHARE" /etc/fstab; then
    if [[ "$FORCE" == true ]]; then
        echo "Entry for $SHARE already exists. Would replace (force enabled)."
        if [[ "$DRY_RUN" == false ]]; then
            sudo sed -i.bak "\|$SHARE|d" /etc/fstab
        fi
    else
        echo "Entry for $SHARE already exists in /etc/fstab. Skipping."
        exit 0
    fi
fi

# Create mount point if it doesn't exist
if [[ ! -d "$MOUNT_POINT" ]]; then
    echo "Would create mount point at $MOUNT_POINT..."
    if [[ "$DRY_RUN" == false ]]; then
        sudo mkdir -p "$MOUNT_POINT"
    fi
else
    echo "Mount point $MOUNT_POINT already exists."
fi

# Warn if the credentials file doesn't exist
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
    echo "WARNING: Credentials file '$CREDENTIALS_FILE' does not exist."
    echo "Please create it with:"
    echo "  username=your_username"
    echo "  password=your_password"
    echo "Then run: chmod 600 $CREDENTIALS_FILE"
fi

# Append to /etc/fstab
echo "Would add the following line to /etc/fstab:"
echo "$FSTAB_LINE"

if [[ "$DRY_RUN" == false ]]; then
    echo "$FSTAB_LINE" | sudo tee -a /etc/fstab > /dev/null
    echo "Done. You can now run 'sudo mount $MOUNT_POINT' or reboot."
else
    echo "(dry-run mode: nothing written to /etc/fstab)"
fi
