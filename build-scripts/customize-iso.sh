#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Customizing ISO..."

# Paths
WORK_DIR="${WORK_DIR:-$PWD}"
ISO_EXTRACT_DIR="$WORK_DIR/iso-root"
CUSTOM_DIR="$WORK_DIR/custom"

# Clean up old directories if exist
rm -rf "$ISO_EXTRACT_DIR" "$CUSTOM_DIR"
mkdir -p "$ISO_EXTRACT_DIR" "$CUSTOM_DIR"

echo "[INFO] Extracting ISO..."
7z x "$WORK_DIR/base.iso" -o"$ISO_EXTRACT_DIR" >/dev/null

# Locate squashfs
echo "[INFO] Searching for filesystem.squashfs..."
SQUASHFS_PATH=$(find "$ISO_EXTRACT_DIR" -name "filesystem.squashfs" -o -name "*.squashfs" | head -n 1 || true)

if [[ -z "$SQUASHFS_PATH" ]]; then
    echo "[ERROR] Could not find filesystem.squashfs!"
    exit 1
fi

echo "[INFO] Found squashfs at: $SQUASHFS_PATH"

# Extract squashfs
echo "[INFO] Extracting squashfs..."
unsquashfs -f -d "$CUSTOM_DIR" "$SQUASHFS_PATH"

# --- Customization section ---
echo "[INFO] Applying custom changes..."

# Example: add a file
echo "Hardclone Custom Build" > "$CUSTOM_DIR/etc/hardclone.txt"

# Example: install extra packages
proot -R "$CUSTOM_DIR" apt-get update
proot -R "$CUSTOM_DIR" apt-get install -y \
    python3 python3-pip python3-venv git fish xxd dialog

# --- End customization ---

# Repack squashfs
echo "[INFO] Repacking squashfs..."
mksquashfs "$CUSTOM_DIR" "$SQUASHFS_PATH" -noappend -comp xz

# Rebuild ISO
echo "[INFO] Rebuilding ISO..."
NEW_ISO="$WORK_DIR/custom.iso"
xorriso -as mkisofs \
    -o "$NEW_ISO" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e EFI/boot/bootx64.efi \
    -no-emul-boot \
    "$ISO_EXTRACT_DIR"

echo "[INFO] Custom ISO built at: $NEW_ISO"
