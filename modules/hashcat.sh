#!/bin/sh
# hashcat.sh – hash audit / jelszó-visszafejtési próbák Hashcat-tel

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_HASHFILE="/usr/local/bin/hackstation/data/hashcat_hashes.txt"
DEFAULT_WORDLIST="/usr/local/bin/hackstation/data/passlist.txt"

clear
log_info "Hashcat modul – Hash audit és jelszóteszt"
echo "--------------------------------"
log_info "A Hashcat egy nagy teljesítményű hash-audit eszköz, amellyel"
log_info "különböző jelszó-hash formátumokat lehet ellenőrizni szólistás,"
log_info "mask alapú vagy kombinált próbálkozásokkal."
echo ""
log_info "Mire jó?"
echo "  - hash-ek típusának megfelelő auditjára"
echo "  - gyenge jelszavak felismerésére"
echo "  - wordlist alapú jelszótesztre"
echo "  - szabályalapú / mask alapú próbálkozásokra"
echo ""
log_info "Fontos:"
echo "  - csak saját vagy engedéllyel vizsgált adatokon használd"
echo "  - kis gépen lassú lehet"
echo "  - GPU nélkül is működhet, de sokkal lassabb"
echo ""
log_info "Gyakori hash módok:"
echo "  0    = MD5"
echo "  100  = SHA1"
echo "  1000 = NTLM"
echo "  1800 = sha512crypt"
echo "  3200 = bcrypt"
echo ""
log_info "Példák:"
log_ok "hashcat -m 0 -a 0 hashes.txt wordlist.txt"           "MD5 hash + szólista"
log_ok "hashcat -m 1000 -a 0 hashes.txt wordlist.txt"        "NTLM hash + szólista"
log_ok "hashcat -m 0 -a 3 hashes.txt ?a?a?a?a"               "Mask attack"
log_ok "hashcat --show -m 0 hashes.txt"                      "Talált jelszavak megjelenítése"
echo ""

mode=$(ask_input "Hash mód (pl. 0=MD5, 100=SHA1, 1000=NTLM)" "0")
attack=$(ask_input "Attack mód (0=wordlist, 3=mask, 6/7=combi)" "0")
hashfile=$(ask_input "Hash fájl" "$DEFAULT_HASHFILE")

case "$attack" in
  0)
    wordlist=$(ask_input "Szólista" "$DEFAULT_WORDLIST")
    extra_opts=$(ask_input "További Hashcat opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")
    cmd="hashcat -m $mode -a 0 \"$hashfile\" \"$wordlist\""
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  3)
    mask=$(ask_input "Mask minta (pl. ?a?a?a?a)" "?a?a?a?a")
    extra_opts=$(ask_input "További Hashcat opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")
    cmd="hashcat -m $mode -a 3 \"$hashfile\" \"$mask\""
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  6|7)
    wordlist1=$(ask_input "Első szólista" "$DEFAULT_WORDLIST")
    wordlist2=$(ask_input "Második szólista" "$DEFAULT_WORDLIST")
    extra_opts=$(ask_input "További Hashcat opciók" "")
    save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")
    cmd="hashcat -m $mode -a $attack \"$hashfile\" \"$wordlist1\" \"$wordlist2\""
    [ -n "$extra_opts" ] && cmd="$cmd $extra_opts"
    ;;
  *)
    log_err "Ismeretlen attack mód. Használható: 0, 3, 6, 7"
    exit 1
    ;;
esac

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "hashcat")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "Hashcat indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "Hashcat indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
