#!/usr/bin/env bash
set -euo pipefail

FORCE=false
DRY_RUN=false

# parse args
for arg in "$@"; do
    case "$arg" in
        -f) FORCE=true ;;
        --dry-run) DRY_RUN=true ;;
        *)
            echo "Usage: $0 [-f] [--dry-run]"
            exit 1
            ;;
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
