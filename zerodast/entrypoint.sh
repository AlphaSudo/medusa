#!/usr/bin/env bash
set -e

echo "Running Medusa database migrations..."
npx medusa migrations run 2>&1 || echo "Migrations may have already been applied"

echo "Creating admin user..."
npx medusa user -e admin@zerodast.local -p Admin123! 2>&1 || echo "Admin user may already exist"

echo "Starting Medusa server..."
exec npx medusa start
