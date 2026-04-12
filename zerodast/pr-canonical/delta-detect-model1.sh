#!/usr/bin/env bash
# Git-diff delta for Model 1 fork PR scans (aligns with main-repo delta-detect.sh intent).
# Emits a single line "FULL" when core/safety-sensitive paths change or no route hints;
# otherwise one route path per line (prefix match for ZAP includePaths).
set -euo pipefail

BASE_REF="${BASE_REF:-origin/main}"
HEAD_REF="${HEAD_REF:-HEAD}"

ROUTE_CHANGES=""
CORE_CHANGED=false

extract_routes_from_file() {
  local file="$1"
  grep -oE "(router|app)\.(get|post|put|delete|patch)\s*\(['\"][^'\"]+['\"]" "$file" \
    | grep -oE "['\"][^'\"]+['\"]" \
    | tr -d "'\"" || true
}

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  case "$file" in
    zerodast/*|.github/workflows/*|docker-compose*|compose.yml|compose.yaml|Dockerfile*|Dockerfile)
      CORE_CHANGED=true
      ;;
    */middleware/*|*/db.*|package.json|package-lock.json|yarn.lock|pnpm-lock.yaml|pnpm-workspace.yaml|go.mod|go.sum|Cargo.toml|pom.xml|build.gradle*)
      CORE_CHANGED=true
      ;;
    */routes/*.js|*/routes/*.ts|*/routes/*.json|*/controllers/*.js|*/controllers/*.ts|*/controllers/*.py)
      endpoints=$(extract_routes_from_file "$file" || true)
      ROUTE_CHANGES="$ROUTE_CHANGES $endpoints"
      ;;
  esac
done < <(git diff --name-only "${BASE_REF}...${HEAD_REF}" 2>/dev/null || true)

if [[ "$CORE_CHANGED" == true ]] || [[ -z "$(echo "$ROUTE_CHANGES" | tr -d '[:space:]')" ]]; then
  echo "FULL"
  exit 0
fi

echo "$ROUTE_CHANGES" | tr ' ' '\n' | sort -u | grep -v '^$'
