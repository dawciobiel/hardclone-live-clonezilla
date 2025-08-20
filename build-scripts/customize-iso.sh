#!/usr/bin/env bash
set -euo pipefail

# --- Variables ---
WORK_DIR="${WORK_DIR:-$PWD/work}"
ISO_EXTRACT_DIR="$WORK_DIR/iso-root"
CHROOT_DIR="$WORK_DIR/chroot"

# --- Make dirs ---
mkdir -p "$CHROOT_DIR"

echo "[INFO] Unpacking filesystem.squashfs..."
# Extract squashfs
unsquashfs -f -d "$CHROOT_DIR" "$ISO_EXTRACT_DIR/live/filesystem.squashfs"

echo "[INFO] Installing packages inside extracted rootfs with proot..."
# Copy resolv.conf for network
cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"

# Update apt and install packages inside rootfs using proot
proot -0 -r "$CHROOT_DIR" /bin/bash -c "
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y \
    python3-pip \
    python3-venv \
    python3-dialog \
    git \
    fish \
    sudo
  apt-get clean
"

echo "[INFO] Rebuilding filesystem.squashfs..."
# Repack squashfs with changes
mksquashfs "$CHROOT_DIR" "$ISO_EXTRACT_DIR/live/filesystem.squashfs" -comp xz -noappend

echo "[INFO] Customization done!"
