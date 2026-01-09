#!/bin/sh
# netdiscover_module.sh – ARP-alapú eszközfelderítés

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_IFACE="wlan0"

clear
log_info "Netdiscover – ARP-alapú hálózati eszközkereső"
echo "----------------------------------------------------"
log_info "A Netdiscover passzívan figyeli a hálózati forgalmat, DHCP csomagokat."
log_info "Nem küld pinget vagy aktív szkennereket."

iface=$(ask_input "Használni kívánt interfész" "$DEFAULT_IFACE")
range=$(ask_input "IP tartomány (opcionális, pl. 192.168.1.0/24)" "")

save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

cmd="netdiscover -i $iface"
[ -n "$range" ] && cmd="$cmd -r $range"

log_info "Parancs: $cmd"

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "netdiscover")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Netdiscover indul:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  eval "$cmd"
fi
