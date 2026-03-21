#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Web audit"
echo "--------------------------------"
echo "1) Nikto"
echo "2) WhatWeb"
echo "3) Gobuster"
echo "4) Feroxbuster"
echo "5) ffuf"
echo "6) testssl.sh"
echo "7) sqlmap"
echo "8) nuclei"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/nikto.sh" ;;
  2) "$MODULE_PATH/whatweb.sh" ;;
  3) "$MODULE_PATH/gobuster.sh" ;;
  4) "$MODULE_PATH/feroxbuster.sh" ;;
  5) "$MODULE_PATH/ffuf.sh" ;;
  6) "$MODULE_PATH/testssl.sh" ;;
  7) "$MODULE_PATH/sqlmap.sh" ;;
  8) "$MODULE_PATH/nuclei.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
