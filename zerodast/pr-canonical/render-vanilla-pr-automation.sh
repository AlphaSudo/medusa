#!/usr/bin/env bash
# Vanilla ZAP PR automation aligned with canonical PR budgets:
# FULL → spider 2m, passive 2m, active 30m, threadPerHost 4.
# Delta → no spider; scoped includePaths + requestor seeds; passive 2m; active 30m; thread 4.
set -euo pipefail

DELTA_FILE="${1:?delta file}"
OUT_YAML="${2:?output yaml}"
TARGET_URL="${3:?target url e.g. http://nocodb:8080}"
SPIDER_URL="${4:-$TARGET_URL}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE="${NODE_BIN:-node}"
SEEDS_JS="${ROOT}/build-request-seeds-vanilla.js"

first="$(head -1 "$DELTA_FILE" | tr -d '\r\n' || true)"

emit_reports() {
  cat <<'_RPT'
  - type: report
    parameters:
      template: "traditional-json"
      reportDir: "/zap/wrk"
      reportFile: "zap-report.json"
  - type: report
    parameters:
      template: "traditional-html"
      reportDir: "/zap/wrk"
      reportFile: "zap-report.html"
_RPT
}

if [[ "$first" == "FULL" ]]; then
  cat > "$OUT_YAML" <<EOF
env:
  contexts:
    - name: "vanilla-baseline-pr"
      urls:
        - "${TARGET_URL}"
      includePaths:
        - "${TARGET_URL}.*"
  parameters:
    failOnError: false
    progressToStdout: true
jobs:
  - type: spider
    parameters:
      context: "vanilla-baseline-pr"
      url: "${SPIDER_URL}"
      maxDuration: 2
      maxDepth: 5
      maxChildren: 50
  - type: passiveScan-wait
    parameters:
      maxDuration: 2
  - type: activeScan
    parameters:
      context: "vanilla-baseline-pr"
      maxRuleDurationInMins: 5
      maxScanDurationInMins: 30
      threadPerHost: 4
      delayInMs: 50
    policyDefinition:
      defaultStrength: medium
      defaultThreshold: low
$(emit_reports)
EOF
else
  {
    echo "env:"
    echo "  contexts:"
    echo "    - name: \"vanilla-baseline-pr\""
    echo "      urls:"
    echo "        - \"${TARGET_URL}\""
    echo "      includePaths:"
    while IFS= read -r line || [[ -n "${line}" ]]; do
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      [[ -z "$line" || "$line" == "FULL" ]] && continue
      path="$line"
      [[ "$path" != /* ]] && path="/${path}"
      esc=$(printf '%s' "$path" | sed 's/[.[\*^$()+?{}|]/\\&/g')
      echo "        - \"${TARGET_URL}${esc}.*\""
    done < "$DELTA_FILE"
    echo "  parameters:"
    echo "    failOnError: false"
    echo "    progressToStdout: true"
    echo "jobs:"
    "${NODE}" "${SEEDS_JS}" "$DELTA_FILE" "$TARGET_URL"
    cat <<'EOF'
  - type: passiveScan-wait
    parameters:
      maxDuration: 2
  - type: activeScan
    parameters:
      context: "vanilla-baseline-pr"
      maxRuleDurationInMins: 5
      maxScanDurationInMins: 30
      threadPerHost: 4
      delayInMs: 50
    policyDefinition:
      defaultStrength: medium
      defaultThreshold: low
EOF
    emit_reports
  } > "$OUT_YAML"
fi
