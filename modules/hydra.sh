#!/bin/sh
# hydra.sh – jelszótörés bruteforce módszerrel

. /usr/local/bin/hackstation/lib/common.sh

# Alap jelszólista
PASSLIST_DEFAULT="/usr/local/bin/hackstation/data/passlist.txt"

clear
log_info "Hydra modul – Jelszófeltörés"
echo "-------------------------------------"
log_info "Hydra: párhuzamos brute-force támadások protokollokra (SSH, FTP, HTTP-form, stb.)"

proto=$(ask_input "Protokoll (pl. ssh, ftp, http-form)" "")
target=$(ask_input "Cél host (pl. 192.168.1.11)" "")
users=$(ask_input "Felhasználó (-l USER vagy -L FILE)" "")
passes=$(ask_input "Jelszólista (-p PASS vagy -P FILE)" "-P $PASSLIST_DEFAULT")
extra=$(ask_input "Extra kapcsolók (pl. -t 4 -v)" "")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

cmd="hydra $extra $users $passes $proto://$target"
log_info "Futtatás: $cmd"

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "hydra")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Hydra parancs:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  eval "$cmd"
fi

log_info "Végeztem."
