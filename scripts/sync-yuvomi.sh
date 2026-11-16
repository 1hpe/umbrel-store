#!/usr/bin/env bash
# Copy the official Umbrel Yuvomi app into homelab-yuvomi-test, keeping the
# test app's id, name, port, tagline and red icon. Prints the version; exits 0.
set -euo pipefail
cd "$(dirname "$0")/.."
UP=https://raw.githubusercontent.com/getumbrel/umbrel-apps/master/yuvomi
APP=homelab-yuvomi-test
ICON="https://raw.githubusercontent.com/1hpe/umbrel-store/main/$APP/icon.svg"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$UP/umbrel-app.yml" -o "$tmp/app.yml"
curl -fsSL "$UP/docker-compose.yml" -o "$tmp/compose.yml"

# Sanity checks: refuse to write anything if upstream looks unexpected.
grep -q '^id: yuvomi$' "$tmp/app.yml"            || { echo "upstream id changed" >&2; exit 1; }
grep -q '^port: 8180$' "$tmp/app.yml"            || { echo "upstream port changed" >&2; exit 1; }
grep -q 'APP_HOST: yuvomi_web_1' "$tmp/compose.yml" || { echo "upstream APP_HOST changed" >&2; exit 1; }
grep -Eq '^\s*image: ghcr.io/ulsklyc/yuvomi:' "$tmp/compose.yml" || { echo "upstream image changed" >&2; exit 1; }

sed -e "s/^id: yuvomi\$/id: $APP/" \
    -e 's/^name: Yuvomi$/name: Yuvomi Test/' \
    -e 's/^port: 8180$/port: 8181/' \
    -e 's/^tagline: .*/tagline: TEST copy of Yuvomi — try updates here first/' \
    -e '/^gallery:/,/^path:/{/^gallery:/d;/^  - /d}' \
    -e '/^submission:/d' -e '/^submitter:/d' \
    -e "/^port: 8181\$/a icon: $ICON" \
    "$tmp/app.yml" > "$APP/umbrel-app.yml"

# Upstream compose with only the container name changed; keep our key comment.
sed -e "s/APP_HOST: yuvomi_web_1/APP_HOST: ${APP}_web_1/" \
    -e 's|^\(\s*\)- DB_ENCRYPTION_KEY=|\1# Yuvomi Test: override DB_ENCRYPTION_KEY in Umbrel (custom env) with the REAL Yuvomi key. Never commit it.\n\1- DB_ENCRYPTION_KEY=|' \
    "$tmp/compose.yml" > "$APP/docker-compose.yml"

grep -m1 '^version:' "$APP/umbrel-app.yml"
