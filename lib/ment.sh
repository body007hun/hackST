#!/bin/sh
set -eu

CONF_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/../conf" && pwd)"
CONF_FILE="$CONF_DIR/ment.conf"

if [ -f "$CONF_FILE" ]; then
  # shellcheck disable=SC1090
  . "$CONF_FILE"
else
  echo "[ERROR] Hiányzó config: $CONF_FILE"
  echo "Másold ide: $CONF_DIR/ment.conf.example -> ment.conf és töltsd ki."
  exit 1
fi

SSH_OPTS="-i $SSH_KULCS -o StrictHostKeyChecking=no"
DATUM=$(date +%Y-%m-%d_%H-%M)
MENTES_DIR="backup_$DATUM"

echo "📦 Teljes rendszer mentése indul..."

# Távoli könyvtár létrehozása
ssh $SSH_OPTS "$FELHASZNALO@$SZERVER" "mkdir -p '$CEL_UTVONAL/$MENTES_DIR'"

# Backup lefuttatása, most már helyesen kizárva a cuccokat
rsync -a --info=progress2 --delete \
  --exclude="/dev" \
  --exclude="/proc" \
  --exclude="/sys" \
  --exclude="/tmp" \
  --exclude="/run" \
  --exclude="/mnt" \
  --exclude="/media" \
  --exclude="/lost+found" \
  --exclude="/var/cache" \
  --exclude="/swapfile" \
  --exclude="$CEL_UTVONAL" \
  -e "ssh $SSH_OPTS" \
  / "$FELHASZNALO@$SZERVER:$CEL_UTVONAL/$MENTES_DIR/"

echo "✅ Rendszer backup kész: $CEL_UTVONAL/$MENTES_DIR"
