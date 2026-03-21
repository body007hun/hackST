#!/bin/sh
# gobuster.sh – könyvtár / vhost / DNS felderítés Gobusterrel

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_TARGET=${1:-"http://127.0.0.1"}
DEFAULT_WORDLIST="/usr/local/bin/hackstation/data/passlist_top100.txt"

clear
log_info "Gobuster modul – Webes útvonal / vhost / DNS felderítés"
echo "--------------------------------"
log_info "A Gobuster egy gyors brute-force alapú felderítő eszköz,"
log_info "amellyel rejtett webes útvonalakat, virtuális hostokat vagy"
log_info "DNS neveket lehet keresni előre megadott szólisták alapján."
echo ""
log_info "Mire jó?"
echo "  - rejtett könyvtárak és fájlok keresésére"
echo "  - webes tartalom-felderítésre"
echo "  - virtual host (vhost) keresésre"
echo "  - DNS aldomain keresésre"
echo ""
log_info "Módok röviden:"
echo "  dir  = könyvtár / fájl keresés"
echo "  vhost = virtuális host keresés"
echo "  dns  = aldomain keresés"
echo ""
log_info "Példák:"
log_ok "gobuster dir -u $DEFAULT_TARGET -w $DEFAULT_WORDLIST"                "Könyvtár keresés"
log_ok "gobuster vhost -u $DEFAULT_TARGET -w $DEFAULT_WORDLIST"              "Vhost keresés"
log_ok "gobuster dns -d example.com -w $DEFAULT_WORDLIST"                    "DNS aldomain keresés"
log_ok "gobuster dir -u $DEFAULT_TARGET -x php,txt,html -w $DEFAULT_WORDLIST" "Kiterjesztések keresése"
echo ""

mode=$(ask_input "Mód (dir/vhost/dns)" "dir")

case "$mode" in
  dir)
    target=$(ask_input "Cél URL" "$DEFAULT_TARGET")
    wordlist=$(ask_input "Szólista" "$DEFAULT_WORDLIST")
    exts=$(ask_input "Kiterjesztések (pl. php,txt,html | Enter = nincs)" "")
    status=$(ask_input "Csak ezek a státuszkódok érdekelnek? (pl. 200,204,301 | Enter = alap)" "")
    extra_opts=$(ask_input "További Gobuster opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

    cmd="gobuster dir -u \"$target\" -w \"$wordlist\""
    [ -n "$exts" ] && cmd="$cmd -x $exts"
    [ -n "$status" ] && cmd="$cmd -s $status"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  vhost)
    target=$(ask_input "Cél URL" "$DEFAULT_TARGET")
    wordlist=$(ask_input "Szólista" "$DEFAULT_WORDLIST")
    append_domain=$(ask_input "Append domain használata? (y/n)" "y")
    extra_opts=$(ask_input "További Gobuster opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

    cmd="gobuster vhost -u \"$target\" -w \"$wordlist\""
    [ "$append_domain" = "y" ] && cmd="$cmd --append-domain"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  dns)
    domain=$(ask_input "Domain" "example.com")
    wordlist=$(ask_input "Szólista" "$DEFAULT_WORDLIST")
    resolver=$(ask_input "DNS szerver (Enter = rendszer alapértelmezett)" "")
    extra_opts=$(ask_input "További Gobuster opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

    cmd="gobuster dns -d \"$domain\" -w \"$wordlist\""
    [ -n "$resolver" ] && cmd="$cmd -r $resolver"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  *)
    log_err "Ismeretlen mód. Használható: dir / vhost / dns"
    exit 1
    ;;
esac

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "gobuster")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Gobuster indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "Gobuster indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
