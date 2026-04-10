#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

clear

HOSTNAME=$(hostname)
DATE=$(date)
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}')
SSH_IFACE=$(ip route get 1 2>/dev/null | grep -oE 'dev [^ ]+' | awk '{print $2}')
[ -z "$SSH_IFACE" ] && SSH_IFACE="wlan0"

MAIN_IP=$(ip -4 addr show "$SSH_IFACE" 2>/dev/null | awk '/inet / {print $2}' | head -n1)
PREFIX=$(echo "$MAIN_IP" | cut -d'/' -f2)
ADDR=$(echo "$MAIN_IP" | cut -d'/' -f1)

if [ -n "$ADDR" ] && [ -n "$PREFIX" ]; then
  OCT1=$(echo "$ADDR" | cut -d'.' -f1)
  OCT2=$(echo "$ADDR" | cut -d'.' -f2)
  OCT3=$(echo "$ADDR" | cut -d'.' -f3)
  DEFAULT_NET="$OCT1.$OCT2.$OCT3.0/$PREFIX"
else
  DEFAULT_NET="192.168.1.0/24"
fi

GW=$(ip route | awk '/default/ {print $3}' | head -n1)
DNS=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | paste -sd ', ' -)
DISKS=$(lsblk | sed 's/^/  /')

OUTPUT_DIR="$(get_output_dir)"
MODULE_PATH="/usr/local/bin/hackstation/modules"
MENU_PATH="/usr/local/bin/hackstation/menus"

log_info "HackStation Főmenü – $HOSTNAME ($DATE)"
echo ""
log_info "Interfészek és IP címek:"
for iface in $INTERFACES; do
  ip_addr=$(ip -o -f inet addr show "$iface" | awk '{print $4}')
  if [ -n "$ip_addr" ]; then
    echo "  🌐 $iface: $ip_addr"
  else
    echo "  ⚪ $iface: nincs IP"
  fi
done

echo ""
log_info "SSH interfész: $SSH_IFACE (NE állítsd monitor módba!)"
echo "🚪 Gateway: ${GW:-nincs}"
echo "🧭 DNS: ${DNS:-nincs}"
echo "🌍 Alhálózat: $DEFAULT_NET"
echo ""

log_info "Lemezek:"
echo "$DISKS"
echo ""

log_info "📁 Mentések: $OUTPUT_DIR"
last_out=$(ls -t "$OUTPUT_DIR"/ 2>/dev/null | head -n1)
[ -n "$last_out" ] && log_info "🕑 Utolsó mentés: $last_out"

echo ""
echo "Válassz kategóriát:"
echo "1) Hálózati felderítés"
echo "2) Forgalom és csomagelemzés"
echo "3) Wi-Fi"
echo "4) Web audit"
echo "5) OSINT / DNS"
echo "6) Hitelesítés / hash"
echo "7) SMB / belső háló"
echo "8) Forensics / artifact"
echo "9) Rendszer / output / mentés"
echo "0) Kilépés"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MENU_PATH/menu_network.sh" "$DEFAULT_NET" ;;
  2) "$MENU_PATH/menu_packets.sh" ;;
  3) "$MENU_PATH/menu_wifi.sh" ;;
  4) "$MENU_PATH/menu_web.sh" ;;
  5) "$MENU_PATH/menu_osint.sh" ;;
  6) "$MENU_PATH/menu_auth.sh" ;;
  7) "$MENU_PATH/menu_smb.sh" ;;
  8) "$MENU_PATH/menu_forensics.sh" ;;
  9) "$MENU_PATH/menu_system.sh" ;;
  0) exit 0 ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0

