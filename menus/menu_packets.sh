#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Forgalom és csomagelemzés"
echo "--------------------------------"
echo "1) TCPdump"
echo "2) Tshark"
echo "3) MTR"
echo "4) Netcat"
echo "5) Socat"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/tcpdump_module.sh" ;;
  2) "$MODULE_PATH/tshark.sh" ;;
  3) "$MODULE_PATH/mtr.sh" ;;
  4) "$MODULE_PATH/netcat.sh" ;;
  5) "$MODULE_PATH/socat.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
