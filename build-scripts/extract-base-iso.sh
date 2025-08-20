#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_FILE="$WORK_DIR/clonezilla-custom/clonezilla-original.iso"
EXTRACT_DIR="$WORK_DIR/iso-extract"
SQUASHFS_ROOT="$EXTRACT_DIR/live/squashfs-root"

echo "Cleaning old extraction..."
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR/live"

echo "Extracting ISO with 7z (skip existing files)..."
7z x -aos "$ISO_FILE" -o"$EXTRACT_DIR"

echo "Extracting squashfs filesystem..."
mkdir -p "$SQUASHFS_ROOT"
unsquashfs -d "$SQUASHFS_ROOT" "$EXTRACT_DIR/live/filesystem.squashfs"

echo "Extraction completed: squashfs-root ready"
