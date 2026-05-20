#!/usr/bin/env bash
# Start vulnerable stack, wait, run before-scan
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}/docker"

echo "Starting vulnerable WordPress stack..."
docker compose -f docker-compose.yml up -d

echo "Waiting for WordPress..."
for i in $(seq 1 60); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ || echo "000")
  if [ "$CODE" = "200" ] || [ "$CODE" = "301" ] || [ "$CODE" = "302" ]; then
    echo "Ready (HTTP ${CODE})."
    break
  fi
  sleep 5
done

"${ROOT}/scripts/run-wpscan.sh" "http://localhost:8080" "before-remediation"
