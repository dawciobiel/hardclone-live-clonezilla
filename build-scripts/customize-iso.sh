#!/usr/bin/env bash
set -euo pipefail

ISO_ROOT="$WORK_DIR/iso-root"

echo "[INFO] Searching for filesystem.squashfs..."
find "$ISO_ROOT" -type f -name "filesystem.squashfs"
