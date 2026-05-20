#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-wordpress-hardened:local}"

docker build -f "${ROOT}/dockerfiles/Dockerfile.hardened" -t "${TAG}" "${ROOT}"
echo "Built ${TAG}"
echo "Run: HARDENED_IMAGE=${TAG} docker compose -f docker/docker-compose.hardened.yml up -d"
