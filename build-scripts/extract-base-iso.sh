#!/bin/bash
set -e

WORK_DIR="/workspace/clonezilla-custom"
cd "$WORK_DIR"

echo "Extracting Clonezilla ISO..."
mkdir -p iso-extract
7z x clonezilla-original.iso -oiso-extract

cd iso-extract/live
echo "Extracting squashfs filesystem..."
unsquashfs filesystem.squashfs

echo "Extraction completed: squashfs-root ready"
