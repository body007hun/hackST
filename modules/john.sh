#!/bin/sh
# john.sh – Jelszóhash feltörés John the Ripper-rel

. /usr/local/bin/hackstation/lib/common.sh

# Alapértelmezett jelszólista
PASSLIST_PATH=${PASSLIST_PATH:-/usr/local/bin/hackstation/data/passlist_top100.txt}

clear
log_info "John the Ripper modul – jelszóhash feltörés"
echo "----------------------------------------------"
log_info "Támogatott formátumok: Unix crypt, Windows LM, WPA handshake, ZIP, RAR, stb."

hashfile=$(ask_input "Hash fájl elérési út" "")
[ ! -f "$hashfile" ] && log_err "Nem található fájl: $hashfile" && exit 1

wordlist=$(ask_input "Jelszólista" "$PASSLIST_PATH")
[ ! -f "$wordlist" ] && log_err "Nem található jelszólista: $wordlist" && exit 1

cd /root/john-1.9.0/run || { log_err "Nem található a John futtatási mappa."; exit 1; }

hash_count=$(wc -l < "$hashfile")
log_ok "Hash" "Betöltött sorok száma: $hash_count"

log_info "Feltörés indítása: john --wordlist=$wordlist $hashfile"
john --wordlist="$wordlist" "$hashfile"

echo ""
log_info "Eredmények:"
john --show "$hashfile"

echo ""
log_ok "Kész" "Művelet befejezve."
