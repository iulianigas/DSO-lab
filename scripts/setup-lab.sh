#!/usr/bin/env bash
# Start vulnerable stack, wait, run before-scan
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}/docker"

echo "Starting vulnerable WordPress stack..."
docker compose -f docker-compose.yml up -d

echo "Waiting for WordPress..."
for i in $(seq 1 40); do
  if curl -sf http://localhost:8080/ | grep -qi "wordpress\|wp-content"; then
    echo "Ready."
    break
  fi
  sleep 5
done

"${ROOT}/scripts/run-wpscan.sh" "http://localhost:8080" "before-remediation"
