#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Wi-Fi eszközök"
echo "--------------------------------"
echo "1) Aircrack-ng monitor mód"
echo "2) hcxdumptool"
echo "3) Bettercap"
echo "4) Interfész / csatorna info"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/aircrack.sh" ;;
  2) "$MODULE_PATH/hcxdumptool.sh" ;;
  3) "$MODULE_PATH/bettercap.sh" ;;
  4) "$MODULE_PATH/wifi_info.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
