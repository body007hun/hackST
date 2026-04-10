#!/bin/sh
# amass.sh – domain / subdomain reconnaissance modul hackST-hez

. /usr/local/bin/hackstation/lib/common.sh

MODULE_NAME="amass"
mkdir -p /root/outputs
OUTFILE="$(gen_output_path "$MODULE_NAME")"

log_file() {
  printf "%s\n" "$*" >> "$OUTFILE"
}

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

pause() {
  echo ""
  read -p "Enter a visszalépéshez..." _
}

run_cmd() {
  title="$1"
  shift

  [ -n "$title" ] && {
    log_info "$title"
    echo ""
    log_file ""
    log_file "### $title"
  }

  "$@" 2>&1 | tee -a "$OUTFILE"
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_err "Hiányzó parancs: $1"
    return 1
  fi
  return 0
}

sanitize_target() {
  echo "$1" | tr '/: ' '___'
}

default_wordlist() {
  for w in \
    /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
    /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt \
    /usr/share/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt \
    /usr/share/wordlists/amass/subdomains.lst
  do
    [ -f "$w" ] && { echo "$w"; return 0; }
  done
  echo ""
  return 1
}

show_last_results() {
  log_info "Utolsó 80 sor:"
  echo ""
  tail -n 80 "$OUTFILE"
}

amass_passive_enum() {
  need_cmd amass || return 1

  domain="$(ask_input "Cél domain" "example.com")"
  [ -z "$domain" ] && { log_err "Nincs domain megadva."; return 1; }

  target_tag="$(sanitize_target "$domain")"
  result_file="/root/outputs/${MODULE_NAME}_${target_tag}_passive.txt"

  log_info "Passzív enum indul: $domain"
  log_info "Log: $OUTFILE"
  log_info "Találatok: $result_file"

  {
    echo "===== AMASS PASSIVE ENUM ====="
    echo "Domain: $domain"
    echo "Date: $(date)"
    echo "=============================="
  } >> "$OUTFILE"

  amass enum -passive -d "$domain" 2>&1 | tee -a "$OUTFILE" | tee "$result_file"

  count="$(grep -vc '^\s*$' "$result_file" 2>/dev/null || echo 0)"
  log_ok "ENUM" "Talált subdomainek: $count"
}

amass_active_enum() {
  need_cmd amass || return 1

  domain="$(ask_input "Cél domain" "example.com")"
  [ -z "$domain" ] && { log_err "Nincs domain megadva."; return 1; }

  read -p "Bruteforce is menjen? (i/n) [i]: " brute_yn
  [ -z "$brute_yn" ] && brute_yn="i"

  extra_args=""
  wordlist=""

  if [ "$brute_yn" = "i" ] || [ "$brute_yn" = "I" ]; then
    wordlist="$(default_wordlist)"
    if [ -n "$wordlist" ]; then
      extra_args="-brute -w $wordlist"
      log_info "Wordlist: $wordlist"
    else
      log_err "Nem találtam alap wordlistet. Bruteforce nélkül folytatom."
    fi
  fi

  target_tag="$(sanitize_target "$domain")"
  result_file="/root/outputs/${MODULE_NAME}_${target_tag}_active.txt"

  log_info "Aktív enum indul: $domain"
  log_info "Log: $OUTFILE"
  log_info "Találatok: $result_file"

  {
    echo "===== AMASS ACTIVE ENUM ====="
    echo "Domain: $domain"
    echo "Date: $(date)"
    echo "Bruteforce: $brute_yn"
    echo "============================="
  } >> "$OUTFILE"

  # shellcheck disable=SC2086
  amass enum -d "$domain" $extra_args 2>&1 | tee -a "$OUTFILE" | tee "$result_file"

  count="$(grep -vc '^\s*$' "$result_file" 2>/dev/null || echo 0)"
  log_ok "ENUM" "Talált subdomainek: $count"
}

amass_intel() {
  need_cmd amass || return 1

  domain="$(ask_input "Cél domain" "example.com")"
  [ -z "$domain" ] && { log_err "Nincs domain megadva."; return 1; }

  target_tag="$(sanitize_target "$domain")"
  result_file="/root/outputs/${MODULE_NAME}_${target_tag}_intel.txt"

  log_info "Intel mód indul: $domain"
  log_info "Találatok: $result_file"

  {
    echo "===== AMASS INTEL ====="
    echo "Domain: $domain"
    echo "Date: $(date)"
    echo "======================="
  } >> "$OUTFILE"

  amass intel -whois -d "$domain" 2>&1 | tee -a "$OUTFILE" | tee "$result_file"
}

amass_reverse_whois_org() {
  need_cmd amass || return 1

  org="$(ask_input "Szervezet neve (reverse whois / intel)" "Example Inc")"
  [ -z "$org" ] && { log_err "Nincs szervezet megadva."; return 1; }

  org_tag="$(sanitize_target "$org")"
  result_file="/root/outputs/${MODULE_NAME}_${org_tag}_orgintel.txt"

  log_info "Org intel indul: $org"
  log_info "Találatok: $result_file"

  {
    echo "===== AMASS ORG INTEL ====="
    echo "Org: $org"
    echo "Date: $(date)"
    echo "==========================="
  } >> "$OUTFILE"

  amass intel -whois -org "$org" 2>&1 | tee -a "$OUTFILE" | tee "$result_file"
}

amass_track_diff() {
  need_cmd amass || return 1

  old_file="$(ask_input "Régi fájl elérési útja" "/root/outputs/amass_example_old.txt")"
  new_file="$(ask_input "Új fájl elérési útja" "/root/outputs/amass_example_new.txt")"

  [ ! -f "$old_file" ] && { log_err "Régi fájl nem található: $old_file"; return 1; }
  [ ! -f "$new_file" ] && { log_err "Új fájl nem található: $new_file"; return 1; }

  diff_file="/root/outputs/${MODULE_NAME}_diff_$(date +%Y%m%d_%H%M%S).txt"

  log_info "Diff készítés indul"
  log_info "Régi: $old_file"
  log_info "Új:   $new_file"
  log_info "Mentés: $diff_file"

  {
    echo "===== AMASS DIFF ====="
    echo "Old: $old_file"
    echo "New: $new_file"
    echo "Date: $(date)"
    echo "======================"
    echo ""
    echo "--- Csak a régiben ---"
    comm -23 "$(sort "$old_file")" "$(sort "$new_file")"
    echo ""
    echo "--- Csak az újban ---"
    comm -13 "$(sort "$old_file")" "$(sort "$new_file")"
  } | tee -a "$OUTFILE" | tee "$diff_file"
}

install_hint() {
  echo ""
  log_info "Telepítési ötletek:"
  echo "  Alpine: apk add amass"
  echo "  Arch:   pacman -S amass"
  echo "  Debian/Ubuntu: apt install amass"
  echo ""
  log_info "Ha nincs repo csomag vagy régi, x86-on mehet Go-ból is."
  echo ""
}

clear
HOSTNAME="$(hostname)"
DATE_NOW="$(date)"

log_info "Amass recon modul"
log_info "Host: $HOSTNAME"
log_info "Log mentés: $OUTFILE"

log_file "HackST module: $MODULE_NAME"
log_file "Host: $HOSTNAME"
log_file "Date: $DATE_NOW"
log_file "========================================"

while true; do
  echo ""
  echo "Válassz:"
  echo "1) Passzív subdomain enum"
  echo "2) Aktív subdomain enum"
  echo "3) Intel / WHOIS domain alapján"
  echo "4) Intel / reverse WHOIS szervezet alapján"
  echo "5) Két korábbi eredmény diff"
  echo "6) Logfájl utolsó sorai"
  echo "7) Telepítési tippek"
  echo "8) Vissza"
  echo ""

  read -p "Választás: " opt

  case "$opt" in
    1)
      amass_passive_enum
      pause
      ;;
    2)
      amass_active_enum
      pause
      ;;
    3)
      amass_intel
      pause
      ;;
    4)
      amass_reverse_whois_org
      pause
      ;;
    5)
      amass_track_diff
      pause
      ;;
    6)
      show_last_results
      pause
      ;;
    7)
      install_hint
      pause
      ;;
    8)
      exit 0
      ;;
    *)
      log_err "Érvénytelen opció."
      ;;
  esac
done
