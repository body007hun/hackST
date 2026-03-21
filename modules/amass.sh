#!/bin/sh
# amass.sh – aldomain és infrastruktúra-felderítés Amass-szal

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_DOMAIN="example.com"
clear
log_info "Amass modul – Domain és aldomain felderítés"
echo "--------------------------------"
log_info "Az Amass egy erős infrastruktúra- és aldomain-felderítő eszköz,"
log_info "amely OSINT, DNS és különböző adatforrások alapján próbál képet"
log_info "alkotni egy domain környezetéről."
echo ""
log_info "Mire jó?"
echo "  - aldomain-ek keresésére"
echo "  - támadási felület / attack surface felmérésre"
echo "  - DNS-alapú és OSINT-alapú infrastruktúra-felderítésre"
echo "  - webes audit előtti célpont-térképezésre"
echo ""
log_info "Fő módok röviden:"
echo "  enum   = aldomain felderítés"
echo "  intel  = kapcsolódó domainek / infra információk"
echo ""
log_info "Példák:"
log_ok "amass enum -d $DEFAULT_DOMAIN"                    "Alap aldomain keresés"
log_ok "amass enum -passive -d $DEFAULT_DOMAIN"           "Passzív, csendesebb felderítés"
log_ok "amass intel -d $DEFAULT_DOMAIN"                  "Infra / kapcsolódó infók"
log_ok "amass enum -d $DEFAULT_DOMAIN -o amass.txt"      "Kimenet fájlba"
echo ""

mode=$(ask_input "Mód (enum/intel)" "enum")
domain=$(ask_input "Domain" "$DEFAULT_DOMAIN")
passive=$(ask_input "Passzív mód? (y/n)" "y")
brute=$(ask_input "Bruteforce engedélyezése? (y/n)" "n")
extra_opts=$(ask_input "További Amass opciók" "")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

case "$mode" in
  enum)
    cmd="amass enum -d \"$domain\""
    [ "$passive" = "y" ] && cmd="$cmd -passive"
    [ "$brute" = "y" ] && cmd="$cmd -brute"
    ;;
  intel)
    cmd="amass intel -d \"$domain\""
    [ "$passive" = "y" ] && cmd="$cmd -passive"
    ;;
  *)
    log_err "Ismeretlen mód. Használható: enum / intel"
    exit 1
    ;;
esac

[ -n "$extra_opts" ] && cmd="$cmd $extra_opts"

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "amass")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Amass indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "Amass indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
