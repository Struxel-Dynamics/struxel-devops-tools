#!/bin/bash
set +e

if [ -z "$GH_TOKEN" ]; then
  echo "Error: GH_TOKEN not set"
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

CICD_WORKFLOW='name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request: 
    branches: [main]
  workflow_dispatch:

jobs: 
  ci-cd:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/ci-cd-template.yml@main
    with:
      python_version: "3.11"
      run_tests: true
      run_lint: true
      deploy_environment:  staging
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
'

SUCCESS=0
FAILED=0

echo "🚀 Setting up CI/CD pipelines..."
echo ""

for REPO in "${REPOS[@]}"; do
  printf "%-45s" "📦 $REPO..."
  TEMP=$(mktemp -d)
  
  if git clone -q --depth 1 "https://x-access-token:${GH_TOKEN}@github. com/Struxel-Dynamics/$REPO.git" "$TEMP" 2>/dev/null; then
    cd "$TEMP"
    git config user.name "Struxel DevOps Bot"
    git config user.email "devops@struxeldynamics.com"
    
    mkdir -p .github/workflows
    echo "$CICD_WORKFLOW" > .github/workflows/ci-cd. yml
    git add .github/workflows/ci-cd.yml
    
    if git commit -q -m "Add comprehensive CI/CD pipeline" && git push -q 2>/dev/null; then
      echo "✅"
      ((SUCCESS++))
    else
      echo "❌"
      ((FAILED++))
    fi
    cd /
  else
    echo "❌"
    ((FAILED++))
  fi
  
  rm -rf "$TEMP"
done

echo ""
echo "✅ Success: $SUCCESS | ❌ Failed: $FAILED"
exit 0
