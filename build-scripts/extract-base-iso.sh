#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}/clonezilla-custom"
cd "$WORK_DIR"

ISO_NAME="clonezilla-original.iso"
EXTRACT_DIR="iso-extract"

mkdir -p "$EXTRACT_DIR"
echo "Extracting ISO with 7z..."
rm -rf "$EXTRACT_DIR"
7z x -y "$ISO_NAME" -o"$EXTRACT_DIR"

cd "$EXTRACT_DIR/live"

echo "DEBUG: checking folder [ $(pwd) ] content:"
ls -l

echo "Extracting squashfs filesystem..."
# We ignore Xattr and force Exit code 0 despite non-critical errors (e.g. /dev /*)
unsquashfs -no-xattrs -no-exit-code -d squashfs-root filesystem.squashfs

echo "Extraction completed: squashfs-root ready"
