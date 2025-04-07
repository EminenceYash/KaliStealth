#!/bin/bash

echo "[*] Updating and installing tools..."
sudo apt update && sudo apt install -y tor proxychains4 macchanger openvpn curl wget net-tools

echo "[*] Enabling Tor on boot..."
sudo systemctl enable tor

echo "[*] Configuring Proxychains for Tor..."
sudo sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains.conf
sudo sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains.conf
sudo sed -i 's/^# socks5 127.0.0.1 9050/socks5 127.0.0.1 9050/' /etc/proxychains.conf

echo "[*] Setting MAC spoofing on interface..."

INTERFACE="eth0"
if ! ip link show $INTERFACE &>/dev/null; then
  INTERFACE=$(ip link show | grep -E '^[0-9]+: e' | cut -d: -f2 | awk '{print $1}' | head -n1)
fi

sudo ip link set $INTERFACE down
sudo macchanger -r $INTERFACE
sudo ip link set $INTERFACE up

echo "[*] Creating MAC spoofing at boot..."
cat <<EOF | sudo tee /etc/network/if-pre-up.d/macspoof
#!/bin/bash
/usr/bin/macchanger -r $INTERFACE
EOF

sudo chmod +x /etc/network/if-pre-up.d/macspoof

echo "[*] Creating quick-use aliases..."
echo 'alias toron="sudo systemctl start tor"' >> ~/.bashrc
echo 'alias toroff="sudo systemctl stop tor"' >> ~/.bashrc
echo 'alias ipcheck="proxychains curl https://ifconfig.me"' >> ~/.bashrc
source ~/.bashrc

echo "[+] Base setup complete."
