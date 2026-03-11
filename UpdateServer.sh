#!/usr/bin/env bash
set -euo pipefail

# === Config ===
HOST="89.167.98.24"
USER="tal"
REMOTE_WEB_ROOT="/var/www/html"
REMOTE_TMP="/tmp"
FILES=("index.html" "TalPhoto.JPG")

# === Checks ===
for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Missing file: $f"
    echo "Make sure you're running this script from the folder that contains your website files."
    exit 1
  fi
done

echo "Uploading files to ${USER}@${HOST}:${REMOTE_TMP} ..."
scp "${FILES[@]}" "${USER}@${HOST}:${REMOTE_TMP}/"

echo "Deploying on server (moving into ${REMOTE_WEB_ROOT}) ..."
ssh -t "${USER}@${HOST}" bash -lc "'
  set -euo pipefail

  sudo mkdir -p \"${REMOTE_WEB_ROOT}\"

  sudo mv \"${REMOTE_TMP}/index.html\" \"${REMOTE_WEB_ROOT}/index.html\"
  sudo mv \"${REMOTE_TMP}/TalPhoto.JPG\" \"${REMOTE_WEB_ROOT}/TalPhoto.JPG\"

  sudo chown -R www-data:www-data \"${REMOTE_WEB_ROOT}\"
  sudo chmod -R 755 \"${REMOTE_WEB_ROOT}\"

  sudo nginx -t
  sudo systemctl reload nginx
'"

echo "✅ Deployed successfully."
echo "Open: http://${HOST}"
