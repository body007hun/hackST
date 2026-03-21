#!/bin/sh
# whatweb.sh – webtechnológia-felderítés WhatWeb-bel

. /usr/local/bin/hackstation/lib/common.sh

DEFAULT_TARGET=${1:-"http://127.0.0.1"}
clear
log_info "WhatWeb modul – Webtechnológia felismerés"
echo "--------------------------------"
log_info "A WhatWeb egy webes fingerprinting eszköz, amely megpróbálja"
log_info "azonosítani, hogy egy weboldal milyen technológiákat, szervert,"
log_info "keretrendszert, CMS-t, sütiket, fejléceket vagy egyéb komponenseket használ."
echo ""
log_info "Mire jó?"
echo "  - weboldalak technológiai azonosítására"
echo "  - szerver, CMS, framework, reverse proxy felismerésére"
echo "  - első körös webes felderítésre"
echo "  - audit előtt gyors tájékozódásra"
echo ""
log_info "Példák:"
log_ok "whatweb $DEFAULT_TARGET"                          "Alap felismerés"
log_ok "whatweb -a 3 $DEFAULT_TARGET"                    "Részletesebb vizsgálat"
log_ok "whatweb --no-errors $DEFAULT_TARGET"             "Csendesebb futás"
log_ok "whatweb --log-verbose=whatweb.log $DEFAULT_TARGET" "Részletes log fájlba"
echo ""

target=$(ask_input "Cél URL / host" "$DEFAULT_TARGET")
aggr=$(ask_input "Aggresszivitás (1-4)" "1")
noerr=$(ask_input "Hibákat rejtsük el? (y/n)" "y")
extra_opts=$(ask_input "További WhatWeb opciók" "")
save=$(ask_input "Mentsem a kimenetet fájlba? (y/n)" "y")

cmd="whatweb -a $aggr"

[ "$noerr" = "y" ] && cmd="$cmd --no-errors"
[ -n "$extra_opts" ] && cmd="$cmd $extra_opts"

cmd="$cmd \"$target\""

if [ "$save" = "y" ]; then
  outfile=$(gen_output_path "whatweb")
  log_info "Kimenet mentése ide: $outfile"
  {
    log_info "WhatWeb indítása a következő paraméterekkel:"
    echo "$cmd"
    eval "$cmd"
  } | tee "$outfile"
else
  log_info "WhatWeb indítása a következő paraméterekkel:"
  echo "$cmd"
  eval "$cmd"
fi

exit 0
