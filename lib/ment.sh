#!/bin/sh

SZERVER="192.168.1.22"
FELHASZNALO="ment"
SSH_KULCS="~/.ssh/alpine_backup_key"
SSH_OPTS="-i $SSH_KULCS -o StrictHostKeyChecking=no"
CEL_UTVONAL="/mnt/store/alpine"
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
