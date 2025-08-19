#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}/clonezilla-custom"
cd "$WORK_DIR"

ISO_NAME="clonezilla-original.iso"
EXTRACT_DIR="iso-extract"

mkdir -p "$EXTRACT_DIR"
echo "Extracting ISO with 7z..."
7z x "$ISO_NAME" -o"$EXTRACT_DIR"

cd "$EXTRACT_DIR/live"
echo "Extracting squashfs filesystem..."
proot -0 unsquashfs -no-xattrs -no-dev -d squashfs-root filesystem.squashfs

echo "Extraction completed: squashfs-root ready"
