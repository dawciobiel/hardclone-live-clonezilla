#!/bin/bash
set -euo pipefail

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_ROOT="$WORK_DIR/iso-extract/live/squashfs-root"
USER_NAME="user"

if [ ! -d "$ISO_ROOT" ]; then
    echo "Error: $ISO_ROOT not found!"
    exit 1
fi

cd "$ISO_ROOT"

echo "=== Installing proot for userland emulation ==="
if ! command -v proot >/dev/null 2>&1; then
    apt-get update
    apt-get install -y proot
fi

echo "=== Installing additional packages inside squashfs-root ==="
proot -R "$ISO_ROOT" /bin/bash -c "
set -e
export DEBIAN_FRONTEND=noninteractive

# Update package list
apt update -qq || true

# Install packages if missing
for pkg in python3-pip python3-venv python3-dialog git fish sudo; do
    dpkg -s \$pkg >/dev/null 2>&1 || apt install -y \$pkg
done

# Set fish as default shell
grep -qxF '/usr/bin/fish' /etc/shells || echo '/usr/bin/fish' >> /etc/shells
chsh -s /usr/bin/fish root || true
if id -u $USER_NAME >/dev/null 2>&1; then
    chsh -s /usr/bin/fish $USER_NAME || true
fi

# Give passwordless sudo to user
grep -qxF '$USER_NAME ALL=(ALL) NOPASSWD:ALL' /etc/sudoers || echo '$USER_NAME ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
"

echo "=== Cloning HardClone CLI inside squashfs-root ==="
proot -R "$ISO_ROOT" /bin/bash -c "
set -e
mkdir -p /opt
if [ ! -d /opt/hardclone-cli ]; then
    git clone https://github.com/dawciobiel/hardclone-cli.git /opt/hardclone-cli
    chmod +x /opt/hardclone-cli/* || true
fi
"

echo "=== Creating first-boot setup script ==="
mkdir -p usr/local/bin var/log
cat > usr/local/bin/first-boot-setup.sh << 'EOF'
#!/bin/bash
if [ ! -f /var/log/hardclone-setup-done ]; then
    echo "HardClone: First boot setup ..."
    touch /var/log/hardclone-setup-done
    echo "HardClone: Setup completed"
fi
EOF
chmod +x usr/local/bin/first-boot-setup.sh

echo "=== ISO customization done ==="
