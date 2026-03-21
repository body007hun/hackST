#!/bin/sh
# nikto.sh – webszerver alap sebezhetőség-ellenőrzés Nikto-val

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_TARGET=${1:-"http://127.0.0.1"}
clear
log_info "Nikto modul – Webszerver alap audit"
echo "--------------------------------"
log_info "A Nikto egy nyílt forráskódú webszerver-szkenner, amely gyakori hibás"
log_info "beállításokat, ismert problémás fájlokat, veszélyes defaultokat és"
log_info "tipikus szerveroldali gyengeségeket keres."
echo ""
log_info "Mire jó?"
echo "  - webszerver alap állapotfelmérésre"
echo "  - régi / hibás beállítások kiszúrására"
echo "  - expose-olt fájlok, admin oldalak, default tartalmak keresésére"
echo "  - gyors első webes baseline ellenőrzésre"
echo ""
log_info "Példák:"
log_ok "nikto.pl -h $DEFAULT_TARGET"                    "Alap vizsgálat egy célra"
log_ok "nikto.pl -h https://example.com -ssl"          "HTTPS cél explicit SSL-lel"
log_ok "nikto.pl -h example.com -port 8080"            "Egyedi port vizsgálata"
log_ok "nikto.pl -h $DEFAULT_TARGET -Tuning b"         "Csak érdekes / veszélyes elemek"
log_ok "nikto.pl -h $DEFAULT_TARGET -Format txt"       "Szöveges kimenet"
echo ""

target=$(ask_input "Cél URL / host" "$DEFAULT_TARGET")
port=$(ask_input "Port (Enter = alapértelmezett)" "")
ssl=$(ask_input "SSL/HTTPS kényszerítése? (y/n)" "n")
tuning=$(ask_input "Nikto Tuning opciók (Enter = nincs)" "")
extra_opts=$(ask_input "További Nikto opciók" "")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

cmd="nikto.pl -h \"$target\""

[ -n "$port" ] && cmd="$cmd -port $port"
[ "$ssl" = "y" ] && cmd="$cmd -ssl"
[ -n "$tuning" ] && cmd="$cmd -Tuning $tuning"
[ -n "$extra_opts" ] && cmd="$cmd $extra_opts"

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "nikto")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Nikto indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "Nikto indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
