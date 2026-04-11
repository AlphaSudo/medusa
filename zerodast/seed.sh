#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:9000}"

echo "Waiting for Medusa to be ready (may take a few minutes for migrations)..."
for i in $(seq 1 90); do
  if curl -sf "${BASE_URL}/health" >/dev/null 2>&1; then
    echo "Medusa is ready"
    break
  fi
  if [ "$i" -eq 90 ]; then
    echo "ERROR: Medusa did not become healthy"
    exit 1
  fi
  sleep 3
done

echo "Verifying admin login (v2 endpoint)..."
RESP=$(curl -sf -X POST "${BASE_URL}/auth/user/emailpass" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@medusa-test.dev","password":"supersecret"}' 2>&1) || true

if echo "${RESP}" | grep -q "token"; then
  echo "Admin login verified -- JWT obtained"
else
  echo "Warning: admin login response: $(echo "${RESP}" | head -c 300)"
fi

echo "Seed complete"
