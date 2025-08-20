#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_ROOT="$WORK_DIR/iso-extract/live/squashfs-root"

if [ ! -d "$ISO_ROOT" ]; then
    echo "Error: $ISO_ROOT not found!"
    exit 1
fi

cd "$ISO_ROOT"

echo "Preparing offline DEB packages for installation..."
mkdir -p tmp-debs

# List of packages to install
DEB_PACKAGES=("python3-pip" "python3-venv" "python3-dialog" "git" "fish" "sudo")

# Use apt-rdepends to get full dependency tree and download all packages
for pkg in "${DEB_PACKAGES[@]}"; do
    echo "Resolving dependencies for $pkg..."
    apt-get update -qq
    apt-get install --print-uris --yes --reinstall --download-only $pkg | \
        grep -Eo "http[s]?://[^\']+" | \
        xargs -n1 -P4 wget -q -P tmp-debs/
done

echo "Extracting downloaded DEB packages into squashfs-root..."
for deb in tmp-debs/*.deb; do
    echo "Extracting $deb..."
    dpkg-deb -x "$deb" "$ISO_ROOT"
done

# Add fish to /etc/shells and set as default for root and user
echo "/usr/bin/fish" >> etc/shells || true

if [ -x usr/bin/chsh ]; then
    chsh -s /usr/bin/fish || true
fi

if id user >/dev/null 2>&1; then
    chsh -s /usr/bin/fish user || true
fi

# Configure sudoers for user without password
echo 'user ALL=(ALL) NOPASSWD:ALL' >> etc/sudoers || true

echo "Cloning HardClone CLI repository..."
git clone https://github.com/dawciobiel/hardclone-cli.git opt/hardclone-cli
chmod +x opt/hardclone-cli/* 2>/dev/null || true

# Optional: first-boot script
mkdir -p usr/local/bin var/log
cat > usr/local/bin/first-boot-setup.sh << 'EOF'
#!/bin/bash
if [ ! -f /var/log/hardclone-setup-done ]; then
    echo "HardClone: First boot setup starting..."
    touch /var/log/hardclone-setup-done
    echo "HardClone: Setup completed"
fi
EOF
chmod +x usr/local/bin/first-boot-setup.sh

echo "Customizations completed successfully."
