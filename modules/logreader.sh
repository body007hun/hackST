#!/bin/sh
# logreader.sh – Mentett log fájlok kezelése

. /usr/local/bin/hackstation/lib/common.sh

LOG_DIR="/root/outputs"

clear
log_info "Log olvasó és karbantartó modul"

if [ ! -d "$LOG_DIR" ]; then
  log_err "A log könyvtár nem található: $LOG_DIR"
  exit 1
fi

files=$(ls -1t "$LOG_DIR")
if [ -z "$files" ]; then
  log_info "Nincsenek elérhető mentések."
  exit 0
fi

echo ""
log_info "Elérhető log fájlok:"
i=1
for file in $files; do
  echo "  $i) $file"
  eval "file_$i=\"$file\""
  i=$((i+1))
done

echo ""
read -p "Add meg a fájl számát vagy 'q' a kilépéshez: " choice
[ "$choice" = "q" ] && exit 0

selected=$(eval echo "\$file_$choice")
[ -z "$selected" ] && log_err "Érvénytelen választás!" && exit 1

log_info "Kiválasztott fájl: $selected"
echo "1) Megnyitás"
echo "2) Törlés"
echo "3) Mégse"
read -p "Mit szeretnél tenni? " action

case "$action" in
  1)
    case "$selected" in
      *.pcap)
        log_info "Tcpdump visszajátszás indul..."
        tcpdump -nn -r "$LOG_DIR/$selected"
        ;;
      *)
        less "$LOG_DIR/$selected"
        ;;
    esac
    ;;
  2)
    read -p "Biztosan törlöd? [y/N]: " confirm
    if [ "$confirm" = "y" ]; then
      rm "$LOG_DIR/$selected"
      log_ok "Törlés" "Fájl törölve: $selected"
    else
      log_info "Törlés megszakítva."
    fi
    ;;
  *)
    log_info "Művelet megszakítva."
    ;;
esac

exit 0
