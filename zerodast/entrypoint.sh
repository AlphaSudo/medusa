#!/usr/bin/env bash
set -e

echo "Running Medusa database migrations..."
npx medusa migrations run 2>&1 || echo "Migrations may have already been applied"

echo "Starting Medusa server..."
exec npx medusa start
