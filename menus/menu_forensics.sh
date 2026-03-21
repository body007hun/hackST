#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
MAIN_MENU="/usr/local/bin/hackstation/menus/hackmenu.sh"

clear
log_info "Forensics / artifact"
echo "--------------------------------"
echo "1) ExifTool"
echo "2) Binwalk"
echo "3) file / strings / xxd"
echo "4) YARA"
echo ""
echo "0) Vissza a főmenübe"
echo ""
read -p "Választás: " opt

case "$opt" in
  1) "$MODULE_PATH/exiftool.sh" ;;
  2) "$MODULE_PATH/binwalk.sh" ;;
  3) "$MODULE_PATH/file_tools.sh" ;;
  4) "$MODULE_PATH/yara.sh" ;;
  0) exec "$MAIN_MENU" ;;
  *) log_err "Érvénytelen választás." ;;
esac

exit 0
