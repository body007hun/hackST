#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

# --- output / logging ---
MODULE_NAME="osint_defensive"
mkdir -p /root/outputs
OUTFILE="$(gen_output_path "$MODULE_NAME")"

# fájlba írás (ANSI nélkül)
log_file() {
  printf "%s\n" "$*" >> "$OUTFILE"
}

# felülírjuk a common.sh logolóit: terminál színes, fájl plain
log_info() {
  printf "%b %s\n" "$INFO" "$*"
  log_file "[INFO] $*"
}
log_err() {
  printf "%b %s\n" "$ERR" "$*"
  log_file "[HIBA] $*"
}
log_ok() {
  local tag="$1"
  local msg="$2"
  printf "%b %-10s %b %s\n" "$OK" "$tag" "$INFO" "$msg"
  log_file "[OK] $tag - $msg"
}

pause() { echo ""; read -p "Enter a visszalépéshez..." _; }

# parancs futtatás + logolás (stdout+stderr a fájlba is)
run_cmd() {
  # $1 = human title (optional)
  title="$1"; shift
  [ -n "$title" ] && { log_info "$title"; echo "" ; log_file ""; log_file "### $title"; }
  # shellcheck disable=SC2068
  "$@" 2>&1 | tee -a "$OUTFILE"
}

get_public_ip() {
  ip=""
  if command -v dig >/dev/null 2>&1; then
    ip=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null | tail -n1)
  fi
  if [ -z "$ip" ] && command -v curl >/dev/null 2>&1; then
    ip=$(curl -fsS https://api.ipify.org 2>/dev/null)
  fi
  [ -n "$ip" ] && echo "$ip" || echo "N/A"
}

dns_check() {
  domain="$1"
  [ -z "$domain" ] && { log_err "Nincs domain megadva."; return 1; }

  log_info "DNS check: $domain"
  echo ""
  log_file ""
  log_file "===== DNS check: $domain ====="

  run_cmd "A rekord"    dig +short A "$domain"
  echo ""
  run_cmd "AAAA rekord" dig +short AAAA "$domain"
  echo ""
  run_cmd "MX rekord"   dig +short MX "$domain"
  echo ""
  # TXT (SPF)
  log_info "TXT (SPF gyanús sorok):"
  log_file "### TXT (SPF gyanús sorok)"
  dig +short TXT "$domain" 2>&1 | tee -a "$OUTFILE" | grep -i "v=spf1" | sed 's/^/  - /' | tee -a "$OUTFILE" >/dev/null
  # ha nincs találat
  if ! dig +short TXT "$domain" 2>/dev/null | grep -qi "v=spf1"; then
    echo "  - (nincs SPF TXT találat)"
    log_file "  - (nincs SPF TXT találat)"
  fi

  echo ""
  run_cmd "DMARC" dig +short TXT "_dmarc.$domain"
}

tls_expiry() {
  host="$1"
  [ -z "$host" ] && { log_err "Nincs host megadva."; return 1; }

  log_info "TLS lejárat: $host:443"
  echo ""
  log_file ""
  log_file "===== TLS lejárat: $host:443 ====="

  if ! command -v openssl >/dev/null 2>&1; then
    log_err "openssl nincs telepítve."
    return 1
  fi

  # cert dátumok
  echo | openssl s_client -servername "$host" -connect "$host:443" 2>&1 \
    | openssl x509 -noout -dates 2>&1 \
    | tee -a "$OUTFILE" \
    || log_err "Nem sikerült lekérni a tanúsítványt (van https? jó a host?)"
}

whois_lookup() {
  target="$1"
  [ -z "$target" ] && { log_err "Nincs megadva IP vagy domain."; return 1; }

  log_info "WHOIS: $target"
  echo ""
  log_file ""
  log_file "===== WHOIS: $target ====="

  if ! command -v whois >/dev/null 2>&1; then
    log_err "whois nincs telepítve."
    return 1
  fi

  # első 80 sor elég szokott lenni
  whois "$target" 2>&1 | sed -n '1,80p' | tee -a "$OUTFILE"
  echo ""
  log_info "(csak az első 80 sor; ha kell, bővítjük)"
}

geoip_lookup() {
  ip="$1"
  [ -z "$ip" ] && { log_err "Nincs IP megadva."; return 1; }

  log_info "GeoIP: $ip"
  echo ""
  log_file ""
  log_file "===== GeoIP: $ip ====="

  if command -v geoiplookup >/dev/null 2>&1; then
    geoiplookup "$ip" 2>&1 | tee -a "$OUTFILE" || log_err "GeoIP lookup nem ment."
  else
    log_err "geoiplookup nincs telepítve."
  fi
}

log_top_ips() {
  log_info "Top IP-k logokból (best effort)"
  echo ""
  log_file ""
  log_file "===== Top IP-k logokból ====="

  if [ -f /var/log/nginx/access.log ]; then
    log_info "Nginx access.log top 20:"
    log_file "### Nginx access.log top 20"
    awk '{print $1}' /var/log/nginx/access.log \
      | sort | uniq -c | sort -nr | head -n 20 \
      | tee -a "$OUTFILE"
    echo ""
  else
    log_info "Nincs /var/log/nginx/access.log"
  fi

  for f in /var/log/auth.log /var/log/messages; do
    if [ -f "$f" ]; then
      log_info "SSH auth gyanús IP-k ($f) top 20:"
      log_file "### SSH auth gyanús IP-k ($f) top 20"
      grep -E "Failed password|authentication failure" "$f" 2>/dev/null \
        | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" \
        | sort | uniq -c | sort -nr | head -n 20 \
        | tee -a "$OUTFILE" >/dev/null

      # ha üres lett
      if ! grep -E "Failed password|authentication failure" "$f" 2>/dev/null | grep -qE "([0-9]{1,3}\.){3}[0-9]{1,3}"; then
        log_info "  (nincs találat)"
        log_file "  (nincs találat)"
      fi
      echo ""
      break
    fi
  done
}

fail2ban_status() {
  log_file ""
  log_file "===== Fail2Ban státusz ====="
  if command -v fail2ban-client >/dev/null 2>&1; then
    log_info "Fail2Ban státusz:"
    fail2ban-client status 2>&1 | tee -a "$OUTFILE"
  else
    log_info "Fail2Ban nincs telepítve."
  fi
}

# --- start screen ---
clear
HOSTNAME=$(hostname)
DATE=$(date)
log_info "🛡️ Defensive OSINT / Audit (csak saját célokra)"
log_info "📁 Log mentés: $OUTFILE"

log_file "HackST module: $MODULE_NAME"
log_file "Host: $HOSTNAME"
log_file "Date: $DATE"
log_file "========================================"

# --- menu loop ---
while true; do
  echo ""
  echo "Válassz:"
  echo "1) Public IP + (opcionális) GeoIP"
  echo "2) WHOIS lookup (IP vagy domain)"
  echo "3) DNS check (A/AAAA/MX/SPF/DMARC)"
  echo "4) TLS tanúsítvány lejárat (https host)"
  echo "5) Top IP-k logokból (nginx/auth)"
  echo "6) Fail2Ban status"
  echo "7) Logfájl megnyitása (tail)"
  echo "9) Audit bundle (DNS+TLS+WHOIS)"
  echo "8) Vissza"
  echo ""
  read -p "Választás: " opt

  case "$opt" in
    1)
      ip=$(get_public_ip)
      log_info "Public IP: $ip"
      log_file "Public IP: $ip"
      echo ""
      read -p "GeoIP-et is? (i/n): " yn
      [ "$yn" = "i" ] || [ "$yn" = "I" ] && geoip_lookup "$ip"
      pause
      ;;
    2)
      read -p "IP vagy domain: " t
      whois_lookup "$t"
      pause
      ;;
    3)
      read -p "Domain (pl. example.com): " d
      dns_check "$d"
      pause
      ;;
    4)
      read -p "Host (pl. example.com): " h
      tls_expiry "$h"
      pause
      ;;
    5)
      log_top_ips
      pause
      ;;
    6)
      fail2ban_status
      pause
      ;;
    7)
      log_info "Tail: $OUTFILE"
      echo ""
      tail -n 80 "$OUTFILE"
      pause
      ;;
    9) /usr/local/bin/hackstation/modules/audit_bundle.sh ;;
    8) exit 0 ;;
    *) log_err "Érvénytelen opció." ;;
  esac
done
