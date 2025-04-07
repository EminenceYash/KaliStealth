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
    echo "[*] VPN Mode"
    read -p "Enter full path to your .ovpn file: " vpnfile
    sudo openvpn --config "$vpnfile"
    ;;
  3)
    echo "[*] Disabling Tor & VPN..."
    sudo systemctl stop tor
    echo "Manually stop OpenVPN with Ctrl+C if running"
    ;;
  4)
    echo "[*] Checking IP with proxychains..."
    proxychains curl https://ifconfig.me
    ;;
  5)
    echo "Bye 👋"
    exit 0
    ;;
  *)
    echo "Invalid choice."
    ;;
esac
