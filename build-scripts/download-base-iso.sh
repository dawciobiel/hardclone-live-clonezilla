#!/bin/bash
set -e

# Set working directory
WORK_DIR="${WORK_DIR:-$PWD}/clonezilla-custom"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "Getting latest Clonezilla version..."
CLONEZILLA_VERSION=$(curl -s "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/" \
    | grep -o 'href="/projects/clonezilla/files/clonezilla_live_stable/[0-9][^/]*' \
    | head -1 | cut -d'/' -f6)
echo "Latest version: $CLONEZILLA_VERSION"

CLONEZILLA_URL="https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/${CLONEZILLA_VERSION}/clonezilla-live-${CLONEZILLA_VERSION}-amd64.iso/download"
ISO_NAME="clonezilla-original.iso"

echo "Downloading Clonezilla ISO..."
wget -O "$ISO_NAME" "$CLONEZILLA_URL"
echo "Downloaded ISO: $WORK_DIR/$ISO_NAME"
