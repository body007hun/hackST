#!/bin/sh

# common.sh: helper funkciók és színezések

INFO="\033[1;34m[INFO]\033[0m"
OK="\033[1;32m[OK]\033[0m"
ERR="\033[1;31m[HIBA]\033[0m"

log_info() {
  local msg="$*"
  printf "%b %s\n" "$INFO" "$msg"
}

log_err() {
  local msg="$*"
  printf "%b %s\n" "$ERR" "$msg"
}

log_ok() {
  local tag="$1"
  local msg="$2"
  printf "%b %-10s %b %s\n" "$OK" "$tag" "$INFO" "$msg"
}

# Központi output könyvtár feloldása
get_output_dir() {
  if [ -n "$HACKST_OUTPUT_DIR" ]; then
    echo "$HACKST_OUTPUT_DIR"
  elif [ "$(id -u)" -eq 0 ] 2>/dev/null; then
    echo "/root/outputs"
  else
    echo "$HOME/outputs"
  fi
}

# Automatikus mentéskönyvtár és fájlnév
gen_output_path() {
  local module_name="$1"
  local outdir

  outdir="$(get_output_dir)"
  mkdir -p "$outdir" 2>/dev/null

  echo "$outdir/${module_name}-$(date +"%Y%m%d-%H%M%S").log"
}

# Biztonságos kérdéskérés alapértékkel
ask_input() {
  local prompt="$1"
  local default="$2"
  local result
  read -p "$prompt [$default]: " result
  echo "${result:-$default}"
}

# Hiányzó menüpontok
run_named_module() {
  local name="$1"
  local mod="$2"
  shift 2

  if [ -x "$mod" ]; then
    "$mod" "$@"
  else
    log_err "A(z) $name modul még nincs telepítve / nincs futtathatóvá téve."
    echo "Hiányzó fájl: $mod"
    echo ""
    read -p "Enter a visszalépéshez..." dummy
  fi
}
