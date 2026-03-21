#!/bin/sh
# tshark.sh – csomagrögzítés és forgalomelemzés TSharkkal

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_IFACE=$(ip route get 1 2>/dev/null | grep -oE 'dev [^ ]+' | awk '{print $2}')
[ -z "$DEFAULT_IFACE" ] && DEFAULT_IFACE="wlan0"

clear
log_info "TShark modul – Forgalomfigyelés és csomagelemzés"
echo "--------------------------------"
log_info "A TShark a Wireshark parancssoros változata."
log_info "Segítségével hálózati forgalmat lehet élőben figyelni, szűrni,"
log_info "fájlba menteni vagy később elemezni."
echo ""
log_info "Mire jó?"
echo "  - élő hálózati forgalom figyelésére"
echo "  - protokollok és csomagok elemzésére"
echo "  - DNS, HTTP, TLS, ARP és más forgalmak gyors vizsgálatára"
echo "  - pcap mentésre későbbi Wireshark elemzéshez"
echo ""
log_info "Tipikus használat:"
echo "  - általános sniff"
echo "  - csak DNS forgalom"
echo "  - csak HTTP/HTTPS kapcsolatfigyelés"
echo "  - meghatározott host vagy port figyelése"
echo ""
log_info "Példák:"
log_ok "tshark -i $DEFAULT_IFACE"                              "Élő forgalom figyelése"
log_ok "tshark -i $DEFAULT_IFACE -f 'port 53'"                "DNS forgalom capture szűrővel"
log_ok "tshark -i $DEFAULT_IFACE -Y 'dns'"                    "DNS csomagok megjelenítése"
log_ok "tshark -i $DEFAULT_IFACE -w capture.pcapng"           "Mentés pcapng fájlba"
log_ok "tshark -r capture.pcapng"                             "Korábbi capture visszaolvasása"
echo ""

mode=$(ask_input "Mód (live/read)" "live")

case "$mode" in
  live)
    iface=$(ask_input "Interfész" "$DEFAULT_IFACE")
    capfilter=$(ask_input "Capture filter (pl. port 53 | Enter = nincs)" "")
    displayfilter=$(ask_input "Display filter (pl. dns, http, tls | Enter = nincs)" "")
    packet_count=$(ask_input "Csomaglimit (Enter = nincs)" "")
    save_pcap=$(ask_input "Mentsek PCAPNG fájlt is? (y/n)" "n")
    save_text=$(ask_input "Mentsem a képernyőkimenetet logba? (y/n)" "y")
    extra_opts=$(ask_input "További TShark opciók" "")

    cmd="tshark -i \"$iface\""
    [ -n "$capfilter" ] && cmd="$cmd -f \"$capfilter\""
    [ -n "$displayfilter" ] && cmd="$cmd -Y \"$displayfilter\""
    [ -n "$packet_count" ] && cmd="$cmd -c $packet_count"
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"

    if [ "$save_pcap" = "y" ]; then
      pcapfile=$(gen_output_path "tshark" "pcapng")
      cmd="$cmd -w \"$pcapfile\""
      log_info "PCAP mentés ide: $pcapfile"
    fi

    if [ "$save_text" = "y" ]; then
      outfile=$(gen_output_path "tshark")
      log_info "Kimenet mentése ide: $outfile"
      {
        log_info "TShark indítása a következő paraméterekkel:"
        echo "$cmd"
        eval "$cmd"
      } | tee "$outfile"
    else
      log_info "TShark indítása a következő paraméterekkel:"
      echo "$cmd"
      eval "$cmd"
    fi
    ;;
  read)
    infile=$(ask_input "Beolvasandó PCAP/PCAPNG fájl" "/root/outputs/capture.pcapng")
    displayfilter=$(ask_input "Display filter (pl. dns, http, tls | Enter = nincs)" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")
    extra_opts=$(ask_input "További TShark opciók" "")

    cmd="tshark -r \"$infile\""
    [ -n "$displayfilter" ] && cmd="$cmd -Y \"$displayfilter\""
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"

    if [ "$save" = "y" ]; then
      outfile=$(gen_output_path "tshark-read")
      log_info "Kimenet mentése ide: $outfile"
      {
        log_info "TShark indítása a következő paraméterekkel:"
        echo "$cmd"
        eval "$cmd"
      } | tee "$outfile"
    else
      log_info "TShark indítása a következő paraméterekkel:"
      echo "$cmd"
      eval "$cmd"
    fi
    ;;
  *)
    log_err "Ismeretlen mód. Használható: live / read"
    exit 1
    ;;
esac

exit 0
