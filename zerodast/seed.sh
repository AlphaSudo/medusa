#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:9000}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@zerodast.local}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin123!}"

echo "Waiting for Medusa to be ready..."
for i in $(seq 1 60); do
  if curl -sf "${BASE_URL}/health" >/dev/null 2>&1; then
    echo "Medusa is ready"
    break
  fi
  echo "Waiting... ($i)"
  sleep 3
done

echo "Creating admin user..."
CREATE_RESPONSE=$(curl -sS -w "\n%{http_code}" "${BASE_URL}/admin/users" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\",\"role\":\"admin\"}" 2>&1) || true

HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -1)
BODY=$(echo "$CREATE_RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
  echo "Admin user created"
elif echo "$BODY" | grep -qi "already\|exist\|duplicate"; then
  echo "Admin user already exists, continuing"
else
  echo "Create user response (${HTTP_CODE}): $(echo "$BODY" | head -c 200)"
  echo "Continuing anyway"
fi

echo "Testing auth login..."
LOGIN_RESPONSE=$(curl -sS "${BASE_URL}/auth/user/emailpass" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}" 2>&1) || true

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
  echo "Auth verified -- token obtained"
else
  echo "WARNING: login response: $(echo "$LOGIN_RESPONSE" | head -c 200)"
fi
