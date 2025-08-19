#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_ROOT="$PWD/squashfs-root"

cd "$ISO_ROOT"

echo "Installing additional packages inside squashfs-root..."
apt-get update && apt-get install -y proot

proot -R . /bin/bash -c "
  apt update
  apt install -y python3-pip python3-venv python3-dialog git fish
  echo '/usr/bin/fish' >> /etc/shells
  chsh -s /usr/bin/fish root || true
  if id -u user >/dev/null 2>&1; then
    chsh -s /usr/bin/fish user || true
  fi
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
