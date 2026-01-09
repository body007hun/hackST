#!/bin/sh
# arp_scan.sh – hálózati eszközök felderítése ARP-vel

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_RANGE="$1"
DEFAULT_IFACE="wlan0"

clear
log_info "ARP-scan modul"
echo "------------------"
log_info "Az arp-scan eszköz ARP csomagokkal térképezi fel a hálózaton lévő eszközöket."
log_info "Nem ICMP vagy DNS, hanem közvetlen ARP kérések alapján működik."

echo ""
log_info "Hasznos kapcsolók:"
log_ok "-I <interface>" "Interfész megadása (pl. wlan0)"
log_ok "-l"             "Alhálózat automatikus lekérdezése"
log_ok "-g"             "Beépített gateway keresés"
log_ok "-x"             "Kimenet XML formátumban"
log_ok "-v"             "Részletes kimenet"

echo ""
iface=$(ask_input "Használni kívánt interfész" "$DEFAULT_IFACE")
range=$(ask_input "Céltartomány (CIDR)" "$DEFAULT_RANGE")
extra=$(ask_input "További kapcsolók" "")

save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "arp_scan")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "ARP-scan indítása a következő parancs alapján:"
    echo "arp-scan -I $iface $extra $range"
    arp-scan -I "$iface" $extra "$range"
  } | tee "$outfile"
else
  log_info "ARP-scan indítása:"
  echo "arp-scan -I $iface $extra $range"
  arp-scan -I "$iface" $extra "$range"
fi
