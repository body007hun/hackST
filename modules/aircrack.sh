#!/bin/sh
# aircrack.sh – Aircrack-ng monitor mód biztonságosan

. /usr/local/bin/hackstation/lib/common.sh

clear
log_info "Aircrack-ng – Wi-Fi audit modul"

# Elérhető interfészek lekérdezése
WIFI_IFACES=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')
[ -z "$WIFI_IFACES" ] && log_err "Nincs elérhető wifi interfész." && exit 1

SSH_IFACE=$(ip route get 1 | grep -oP 'dev \K\S+')
SAFE_IFACES=""

echo ""
log_info "Elérhető wifi interfészek:"
for iface in $WIFI_IFACES; do
  if [ "$iface" = "$SSH_IFACE" ]; then
    log_info "❌ $iface (SSH kapcsolat – nem módosítható)"
  else
    log_info "✅ $iface (használható monitor módra)"
    SAFE_IFACES="$SAFE_IFACES $iface"
  fi
done

if [ -z "$SAFE_IFACES" ]; then
  log_err "Nincs használható wifi interfész – nem szakíthatjuk meg az SSH kapcsolatot."
  exit 1
fi

echo ""
read -p "Monitor módra állítandó interfész [alap: $(echo $SAFE_IFACES | awk '{print $1}')]: " mon_iface
[ -z "$mon_iface" ] && mon_iface=$(echo $SAFE_IFACES | awk '{print $1}')

log_info "Monitor interfész: $mon_iface"
read -p "Létrehozzuk a monitor módot ($mon_iface)? (y/n): " confirm
[ "$confirm" != "y" ] && log_info "Kilépés." && exit 0

# Monitor mód aktiválása
log_info "Monitor mód aktiválása: $mon_iface"
ip link set "$mon_iface" down
iw "$mon_iface" set monitor control || { log_err "Monitor mód beállítása sikertelen."; exit 1; }
ip link set "$mon_iface" up
log_ok "$mon_iface" "Monitor mód aktiválva."

read -p "Indítjuk az airodump-ng-t? (y/n): " run
if [ "$run" = "y" ]; then
  log_info "airodump-ng $mon_iface – Ctrl+C a leállításhoz."
  sleep 1
  airodump-ng "$mon_iface"
else
  log_info "Kész."
fi
