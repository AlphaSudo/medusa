#!/bin/sh
set -e

echo "Running Medusa v2 database migrations..."
npx medusa db:migrate 2>&1 || echo "Migrations may have already been applied"

echo "Creating admin user..."
npx medusa user -e admin@medusa-test.dev -p supersecret 2>&1 || echo "Admin user may already exist"

echo "Starting Medusa server..."
exec npx medusa start
