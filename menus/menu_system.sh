#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Rendszer / output / mentés"
echo "--------------------------------"
echo "1) Rendszereszközök / beállítások"
echo "2) Audit bundle"
echo "3) Logreader"
echo "4) Net diagnostics"
echo "5) Tool check / frissítés"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/system.sh" ;;
  2) "$MODULE_PATH/audit_bundle.sh" ;;
  3) "$MODULE_PATH/logreader.sh" ;;
  4) "$MODULE_PATH/net_diag.sh" ;;
  5) "$MODULE_PATH/tool_check.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
