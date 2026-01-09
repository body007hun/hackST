#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

clear

HOSTNAME=$(hostname)
DATE=$(date)
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}')
SSH_IFACE=$(ip route get 1 | grep -oP 'dev \K\S+')
MAIN_IP=$(ip -4 addr show $SSH_IFACE | grep inet | awk '{print $2}')
PREFIX=$(echo $MAIN_IP | cut -d'/' -f2)
ADDR=$(echo $MAIN_IP | cut -d'/' -f1)
OCT1=$(echo $ADDR | cut -d'.' -f1)
OCT2=$(echo $ADDR | cut -d'.' -f2)
OCT3=$(echo $ADDR | cut -d'.' -f3)
DEFAULT_NET="$OCT1.$OCT2.$OCT3.0/$PREFIX"
GW=$(ip route | grep default | awk '{print $3}')
DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
DISKS=$(lsblk | sed 's/^/  /')

# Kiírás
log_info "HackStation Főmenü – $HOSTNAME ($DATE)"
echo ""
log_info "Interfészek és IP címek:"
for iface in $INTERFACES; do
  ip_addr=$(ip -o -f inet addr show $iface | awk '{print $4}')
  if [ -n "$ip_addr" ]; then
    echo "  🌐 $iface: $ip_addr"
  else
    echo "  ⚪ $iface: nincs IP"
  fi
done

echo ""
log_info "SSH interfész: $SSH_IFACE (NE állítsd monitor módba!)"
echo "🚪 Gateway: $GW"
echo "🧭 DNS: $DNS"
echo "🌍 Alhálózat: $DEFAULT_NET"
echo ""
log_info "Lemezek:"
echo "$DISKS"

echo ""
log_info "📁 Mentések: /root/outputs/"
last_out=$(ls -t /root/outputs/ 2>/dev/null | head -n1)
[ -n "$last_out" ] && log_info "🕑 Utolsó mentés: $last_out"

# Menü
echo ""
echo "Válassz egy opciót:"
echo "s) Rendszereszközök / beállítások"
echo ""
echo "1) Nmap szkennelés"
echo "2) TCPdump indítása"
echo "3) Aircrack-ng monitor mód"
echo "4) ARP-scan futtatása"
echo "5) Hydra"
echo "6) John the Ripper (JtR)"
echo "7) Netdiscover"
echo "8) Defensive OSINT / Audit"
echo "9) Kilépés"
echo ""
read -p "Választás: " opt


MODULE_PATH="/usr/local/bin/hackstation/modules"

case $opt in
  s|S) "$MODULE_PATH/system.sh" ;;
  1) "$MODULE_PATH/nmap.sh" "$DEFAULT_NET" ;;
  2) "$MODULE_PATH/tcpdump_module.sh" ;;
  3) "$MODULE_PATH/aircrack.sh" ;;
  4) "$MODULE_PATH/arp_scan.sh" "$DEFAULT_NET" ;;
  5) "$MODULE_PATH/hydra.sh" ;;
  6) "$MODULE_PATH/john.sh" ;;
  7) "$MODULE_PATH/netdiscover_module.sh" ;;
  8) "$MODULE_PATH/osint_defensive.sh" ;;
  9) exit 0 ;;
  *) log_err "Érvénytelen választás." ;;
esac
