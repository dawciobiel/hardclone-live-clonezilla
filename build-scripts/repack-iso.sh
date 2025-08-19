#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}/clonezilla-custom"
ISO_NAME="hardclone-live-clonezilla-$(date +%Y%m%d).iso"
OUT_ISO="$WORK_DIR/$ISO_NAME"

cd "$WORK_DIR/iso-extract/live"

echo "Repackaging filesystem..."
rm -f filesystem.squashfs
mksquashfs squashfs-root filesystem.squashfs -comp xz -Xbcj x86
rm -rf squashfs-root

cd ..

echo "Updating boot configs..."
sed -i 's/Clonezilla live/HardClone Live/g' isolinux/isolinux.cfg 2>/dev/null || true
sed -i 's/Clonezilla/HardClone/g' boot/grub/grub.cfg 2>/dev/null || true

ISOLINUX_BIN=$(find . -name "isolinux.bin" -type f | head -1)
EFI_IMG=$(find . -name "efi.img" -o -name "*.efi" | head -1)

echo "Building ISO..."
if [ -n "$ISOLINUX_BIN" ] && [ -n "$EFI_IMG" ]; then
    ISOLINUX_DIR=$(dirname "${ISOLINUX_BIN#./}")
    xorriso -as mkisofs \
        -r -V "HARDCLONE-LIVE" \
        -J -l \
        -b "${ISOLINUX_BIN#./}" \
        -c "${ISOLINUX_DIR}/boot.cat" \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot \
        -e "${EFI_IMG#./}" \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -o "$OUT_ISO" .
else
    echo "Boot files not found, creating basic ISO..."
    xorriso -as mkisofs \
        -r -V "HARDCLONE-LIVE" \
        -J -l \
        -o "$OUT_ISO" .
fi

echo "ISO created: $OUT_ISO"
ls -lh "$OUT_ISO"
