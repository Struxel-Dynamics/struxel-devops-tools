#!/bin/bash
set +e  # Don't exit on error

REPOS=(
  "struxel-platform-api" "struxel-export-worker" "struxel-infra" "struxel-admin-ui" "struxel-core" "struxel-bias-engine" "struxel-governance-framework" "struxel-predictive-module" "struxel-vendor-analyzer" "struxel-compliance-monitor" "struxel-data-validator" "curriculum-training" "struxel-api-gateway" "struxel-audit-logger" "struxel-identity-manager" "struxel-predictive-compliance" "struxel-risk-forecast" "struxel-policy-drift" "struxel-contributor-risk" "struxel-audit-simulator" "struxel-credential-verifier" "struxel-consent-tracker" "struxel-data-lineage" "struxel-prompt-risk" "struxel-model-registry" "struxel-sla-monitor" "struxel-task-runner" "struxel-rubric-checker" "struxel-audit-artifact-kit" "struxel-badge-issuer" "struxel-sla-notifier" "struxel-client-intake-helper" "struxel-dataset-cataloger" "struxel-prompt-sanitizer" "struxel-fintech-stack" "struxel-healthtech-suite" "struxel-hrtech-suite" "struxel-govtech-suite" "struxel-edtech-suite" "struxel-retail-analytics-suite" "struxel-insurtech-suite" "struxel-manufacturtech-suite" "struxel-legaltech-suite" "struxel-energy-utilities-suite"
)

for REPO in "${REPOS[@]}"; do
  echo "Deploying to $REPO..."
  git clone --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/Struxel-Dynamics/$REPO.git" /tmp/$REPO 2>/dev/null && \
  cd /tmp/$REPO && \
  mkdir -p .github/workflows && \
  cat > .github/workflows/docker. yml << 'EOF'
name: Docker Build

on:
  push:
    branches: [main]

jobs:
  build:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    secrets:  inherit
EOF
  git add .github/workflows/docker. yml && \
  git commit -m "Add Docker workflow" && \
  git push && \
  echo "✅ $REPO" || echo "❌ $REPO"
  rm -rf /tmp/$REPO
done

echo "Deployment complete!"
