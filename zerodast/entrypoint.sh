#!/bin/sh
set -e

echo "Running Medusa database migrations..."
npx medusa migrations run 2>&1 || echo "Migrations may have already been applied"

echo "Seeding database with default data..."
npx medusa seed --seed-file=data/seed.json 2>&1 || echo "Seed may have already been applied"

echo "Starting Medusa server..."
exec npx medusa start
