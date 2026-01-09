#!/bin/sh
. /usr/local/bin/hackstation/lib/common.sh

MODULE_NAME="audit_bundle"
mkdir -p /root/outputs
OUTFILE="$(gen_output_path "$MODULE_NAME")"

log_file() { printf "%s\n" "$*" >> "$OUTFILE"; }

# Override loggers: terminal color + file plain
log_info() { printf "%b %s\n" "$INFO" "$*"; log_file "[INFO] $*"; }
log_err()  { printf "%b %s\n" "$ERR"  "$*"; log_file "[HIBA] $*"; }
log_ok() {
  local tag="$1"; local msg="$2"
  printf "%b %-10s %b %s\n" "$OK" "$tag" "$INFO" "$msg"
  log_file "[OK] $tag - $msg"
}

pause() { echo ""; read -p "Enter a kilépéshez..." _; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Run command and tee to log
run() { "$@" 2>&1 | tee -a "$OUTFILE"; }

section() {
  title="$1"
  echo ""
  log_info "$title"
  log_file "========================================"
  log_file "$title"
  log_file "========================================"
}

# --- checks ---
dns_check() {
  domain="$1"
  section "DNS check: $domain"

  if ! have_cmd dig; then
    log_err "dig nincs telepítve (apk add bind-tools)."
    return 1
  fi

  echo "A:"    | tee -a "$OUTFILE"
  run dig +short A "$domain" | sed 's/^/  /' | tee -a "$OUTFILE" >/dev/null

  echo "AAAA:" | tee -a "$OUTFILE"
  run dig +short AAAA "$domain" | sed 's/^/  /' | tee -a "$OUTFILE" >/dev/null

  echo "MX:"   | tee -a "$OUTFILE"
  run dig +short MX "$domain" | sed 's/^/  /' | tee -a "$OUTFILE" >/dev/null

  echo "SPF (TXT v=spf1):" | tee -a "$OUTFILE"
  spf=$(dig +short TXT "$domain" 2>/dev/null | grep -i "v=spf1" || true)
  if [ -n "$spf" ]; then
    printf "  %s\n" "$spf" | tee -a "$OUTFILE"
  else
    echo "  (nincs SPF TXT találat)" | tee -a "$OUTFILE"
  fi

  echo "DMARC (TXT _dmarc.${domain}):" | tee -a "$OUTFILE"
  dmarc=$(dig +short TXT "_dmarc.$domain" 2>/dev/null || true)
  if [ -n "$dmarc" ]; then
    printf "  %s\n" "$dmarc" | tee -a "$OUTFILE"
  else
    echo "  (nincs DMARC TXT találat)" | tee -a "$OUTFILE"
  fi

  return 0
}

tls_check() {
  host="$1"
  section "TLS tanúsítvány: $host:443"

  if ! have_cmd openssl; then
    log_err "openssl nincs telepítve (apk add openssl)."
    return 1
  fi

  # dates
  out="$( (echo | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null) || true )"
  if [ -z "$out" ]; then
    log_err "Nem sikerült certet lekérni (van https? jó a host?)."
    return 1
  fi

  printf "%s\n" "$out" | tee -a "$OUTFILE"

  # Quick expiry heuristic: if openssl can parse enddate, show remaining days (best effort)
  end=$(printf "%s\n" "$out" | sed -n 's/^notAfter=//p')
  if [ -n "$end" ] && have_cmd date; then
    # Alpine date supports -d
    end_ts=$(date -d "$end" +%s 2>/dev/null || echo "")
    now_ts=$(date +%s 2>/dev/null || echo "")
    if [ -n "$end_ts" ] && [ -n "$now_ts" ]; then
      rem=$(( (end_ts - now_ts) / 86400 ))
      echo "Hátralévő napok (kb): $rem" | tee -a "$OUTFILE"
    fi
  fi

  return 0
}

whois_check() {
  target="$1"
  section "WHOIS: $target"

  if ! have_cmd whois; then
    log_err "whois nincs telepítve (apk add whois)."
    return 1
  fi

  # first 120 lines to be a bit more useful in bundle
  run whois "$target" | sed -n '1,120p' | tee -a "$OUTFILE" >/dev/null
  log_info "(WHOIS első 120 sor mentve.)"
  return 0
}

# --- main ---
clear
HOSTNAME=$(hostname)
DATE=$(date)
log_info "📦 Audit bundle (DNS + TLS + WHOIS) – csak saját célokra"
log_info "📁 Log: $OUTFILE"

log_file "HackST module: $MODULE_NAME"
log_file "Host: $HOSTNAME"
log_file "Date: $DATE"

echo ""
DOMAIN="$(ask_input "Domain" "example.com")"
WHOIS_TARGET="$(ask_input "WHOIS target (domain vagy IP)" "$DOMAIN")"
TLS_HOST="$(ask_input "TLS host (https)" "$DOMAIN")"

# Run checks and track status
FAILS=0
dns_check "$DOMAIN" || FAILS=$((FAILS+1))
tls_check "$TLS_HOST" || FAILS=$((FAILS+1))
whois_check "$WHOIS_TARGET" || FAILS=$((FAILS+1))

# Summary
echo ""
log_file ""
log_file "===== SUMMARY ====="
if [ "$FAILS" -eq 0 ]; then
  log_ok "SUMMARY" "Minden ellenőrzés lefutott hiba nélkül."
  log_file "SUMMARY: OK"
else
  log_err "Összesítés: $FAILS rész hibázott / hiányzó függőség / elérhetőség."
  log_file "SUMMARY: FAILS=$FAILS"
fi

echo ""
log_info "Kész. Logfájl: $OUTFILE"
pause
