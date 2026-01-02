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
      DOCKER_USERNAME: ${{ secrets. DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets. DOCKER_PASSWORD }}'

SUCCESS=0
FAILED=0

echo "🚀 Deploying Docker workflows to ${#REPOS[@]} repositories..."
echo ""

for REPO in "${REPOS[@]}"; do
  printf "%-45s" "📦 Processing $REPO..."
  TEMP=$(mktemp -d)
  
  if git clone -q --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/Struxel-Dynamics/$REPO.git" "$TEMP" 2>/dev/null; then
    cd "$TEMP"
    git config user.name "Struxel DevOps Bot"
    git config user. email "devops@struxeldynamics.com"
    
    mkdir -p .github/workflows
    echo "$WORKFLOW" > .github/workflows/docker. yml
    git add .github/workflows/docker.yml
    
    if git diff --staged --quiet; then
      echo "⚠️  No changes"
    else
      if git commit -q -m "Update Docker workflow with correct secrets" && git push -q 2>/dev/null; then
        echo "✅ Success"
        ((SUCCESS++))
      else
        echo "❌ Push failed"
        ((FAILED++))
      fi
    fi
    cd /
  else
    echo "❌ Clone failed"
    ((FAILED++))
  fi
  
  rm -rf "$TEMP"
done

echo ""
echo "=========================================="
echo "✅ Successfully deployed:  $SUCCESS"
echo "❌ Failed: $FAILED"
echo "=========================================="

exit 0
