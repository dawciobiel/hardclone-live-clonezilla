#!/bin/bash
set -e

WORK_DIR="${GITHUB_WORKSPACE:-$(pwd)}"
mkdir -p "$WORK_DIR/clonezilla-custom"
cd "$WORK_DIR/clonezilla-custom"

# Get latest Clonezilla version
CLONEZILLA_VERSION=$(curl -s "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/" \
  | grep -o 'href="/projects/clonezilla/files/clonezilla_live_stable/[0-9][^/]*' \
  | head -1 | cut -d'/' -f6)
echo "Latest Clonezilla version: $CLONEZILLA_VERSION"

CLONEZILLA_URL="https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/${CLONEZILLA_VERSION}/clonezilla-live-${CLONEZILLA_VERSION}-amd64.iso/download"

echo "Downloading Clonezilla ISO..."
wget -O clonezilla-original.iso "$CLONEZILLA_URL"

echo "Download completed: clonezilla-original.iso"
