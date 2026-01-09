#!/bin/sh
# nmap.sh – hálózati szkennelés Nmap-pel

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_NET=${1:-"192.168.1.0/24"}
clear
log_info "Nmap modul – Hálózati szkennelés"
echo "--------------------------------"
log_info "Az Nmap egy nyílt forráskódú hálózatszkenner IP-k és portok vizsgálatához."
echo ""

log_info "Példák:"
log_ok "nmap -sn $DEFAULT_NET"       "Élő eszközök keresése"
log_ok "nmap scanme.nmap.org"        "Alap port scan"
log_ok "nmap -sS scanme.nmap.org"    "Stealth scan"
log_ok "nmap -sV scanme.nmap.org"    "Verziók detektálása"
log_ok "nmap -A scanme.nmap.org"     "Aggresszív scan"
log_ok "nmap -oN output.txt ..."     "Normál output fájlba"
log_ok "nmap -oA output ..."         "Minden output formátum"
echo ""

opts=$(ask_input "Használt Nmap opciók" "-sn")
range=$(ask_input "Céltartomány" "$DEFAULT_NET")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "nmap")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Nmap indítása a következő paraméterekkel:"
    echo "nmap $opts $range"
    nmap $opts $range
  } | tee "$outfile"
else
  log_info "Nmap indítása a következő paraméterekkel:"
  echo "nmap $opts $range"
  nmap $opts $range
fi

exit 0
