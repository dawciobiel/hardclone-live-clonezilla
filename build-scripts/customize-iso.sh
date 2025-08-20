#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_ROOT="$WORK_DIR/iso-extract/live/squashfs-root"

if [ ! -d "$ISO_ROOT" ]; then
    echo "Error: $ISO_ROOT not found!"
    exit 1
fi

cd "$WORK_DIR"

echo "Preparing offline DEB packages for installation..."
mkdir -p tmp-debs
cd tmp-debs

# List of packages we want inside ISO
DEB_PACKAGES=("python3-pip" "python3-venv" "python3-dialog" "git" "fish" "sudo")

# Download .deb packages with dependencies (using apt-get download)
apt-get update -qq
for pkg in "${DEB_PACKAGES[@]}"; do
    echo "Downloading $pkg and dependencies..."
    apt-get download $(apt-cache depends --recurse --no-recommends \
                      --no-suggests --no-conflicts --no-breaks \
                      --no-replaces --no-enhances $pkg | grep "^\w" | sort -u)
done

cd "$WORK_DIR"

echo "Extracting downloaded DEB packages into squashfs-root..."
for deb in tmp-debs/*.deb; do
    dpkg-deb -x "$deb" "$ISO_ROOT"
done

# Configure fish and sudoers
echo "/usr/bin/fish" >> "$ISO_ROOT/etc/shells" || true

# Root shell
sed -i 's|^root:[^:]*:|root:/usr/bin/fish:|' "$ISO_ROOT/etc/passwd" || true

# User shell (if exists in /etc/passwd)
if grep -q "^user:" "$ISO_ROOT/etc/passwd"; then
    sed -i 's|^\(user:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\)[^:]*|\1/usr/bin/fish|' "$ISO_ROOT/etc/passwd" || true
fi

# Passwordless sudo
echo 'user ALL=(ALL) NOPASSWD:ALL' >> "$ISO_ROOT/etc/sudoers" || true

echo "Cloning HardClone CLI repository..."
git clone https://github.com/dawciobiel/hardclone-cli.git "$ISO_ROOT/opt/hardclone-cli"
chmod +x "$ISO_ROOT/opt/hardclone-cli/"* 2>/dev/null || true

# First-boot script
mkdir -p "$ISO_ROOT/usr/local/bin" "$ISO_ROOT/var/log"
cat > "$ISO_ROOT/usr/local/bin/first-boot-setup.sh" << 'EOF'
#!/bin/bash
if [ ! -f /var/log/hardclone-setup-done ]; then
    echo "HardClone: First boot setup starting..."
    touch /var/log/hardclone-setup-done
    echo "HardClone: Setup completed"
fi
EOF
chmod +x "$ISO_ROOT/usr/local/bin/first-boot-setup.sh"

echo "Customizations completed successfully."
