#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_ROOT="$WORK_DIR/iso-extract/live/squashfs-root"

if [ ! -d "$ISO_ROOT" ]; then
    echo "Error: $ISO_ROOT not found!"
    exit 1
fi

cd "$ISO_ROOT"

echo "Installing proot for userland emulation..."
apt-get update && apt-get install -y proot || true

echo "Installing additional packages inside squashfs-root..."
proot -R "$ISO_ROOT" /bin/bash -c "
  set -e
  export DEBIAN_FRONTEND=noninteractive
  apt update 2>/dev/null || true
  apt install -y python3-pip python3-venv python3-dialog git fish sudo 2>/dev/null || true
  echo '/usr/bin/fish' >> /etc/shells || true
  chsh -s /usr/bin/fish root || true
  if id -u user >/dev/null 2>&1; then
    chsh -s /usr/bin/fish user || true
  fi
  echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers || true
"

echo "Cloning HardClone CLI..."
git clone https://github.com/dawciobiel/hardclone-cli.git opt/hardclone-cli
chmod +x opt/hardclone-cli/* 2>/dev/null || true

# Optional: first-boot script
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

echo "Customizations done."
