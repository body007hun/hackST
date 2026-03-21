#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "OSINT / DNS"
echo "--------------------------------"
echo "1) dig / host / drill"
echo "2) dnsrecon"
echo "3) theHarvester"
echo "4) amass"
echo "5) recon-ng"
echo "6) Defensive OSINT / Audit"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/dns_tools.sh" ;;
  2) "$MODULE_PATH/dnsrecon.sh" ;;
  3) "$MODULE_PATH/theharvester.sh" ;;
  4) "$MODULE_PATH/amass.sh" ;;
  5) "$MODULE_PATH/recon_ng.sh" ;;
  6) "$MODULE_PATH/osint_defensive.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
