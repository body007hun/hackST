#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_NET=${1:-"192.168.1.0/24"}
MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Hálózati felderítés"
echo "--------------------------------"
echo "1) Nmap"
echo "2) Masscan"
echo "3) Rustscan"
echo "4) ARP-scan"
echo "5) Netdiscover"
echo "6) fping"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/nmap.sh" "$DEFAULT_NET" ;;
  2) "$MODULE_PATH/masscan.sh" "$DEFAULT_NET" ;;
  3) "$MODULE_PATH/rustscan.sh" "$DEFAULT_NET" ;;
  4) "$MODULE_PATH/arp_scan.sh" "$DEFAULT_NET" ;;
  5) "$MODULE_PATH/netdiscover_module.sh" ;;
  6) "$MODULE_PATH/fping.sh" "$DEFAULT_NET" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
