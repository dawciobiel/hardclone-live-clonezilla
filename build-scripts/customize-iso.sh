#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Customizing ISO filesystem..."

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_EXTRACT_DIR="$WORK_DIR/iso-extract"
ROOTFS_DIR="$WORK_DIR/rootfs"

# --- Check if extraction exists ---
SQUASHFS_PATH="$(find "$ISO_EXTRACT_DIR" -name "filesystem.squashfs" | head -n 1)"

if [[ -z "$SQUASHFS_PATH" ]]; then
    echo "[ERROR] filesystem.squashfs not found inside $ISO_EXTRACT_DIR"
    echo "Did you run extract-base-iso.sh before this step?"
    exit 1
fi

# --- Extract squashfs to rootfs ---
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"
echo "[INFO] Unpacking filesystem.squashfs..."
unsquashfs -f -d "$ROOTFS_DIR" "$SQUASHFS_PATH"

# --- Apply customizations ---
echo "[INFO] Applying customizations..."
# Example: add offline deb packages
mkdir -p "$WORK_DIR/offline-debs"
cp -r "$WORK_DIR/offline-debs" "$ROOTFS_DIR/tmp/"

# --- Install offline DEB packages ---
DEB_DIR="$WORK_DIR/offline-debs"
if [[ -d "$DEB_DIR" ]]; then
    echo "[INFO] Installing offline DEB packages..."
    # Copy packages into rootfs
    cp -r "$DEB_DIR"/*.deb "$ROOTFS_DIR/tmp/" || true

    # Mount necessary filesystems for chroot
    mount --bind /dev "$ROOTFS_DIR/dev"
    mount --bind /proc "$ROOTFS_DIR/proc"
    mount --bind /sys "$ROOTFS_DIR/sys"

    # Install DEBs inside chroot
    chroot "$ROOTFS_DIR" bash -c "
        dpkg -i /tmp/*.deb || apt-get install -f -y
    "

    # Cleanup
    rm -f "$ROOTFS_DIR/tmp/"*.deb
    umount "$ROOTFS_DIR/dev" || true
    umount "$ROOTFS_DIR/proc" || true
    umount "$ROOTFS_DIR/sys" || true
else
    echo "[WARN] Offline DEB directory not found: $DEB_DIR"
fi

echo "[INFO] Customization completed. Root filesystem is ready at $ROOTFS_DIR"
