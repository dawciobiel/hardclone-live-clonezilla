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
echo "DEBUG: checking folder [ $(pwd) ] content:"
ls -l

echo "Extracting squashfs filesystem..."
proot -0 unsquashfs -d squashfs-root -no-xattrs -no-dev filesystem.squashfs

echo "Extraction completed: squashfs-root ready"
