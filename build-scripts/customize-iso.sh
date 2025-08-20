#!/bin/bash
set -e

WORK_DIR="${WORK_DIR:-$PWD}"
ISO_ROOT="$WORK_DIR/iso-extract/live/squashfs-root"

if [ ! -d "$ISO_ROOT" ]; then
    echo "Error: $ISO_ROOT not found!"
    exit 1
fi

cd "$ISO_ROOT"

echo "Preparing DEB packages for extraction..."
mkdir -p tmp-debs

# Lista pakietów, które chcemy zainstalować
DEB_PACKAGES=("python3-pip" "python3-venv" "python3-dialog" "git" "fish" "sudo")

# Pobieramy paczki .deb
for pkg in "${DEB_PACKAGES[@]}"; do
    echo "Downloading $pkg..."
    apt download "$pkg" -o=dir::cache=tmp-debs >/dev/null 2>&1 || true
done

echo "Extracting DEB packages into squashfs-root..."
for deb in tmp-debs/*.deb; do
    echo "Extracting $deb..."
    dpkg-deb -x "$deb" "$ISO_ROOT"
done

# Dodajemy fish do /etc/shells i ustawiamy dla root i user
echo "/usr/bin/fish" >> etc/shells || true
if [ -x usr/bin/chsh ]; then
    chsh -s /usr/bin/fish || true
fi

if id user >/dev/null 2>&1; then
    chsh -s /usr/bin/fish user || true
fi

# Konfiguracja sudoers dla user
echo 'user ALL=(ALL) NOPASSWD:ALL' >> etc/sudoers || true

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
