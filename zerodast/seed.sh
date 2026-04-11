#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:9000}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@zerodast.local}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin123!}"

echo "Waiting for Medusa to be ready..."
for i in $(seq 1 90); do
  if curl -sf "${BASE_URL}/health" >/dev/null 2>&1; then
    echo "Medusa is ready"
    break
  fi
  if curl -sf "${BASE_URL}/store/products" >/dev/null 2>&1; then
    echo "Medusa is ready (store endpoint)"
    break
  fi
  echo "Waiting... ($i)"
  sleep 4
done

echo "Creating admin user..."
CREATE_RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST "${BASE_URL}/admin/auth" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}" 2>&1) || true

HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -1)
BODY=$(echo "$CREATE_RESPONSE" | sed '$d')

echo "Admin auth response (${HTTP_CODE}): $(echo "$BODY" | head -c 200)"

echo "Trying admin invite flow..."
curl -sS -X POST "${BASE_URL}/admin/invites" \
  -H "Content-Type: application/json" \
  -d "{\"user\":\"${ADMIN_EMAIL}\",\"role\":\"admin\"}" 2>&1 || true

echo "Seed complete"
