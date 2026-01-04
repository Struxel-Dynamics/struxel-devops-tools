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

DOCKERFILE='FROM python:3.11-slim

WORKDIR /app

# Copy all application files
COPY .  .

# Install dependencies if requirements. txt exists
RUN if [ -f requirements.txt ]; then \
      pip install --no-cache-dir -r requirements.txt; \
    fi

# Make scripts executable
RUN chmod +x *.sh 2>/dev/null || true

# Environment variables
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 8000

# Default command
CMD ["python", "-m", "http.server", "8000"]
'

DOCKERIGNORE='__pycache__
*.pyc
*. pyo
.git
.github
.env
.venv
venv/
*. md
.DS_Store
'

SUCCESS=0
FAILED=0

echo "🚀 Fixing Dockerfiles in all repositories..."
echo ""

for REPO in "${REPOS[@]}"; do
  printf "%-45s" "📦 $REPO..."
  TEMP=$(mktemp -d)
  
  if git clone -q --depth 1 "https://x-access-token:${GH_TOKEN}@github. com/Struxel-Dynamics/$REPO.git" "$TEMP" 2>/dev/null; then
    cd "$TEMP"
    git config user. name "Struxel DevOps Bot"
    git config user.email "devops@struxeldynamics.com"
    
    echo "$DOCKERFILE" > Dockerfile
    echo "$DOCKERIGNORE" > .dockerignore
    git add Dockerfile .dockerignore
    
    if git diff --staged --quiet; then
      echo "⚠️  No changes"
    else
      if git commit -q -m "Fix Dockerfile to handle missing requirements. txt" && git push -q 2>/dev/null; then
        echo "✅"
        ((SUCCESS++))
      else
        echo "❌"
        ((FAILED++))
      fi
    fi
    cd /
  else
    echo "❌"
    ((FAILED++))
  fi
  
  rm -rf "$TEMP"
done

echo ""
echo "✅ Success:  $SUCCESS | ❌ Failed: $FAILED"
exit 0
