#!/bin/sh
# testssl.sh – TLS/SSL konfiguráció ellenőrzés testssl.sh-val

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_TARGET="127.0.0.1:443"

clear
log_info "testssl.sh modul – TLS / SSL audit"
echo "--------------------------------"
log_info "A testssl.sh egy TLS/SSL ellenőrző eszköz, amellyel egy szolgáltatás"
log_info "titkosítási beállításait, támogatott protokolljait, cipherjeit,"
log_info "tanúsítványát és gyakori hibáit lehet megvizsgálni."
echo ""
log_info "Mire jó?"
echo "  - HTTPS / TLS konfiguráció ellenőrzésére"
echo "  - gyenge protokollok és cipher-ek keresésére"
echo "  - tanúsítványok vizsgálatára"
echo "  - gyors SSL/TLS baseline felmérésre"
echo ""
log_info "Gyakori ellenőrzések:"
echo "  - tanúsítvány adatok"
echo "  - TLS verziók"
echo "  - cipher suite-ok"
echo "  - HSTS / biztonsági beállítások"
echo "  - ismert TLS hibák nyomai"
echo ""
log_info "Példák:"
log_ok "testssl.sh $DEFAULT_TARGET"               "Teljes TLS ellenőrzés"
log_ok "testssl.sh --fast $DEFAULT_TARGET"        "Gyorsabb ellenőrzés"
log_ok "testssl.sh -p $DEFAULT_TARGET"            "Protokollok ellenőrzése"
log_ok "testssl.sh -E $DEFAULT_TARGET"            "Cipher / preferencia vizsgálat"
log_ok "testssl.sh -S $DEFAULT_TARGET"            "Tanúsítvány ellenőrzés"
echo ""

target=$(ask_input "Cél host:port" "$DEFAULT_TARGET")
scan_mode=$(ask_input "Mód (full/fast/protocols/ciphers/cert)" "fast")
sneaky=$(ask_input "Csendesebb / kevésbé részletes mód? (y/n)" "n")
extra_opts=$(ask_input "További testssl.sh opciók" "")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

case "$scan_mode" in
  full)
    cmd="testssl.sh \"$target\""
    ;;
  fast)
    cmd="testssl.sh --fast \"$target\""
    ;;
  protocols)
    cmd="testssl.sh -p \"$target\""
    ;;
  ciphers)
    cmd="testssl.sh -E \"$target\""
    ;;
  cert)
    cmd="testssl.sh -S \"$target\""
    ;;
  *)
    log_err "Ismeretlen mód. Használható: full / fast / protocols / ciphers / cert"
    exit 1
    ;;
esac

[ "$sneaky" = "y" ] && cmd="$cmd --warnings off"
[ -n "$extra_opts" ] && cmd="$cmd $extra_opts"

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "testssl")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "testssl.sh indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "testssl.sh indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
