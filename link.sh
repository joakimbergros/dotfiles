#!/usr/bin/env bash
set -euo pipefail

FORCE=false
DRY_RUN=false

usage() {
    cat <<EOF
This command links all adjacent directories to "$HOME\.config".

Usage: $0 [-d] [-f] [-h]
Options:
  -d    Dry-run (show actions but do not execute them)
  -f    Force replace existing link entry
  -h    Show this help message and exit
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

CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for dir in "$SCRIPT_DIR"/*/; do
    [ -d "$dir" ] || continue

    name="$(basename "$dir")"
    link="$CONFIG_DIR/$name"

    if [ -e "$link" ] || [ -L "$link" ]; then
        if $FORCE; then
            if $DRY_RUN; then
                echo "[dry-run] Would remove: $link"
            else
                echo "Removing existing: $link"
                rm -rf "$link"
            fi
        else
            echo "Skipping: $link already exists (use -f to overwrite)"
            continue
        fi
    fi

    if $DRY_RUN; then
        echo "[dry-run] Would link: $dir -> $link"
    else
        ln -s "$dir" "$link"
        echo "Linked: $dir -> $link"
    fi
done
