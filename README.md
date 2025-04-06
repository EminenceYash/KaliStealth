Hell yeah, now we’re building your Ultimate Kali VM from Zero to Stealth God Mode. 🥷💻🔥
You don’t need to know much right now — I’ll walk you step-by-step, with scripts, tools, and explanations. No fluff, just power.

🔥 MASTER PLAN OVERVIEW
Here’s what we’re setting up:

✅ Kali Installation (clean, secure)

🔐 Isolation + Security (VM-only, no host leakage)

🌐 Internet Access with:

🧅 Tor Mode (anonymity)

🚀 VPN Mode (speed)

🔄 Switching between both

🧰 Scripted Tools for auto-setup, MAC spoofing, proxy, aliases

🕹️ Easy interactive mode switcher script

📂 Bonus: Folder & config structure

🧱 STEP 1: Kali Setup in VirtualBox (Only Do Once)
Create a New VM:

Name: Kali Linux

RAM: 4GB+

CPU: 2+

Storage: 40GB dynamically allocated

Network: NAT (for now)

Download Kali ISO: https://www.kali.org/get-kali/ → “Installer” version

Boot the ISO → Graphical Install

During setup:

Create user kali (not root)

Use manual partitioning if you want to get fancy, or auto-use entire disk

When done, reboot, log in as kali

🧰 STEP 2: Setup Script (Run This First)
🔧 kali-setup.sh
_____________________________________________________________________________________________________________
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
________________________________________________________________________________________

🧃 STEP 3: VPN Config (ProtonVPN – Free & Easy)
A. Register ProtonVPN free account
👉 https://protonvpn.com

B. Download a config:
Go to ProtonVPN dashboard

→ Downloads → OpenVPN

Select:

Platform: Linux

Protocol: UDP

Country: any (pick a fast one)

Download .ovpn file (e.g., us-free-01.ovpn)

C. Move to Kali & test:
__________________________________________________________________________________________________
cd ~/Downloads
sudo openvpn --config us-free-01.ovpn
________________________________________________________________________________________________
If it connects, you’re golden.

🧭 STEP 4: Mode Switcher Script (Choose: VPN / Tor / Direct)
🧠 network-mode.sh
_________________________________________________________________________________________________
#!/bin/bash

echo "=== Network Mode Switcher ==="
echo "1. Tor Mode (proxychains)"
echo "2. VPN Mode (OpenVPN)"
echo "3. Direct Mode (No VPN or Tor)"
echo "4. Check External IP"
echo "5. Exit"
read -p "Choose your mode: " mode

case $mode in
  1)
    echo "[*] Starting Tor..."
    sudo systemctl start tor
    echo "Use commands like: proxychains curl https://ifconfig.me"
    ;;
  2)
    read -p "Enter path to your .ovpn file: " vpnfile
    echo "[*] Connecting to VPN..."
    sudo openvpn --config "$vpnfile"
    ;;
  3)
    echo "[*] Disabling Tor & VPN..."
    sudo systemctl stop tor
    echo "Manually stop OpenVPN with Ctrl+C if running"
    ;;
  4)
    echo "[*] Checking IP with Tor (proxychains)..."
    proxychains curl https://ifconfig.me
    ;;
  5)
    echo "Bye 🫡"
    exit 0
    ;;
  *)
    echo "Invalid choice."
    ;;
esac
____________________________________________________________
📁 STEP 5: Folder Structure (Your lab gear)
_____________________________________________________________
~/kali-lab/
├── vpn-configs/
│   └── us-free-01.ovpn
├── scripts/
│   ├── kali-setup.sh
│   └── network-mode.sh
└── results/
    └── scans, captures, logs etc.
    _____________________________________________________________
🧪 FINAL TESTS
✅ Run setup:
_______________________________________________________________________________________________
chmod +x kali-setup.sh
./kali-setup.sh
_________________________________________________________________________________________________
✅ Switch network modes easily:

______________________________________________________________
chmod +x network-mode.sh
./network-mode.sh
_____________________________________________________________
✅ Check your IP:

In Tor mode: proxychains curl ifconfig.me

In VPN mode: curl ifconfig.me

✅ MAC is spoofed on every boot:

___________________________________________________________
macchanger -s eth0
________________________________________________
💭 You're Ready
You now have:

🔒 A hardened Kali VM

🧅 Tor for stealth ops

🚀 VPN for speed

🔁 One-click mode switching

🧰 Aliases, auto MAC spoof, firewall potential


Wanna take it further?

Add a Whonix gateway

Use Kasm/Firejail for app sandboxing

Create a snapshot & backup script
