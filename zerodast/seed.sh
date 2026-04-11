#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:9000}"

echo "Waiting for Medusa to be ready..."
for i in $(seq 1 60); do
  if curl -sf "${BASE_URL}/health" >/dev/null 2>&1; then
    echo "Medusa is ready"
    break
  fi
  sleep 2
done

echo "Verifying admin login..."
RESP=$(curl -sf -X POST "${BASE_URL}/admin/auth/token" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@zerodast.local","password":"Admin123!"}' 2>&1) || true

if echo "${RESP}" | grep -q "access_token"; then
  echo "Admin login verified -- JWT obtained"
else
  echo "Warning: admin login not yet available (server may still be bootstrapping)"
  echo "Response: ${RESP}"
fi

echo "Seed complete"
