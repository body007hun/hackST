#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Hitelesítés / hash"
echo "--------------------------------"
echo "1) Hydra"
echo "2) John the Ripper"
echo "3) Hashcat"
echo "4) HashID / Name-That-Hash"
echo "5) CeWL"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/hydra.sh" ;;
  2) "$MODULE_PATH/john.sh" ;;
  3) "$MODULE_PATH/hashcat.sh" ;;
  4) "$MODULE_PATH/hashid.sh" ;;
  5) "$MODULE_PATH/cewl.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
