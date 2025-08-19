#!/usr/bin/env bash
set -e

echo "[INFO] Building new ISO..."
mkdir -p artifacts
xorriso -as mkisofs \
  -o artifacts/hardclone-live.iso \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -c isolinux/boot.cat \
  -b isolinux/isolinux.bin \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  iso_root

