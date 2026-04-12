#!/bin/sh
set -e

echo "Running Medusa v2 database migrations (must succeed — do not swallow errors)..."
npx medusa db:migrate

echo "Creating admin user..."
npx medusa user -e admin@medusa-test.dev -p supersecret || true

echo "Starting Medusa server..."
exec npx medusa start
