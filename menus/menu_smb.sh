#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "SMB / belső háló"
echo "--------------------------------"
echo "1) smbclient"
echo "2) enum4linux-ng"
echo "3) ldapsearch"
echo "4) netexec / crackmapexec"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/smbclient.sh" ;;
  2) "$MODULE_PATH/enum4linux_ng.sh" ;;
  3) "$MODULE_PATH/ldapsearch.sh" ;;
  4) "$MODULE_PATH/netexec.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
