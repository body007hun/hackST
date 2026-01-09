#!/bin/sh
# net_diag.sh – hálózati diagnosztikai eszközök

. /usr/local/bin/hackstation/lib/common.sh

while true; do
  clear
  log_info "Netdiagnosztika modul"
  echo "------------------------"
  echo "1) Ping teszt"
  echo "2) Traceroute / MTR"
  echo "3) Iperf3 sebességteszt"
  echo "4) Wi-Fi jelerősség"
  echo "5) DNS lekérdezés"
  echo "6) Vissza"
  echo ""
  read -p "Választás: " opt

  case $opt in
    1)
      host=$(ask_input "Cél host/IP a pinghez" "8.8.8.8")
      log_info "Ping teszt indul: $host"
      ping -c 4 "$host"
      ;;
    2)
      host=$(ask_input "Cél host/IP a traceroute-hoz" "google.com")
      if command -v traceroute >/dev/null 2>&1; then
        log_info "Traceroute indul: $host"
        traceroute "$host"
      elif command -v mtr >/dev/null 2>&1; then
        log_info "MTR indul: $host"
        mtr --report "$host"
      else
        log_err "Nincs telepítve traceroute vagy mtr."
      fi
      ;;
    3)
      iperf_srv=$(ask_input "Iperf3 szerver IP-címe" "192.168.1.1")
      log_info "Iperf3 teszt indul: $iperf_srv"
      iperf3 -c "$iperf_srv"
      ;;
    4)
      for iface in $(ls /sys/class/net | grep wlan); do
        log_info "$iface kapcsolat info:"
        iw dev "$iface" link | sed 's/^/  /'
        echo ""
      done
      ;;
    5)
      domain=$(ask_input "Lekérdezendő domain" "google.com")
      if command -v drill >/dev/null 2>&1; then
        drill "$domain"
      elif command -v dig >/dev/null 2>&1; then
        dig "$domain"
      elif command -v nslookup >/dev/null 2>&1; then
        nslookup "$domain"
      else
        log_err "Nincs elérhető DNS eszköz (drill, dig, nslookup)."
      fi
      ;;
    6)
      break
      ;;
    *)
      log_err "Érvénytelen választás."
      ;;
  esac
  echo ""
  read -p "Nyomj Enter-t a folytatáshoz..." dummy
done
