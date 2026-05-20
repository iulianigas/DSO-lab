#!/usr/bin/env bash
# Run WPScan against local docker-compose WordPress
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="${1:-http://localhost:8080}"
LABEL="${2:-manual}"
OUT_DIR="${ROOT}/scans"
mkdir -p "${OUT_DIR}"

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
TXT="${OUT_DIR}/${LABEL}-${TIMESTAMP}.txt"
JSON="${OUT_DIR}/${LABEL}-${TIMESTAMP}.json"

if ! command -v wpscan &>/dev/null; then
  echo "WPScan not found. Install: gem install wpscan"
  exit 1
fi

echo "Scanning ${URL} -> ${TXT}"
wpscan --url "${URL}" \
  --enumerate u,vp,vt \
  --plugins-detection aggressive \
  --format cli \
  -o "${TXT}" \
  --force || true

wpscan --url "${URL}" \
  --enumerate u,vp,vt \
  --format json \
  -o "${JSON}" \
  --force || true

cp "${TXT}" "${OUT_DIR}/latest-${LABEL}.txt"
echo "Done. Results: ${TXT}"
