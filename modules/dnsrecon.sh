#!/bin/sh
# dnsrecon.sh – DNS felderítés és alap audit dnsrecon-nal

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_DOMAIN="example.com"
DEFAULT_DNS=""

clear
log_info "dnsrecon modul – DNS felderítés és audit"
echo "--------------------------------"
log_info "A dnsrecon egy DNS-felderítő eszköz, amellyel egy domainhez tartozó"
log_info "rekordokat, névszervereket, zónainformációkat és egyéb DNS-adatokat"
log_info "lehet összegyűjteni és ellenőrizni."
echo ""
log_info "Mire jó?"
echo "  - DNS rekordok lekérdezésére"
echo "  - névszerverek és MX rekordok feltárására"
echo "  - zónaátvitel (AXFR) ellenőrzésére"
echo "  - aldomain-ek keresésére"
echo "  - gyors DNS baseline felmérésre"
echo ""
log_info "Fő módok röviden:"
echo "  std   = alap DNS felderítés"
echo "  axfr  = zónaátvitel ellenőrzés"
echo "  brt   = bruteforce aldomain keresés"
echo ""
log_info "Példák:"
log_ok "dnsrecon -d $DEFAULT_DOMAIN"                                      "Alap DNS felderítés"
log_ok "dnsrecon -d $DEFAULT_DOMAIN -t std"                               "Standard lekérdezések"
log_ok "dnsrecon -d $DEFAULT_DOMAIN -t axfr"                              "Zónaátvitel teszt"
log_ok "dnsrecon -d $DEFAULT_DOMAIN -t brt -D subdomains.txt"             "Bruteforce aldomain keresés"
log_ok "dnsrecon -d $DEFAULT_DOMAIN -n 8.8.8.8"                           "Egyedi DNS szerver használata"
echo ""

mode=$(ask_input "Mód (std/axfr/brt)" "std")
domain=$(ask_input "Domain" "$DEFAULT_DOMAIN")
dns_server=$(ask_input "DNS szerver (Enter = rendszer alapértelmezett)" "$DEFAULT_DNS")

case "$mode" in
  std)
    extra_opts=$(ask_input "További dnsrecon opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

    cmd="dnsrecon -d \"$domain\" -t std"
    [ -n "$dns_server" ] && cmd="$cmd -n $dns_server"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  axfr)
    extra_opts=$(ask_input "További dnsrecon opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

    cmd="dnsrecon -d \"$domain\" -t axfr"
    [ -n "$dns_server" ] && cmd="$cmd -n $dns_server"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  brt)
    wordlist=$(ask_input "Szólista aldomain-ekhez" "/usr/local/bin/hackstation/data/passlist_top100.txt")
    extra_opts=$(ask_input "További dnsrecon opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

    cmd="dnsrecon -d \"$domain\" -t brt -D \"$wordlist\""
    [ -n "$dns_server" ] && cmd="$cmd -n $dns_server"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  *)
    log_err "Ismeretlen mód. Használható: std / axfr / brt"
    exit 1
    ;;
esac

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "dnsrecon")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "dnsrecon indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "dnsrecon indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
