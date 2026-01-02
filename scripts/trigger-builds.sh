#!/bin/bash
set +e

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN not set"
  exit 1
fi

REPOS=(
  "struxel-platform-api" "struxel-export-worker" "struxel-infra"
  "struxel-admin-ui" "struxel-core" "struxel-bias-engine"
  "struxel-governance-framework" "struxel-predictive-module"
  "struxel-vendor-analyzer" "struxel-compliance-monitor"
  "struxel-data-validator" "curriculum-training"
  "struxel-api-gateway" "struxel-audit-logger" "struxel-identity-manager"
  "struxel-predictive-compliance" "struxel-risk-forecast"
  "struxel-policy-drift" "struxel-contributor-risk"
  "struxel-audit-simulator" "struxel-credential-verifier"
  "struxel-consent-tracker" "struxel-data-lineage"
  "struxel-prompt-risk" "struxel-model-registry" "struxel-sla-monitor"
  "struxel-task-runner" "struxel-rubric-checker"
  "struxel-audit-artifact-kit" "struxel-badge-issuer"
  "struxel-sla-notifier" "struxel-client-intake-helper"
  "struxel-dataset-cataloger" "struxel-prompt-sanitizer"
  "struxel-fintech-stack" "struxel-healthtech-suite"
  "struxel-hrtech-suite" "struxel-govtech-suite" "struxel-edtech-suite"
  "struxel-retail-analytics-suite" "struxel-insurtech-suite"
  "struxel-manufacturtech-suite" "struxel-legaltech-suite"
  "struxel-energy-utilities-suite"
)

SUCCESS=0
FAILED=0
SKIPPED=0

echo "🚀 Triggering Docker builds..."
echo ""

for REPO in "${REPOS[@]}"; do
  printf "%-45s" "📦 $REPO..."
  
  RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/Struxel-Dynamics/${REPO}/actions/workflows/docker.yml/dispatches" \
    -d '{"ref":"main"}')
  
  if [ "$RESPONSE" == "204" ]; then
    echo "✅"
    ((SUCCESS++))
  elif [ "$RESPONSE" == "404" ]; then
    echo "⚠️"
    ((SKIPPED++))
  else
    echo "❌"
    ((FAILED++))
  fi
  
  sleep 0.3
done

echo ""
echo "✅ Success: $SUCCESS | ⚠️  Skipped: $SKIPPED | ❌ Failed: $FAILED"
exit 0
