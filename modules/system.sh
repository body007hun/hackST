#!/bin/sh
# system.sh – Rendszereszközök és beállítások

. /usr/local/bin/hackstation/lib/common.sh

MODULE_PATH="/usr/local/bin/hackstation/modules"
DATA_PATH="/usr/local/bin/hackstation/data"

while true; do
  clear
  log_info "HackStation – Rendszereszközök és beállítások"
  echo ""
  echo "1) Log olvasó és karbantartó"
  echo "2) Jelszólista kiválasztása"
  echo "3) Hálózati diagnosztika"
  echo "4) Rendszermentés (ment.sh)"
  echo "5) Vissza a főmenübe"
  echo ""
  read -p "Választás: " sysopt

  case $sysopt in
    1)
      "$MODULE_PATH/logreader.sh"
      ;;
    2)
      echo ""
      log_info "Elérhető jelszólisták:"
      i=1
      for list in "$DATA_PATH"/passlist*.txt; do
        echo "  $i) $(basename "$list")"
        eval "list_$i=\"$list\""
        i=$((i+1))
      done
      echo ""
      read -p "Válassz listát: " idx
      selected=$(eval echo "\$list_$idx")
      if [ -f "$selected" ]; then
        export PASSLIST_PATH="$selected"
        log_ok "Beállítás" "Új jelszólista: $PASSLIST_PATH"
      else
        log_err "Érvénytelen választás."
      fi
      ;;
    3)
      "$MODULE_PATH/net_diag.sh"
      ;;
    4)
      /usr/local/bin/hackstation/lib/ment.sh
      ;;
    5)
      break
      ;;
    *)
      log_err "Ismeretlen opció."
      ;;
  esac
  echo ""
  read -p "Nyomj Enter-t a folytatáshoz..." dummy
done
