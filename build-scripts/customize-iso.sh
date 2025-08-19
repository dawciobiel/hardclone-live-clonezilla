#!/bin/bash
set -e

echo "=== Starting ISO customization ==="

# --- 1️⃣ Install additional packages and set fish as default shell ---
echo "Installing additional packages inside squashfs-root..."
apt-get update && apt-get install -y python3-pip python3-venv python3-dialog git xxd fish

echo "/usr/bin/fish" >> /etc/shells
chsh -s /usr/bin/fish root || true
if id -u user >/dev/null 2>&1; then
    chsh -s /usr/bin/fish user || true
fi

# --- 2️⃣ Clone HardClone applications ---
HARDCLONE_CLI_REPO="https://github.com/dawciobiel/hardclone-cli.git"
# HARDCLONE_GUI_REPO="https://github.com/dawciobiel/hardclone-gui.git"

echo "Cloning HardClone CLI application..."
git clone "$HARDCLONE_CLI_REPO" opt/hardclone-cli
chmod +x opt/hardclone-cli/* 2>/dev/null || true

# Uncomment if GUI is needed
# git clone "$HARDCLONE_GUI_REPO" opt/hardclone-gui
# chmod +x opt/hardclone-gui/* 2>/dev/null || true

# --- 3️⃣ Create first-boot setup script ---
mkdir -p usr/local/bin var/log

cat > usr/local/bin/first-boot-setup.sh << 'FBEOF'
#!/bin/bash
if [ ! -f /var/log/hardclone-setup-done ]; then
    echo "HardClone: First boot setup running ..."
    touch /var/log/hardclone-setup-done
    echo "HardClone: Setup completed"
fi
FBEOF

chmod +x usr/local/bin/first-boot-setup.sh

# --- 4️⃣ Create network auto-setup script ---
cat > usr/local/bin/network-setup.sh << 'NETEOF'
#!/bin/bash
sleep 5
dhclient eth0 2>/dev/null || dhclient 2>/dev/null &
sleep 10
apt update &
NETEOF

chmod +x usr/local/bin/network-setup.sh

# Add to startup
echo "/usr/local/bin/network-setup.sh &" >> etc/rc.local
echo "/usr/local/bin/network-setup.sh &" >> etc/bash.bashrc

# --- 5️⃣ Create desktop shortcuts ---
mkdir -p home/user/Desktop

cat > home/user/Desktop/HardClone-CLI.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=HardClone CLI
Comment=Command line backup tool
Exec=/opt/hardclone-cli/hardclone
Icon=utilities-terminal
Terminal=true
Categories=System;
EOF

chmod +x home/user/Desktop/*.desktop

# --- 6️⃣ Update PATH and MOTD ---
echo 'export PATH="/opt/hardclone-cli:$PATH"' >> etc/bash.bashrc
echo "HardClone Live - Custom Clonezilla Distribution" > etc/motd

echo "=== ISO customization completed successfully ==="
