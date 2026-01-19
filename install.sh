#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing packages..."
sudo apt update
sudo apt install -y tcpdump tshark arpwatch openssh-server git

echo "[*] Enabling SSH..."
sudo systemctl enable --now ssh

echo "[*] Creating directories..."
sudo mkdir -p /opt/dropbox
sudo mkdir -p /var/log/dropbox/pcap /var/log/dropbox/reports
sudo chown -R "$USER:$USER" /opt/dropbox
sudo chmod 755 /var/log/dropbox /var/log/dropbox/pcap /var/log/dropbox/reports

echo "[*] Installing scripts to /opt/dropbox..."
sudo cp -f scripts/*.sh /opt/dropbox/
sudo chmod +x /opt/dropbox/*.sh

echo "[*] Installing systemd units..."
sudo cp -f systemd/*.service /etc/systemd/system/
sudo cp -f systemd/*.timer /etc/systemd/system/ || true

echo "[*] Reloading systemd..."
sudo systemctl daemon-reload

echo "[*] Enabling + starting capture..."
sudo systemctl enable --now dropbox-capture.service

echo "[*] Enabling report timer (if present)..."
if ls systemd/*.timer >/dev/null 2>&1; then
  sudo systemctl enable --now dropbox-report.timer
fi

echo
echo "[✓] Install complete."
echo "[*] Verify:"
echo "    systemctl status dropbox-capture.service --no-pager"
echo "    systemctl list-timers --all | grep dropbox"
echo "    ls -lh /var/log/dropbox/pcap | tail"
