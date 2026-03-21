#!/bin/sh
# binwalk.sh – firmware és bináris fájlok elemzése Binwalkkal

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_FILE="/tmp/sample.bin"
DEFAULT_EXTRACT_DIR="/root/outputs/binwalk_extract"

clear
log_info "Binwalk modul – Firmware és bináris fájl elemzés"
echo "--------------------------------"
log_info "A Binwalk egy firmware- és bináriselemző eszköz,"
log_info "amellyel fájlok belső szekcióit, beágyazott tömörített"
log_info "adatokat, fájlrendszereket és ismert bináris mintákat lehet keresni."
echo ""
log_info "Mire jó?"
echo "  - firmware fájlok boncolására"
echo "  - beágyazott tömörített adatok felismerésére"
echo "  - squashfs, cramfs, gzip, xz és más blokkok keresésére"
echo "  - router / IoT / embedded image-ek első körös vizsgálatára"
echo ""
log_info "Fő módok röviden:"
echo "  scan    = csak elemzés"
echo "  extract = felismerés + kibontás"
echo ""
log_info "Példák:"
log_ok "binwalk firmware.bin"                           "Alap szignatúra-keresés"
log_ok "binwalk -e firmware.bin"                        "Automatikus kibontás"
log_ok "binwalk -B firmware.bin"                        "Csak szignatúra scan"
log_ok "binwalk -E firmware.bin"                        "Entrópia vizsgálat"
log_ok "binwalk -y filesystem firmware.bin"             "Csak adott típus keresése"
echo ""

mode=$(ask_input "Mód (scan/extract/entropy/signature)" "scan")
infile=$(ask_input "Vizsgálandó fájl" "$DEFAULT_FILE")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

case "$mode" in
  scan)
    filter=$(ask_input "Csak adott típus? (pl. filesystem, gzip | Enter = nincs)" "")
    extra_opts=$(ask_input "További Binwalk opciók" "")

    cmd="binwalk"
    [ -n "$filter" ] && cmd="$cmd -y \"$filter\""
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    cmd="$cmd \"$infile\""
    ;;
  extract)
    outdir=$(ask_input "Kibontási célmappa" "$DEFAULT_EXTRACT_DIR")
    matryoshka=$(ask_input "Rekurzív kibontás (-M)? (y/n)" "n")
    extra_opts=$(ask_input "További Binwalk opciók" "")

    mkdir -p "$outdir"

    cmd="cd \"$outdir\" && binwalk -e"
    [ "$matryoshka" = "y" ] && cmd="$cmd -M"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    cmd="$cmd \"$infile\""
    ;;
  entropy)
    extra_opts=$(ask_input "További Binwalk opciók" "")

    cmd="binwalk -E"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    cmd="$cmd \"$infile\""
    ;;
  signature)
    extra_opts=$(ask_input "További Binwalk opciók" "")

    cmd="binwalk -B"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    cmd="$cmd \"$infile\""
    ;;
  *)
    log_err "Ismeretlen mód. Használható: scan / extract / entropy / signature"
    exit 1
    ;;
esac

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "binwalk")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Binwalk indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "Binwalk indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
