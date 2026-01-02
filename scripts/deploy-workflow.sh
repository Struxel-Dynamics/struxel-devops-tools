#!/bin/bash
set -e

if [ -z "$GH_TOKEN" ]; then
  echo "Error: GH_TOKEN not set"
  echo "Usage: GH_TOKEN=your_token ./deploy-workflow.sh"
  exit 1
fi

REPOS=(
  "struxel-platform-api" "struxel-export-worker" "struxel-infra"
  "struxel-admin-ui" "struxel-core" "struxel-bias-engine"
  "struxel-governance-framework" "struxel-predictive-module"
  "struxel-vendor-analyzer" "struxel-compliance-monitor"
  "struxel-data-validator" "curriculum-training" "struxel-api-gateway"
  "struxel-audit-logger" "struxel-identity-manager"
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

WORKFLOW='name: Docker Build and Push

on:
  push:
    branches: [main]
    tags: ["v*"]
  workflow_dispatch:

jobs:
  build:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}'

SUCCESS=0
FAILED=0

echo "🚀 Deploying to ${#REPOS[@]} repositories..."

for REPO in "${REPOS[@]}"; do
  printf "%-40s" "📦 $REPO"
  TEMP=$(mktemp -d)
  
  if git clone -q "https://${GH_TOKEN}@github.com/Struxel-Dynamics/$REPO.git" "$TEMP" 2>/dev/null; then
    cd "$TEMP"
    mkdir -p .github/workflows
    echo "$WORKFLOW" > .github/workflows/docker.yml
    git add .github/workflows/docker.yml
    
    if git commit -q -m "Add Docker workflow" 2>/dev/null && git push -q 2>/dev/null; then
      echo "✅"
      ((SUCCESS++))
    else
      echo "⚠️"
    fi
    cd - >/dev/null 2>&1
  else
    echo "❌"
    ((FAILED++))
  fi
  
  rm -rf "$TEMP"
done

echo ""
echo "=========================================="
echo "📊 Summary: ✅ $SUCCESS | ❌ $FAILED"
echo "=========================================="
