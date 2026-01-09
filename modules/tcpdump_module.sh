#!/bin/sh
# tcpdump.sh – hálózati forgalom rögzítése és elemzése

. /usr/local/bin/hackstation/lib/common.sh

clear
log_info "TCPdump modul – Forgalom figyelés"
echo "----------------------------------"
log_info "A tcpdump egy hatékony parancssori csomagelemző."
log_info "Valós idejű hálózati forgalom rögzítésére és vizsgálatára alkalmas."
echo ""

log_info "Hasznos kapcsolók:"
log_ok " -D" "Elérhető interfészek kilistázása"
log_ok " -i" "Interfész kiválasztása (pl. wlan0)"
log_ok " -w" "Rögzítés fájlba (.pcap)"
log_ok " -r" "Mentett fájl beolvasása"
echo ""

log_info "Expression segédlet:"
log_ok " host <IP>"         "Bármely csomag forrás vagy cél IP-re"
log_ok " src <IP>"          "Forrás IP-re"
log_ok " dst <IP>"          "Cél IP-re"
log_ok " src and dst <IP>"  "Mindkét oldal az IP"
log_ok " src or dst <IP>"   "Bármelyik oldal az IP"
echo ""

log_info "TCP flag-ek jelentése:"
log_ok " [.] "  "ACK (megerősítés)"
log_ok " [S] "  "SYN (kapcsolat kezdete)"
log_ok " [P] "  "PSH (adat push)"
log_ok " [F] "  "FIN (kapcsolat zárás)"
log_ok " [R] "  "RST (kapcsolat visszaállítás)"
log_ok " [S.]"  "SYN-ACK"
echo ""

iface=$(ask_input "Interfész (pl. wlan0)" "wlan0")
expr=$(ask_input "Szűrő kifejezés (pl. 'port 80')" "")

outfile=$(gen_output_path "tcpdump")
log_info "A mentés helye: $outfile"
log_info "Parancs: tcpdump -i $iface -w $outfile $expr"
log_info "Futtatás indul (Ctrl+C leállítja)"

sleep 1
tcpdump -i "$iface" -w "$outfile" $expr
