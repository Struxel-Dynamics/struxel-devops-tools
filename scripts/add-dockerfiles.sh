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

DOCKERFILE='# Multi-stage build for Python application
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt* ./
RUN pip install --user --no-cache-dir -r requirements.txt 2>/dev/null || echo "No requirements.txt found"

# Production stage
FROM python:3.11-slim

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY . .

# Make sure scripts are executable
RUN chmod +x *.sh 2>/dev/null || true

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH=/root/.local/bin:$PATH

# Expose port (adjust as needed)
EXPOSE 8000

# Default command (adjust based on your app)
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
'

DOCKERIGNORE='__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
.env
.venv
env/
venv/
ENV/
.git/
.github/
.gitignore
*.md
.DS_Store
*.log
.pytest_cache/
.coverage
htmlcov/
.tox/
.mypy_cache/
.idea/
.vscode/
'

SUCCESS=0
SKIPPED=0
FAILED=0

echo "🚀 Adding Dockerfiles to repositories..."
echo ""

for REPO in "${REPOS[@]}"; do
  printf "%-45s" "📦 Processing $REPO..."
  TEMP=$(mktemp -d)
  
  if git clone -q --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/Struxel-Dynamics/$REPO.git" "$TEMP" 2>/dev/null; then
    cd "$TEMP"
    
    # Check if Dockerfile already exists
    if [ -f "Dockerfile" ]; then
      echo "⚠️  Dockerfile exists"
      ((SKIPPED++))
    else
      git config user.name "Struxel DevOps Bot"
      git config user.email "devops@struxeldynamics.com"
      
      echo "$DOCKERFILE" > Dockerfile
      echo "$DOCKERIGNORE" > .dockerignore
      
      git add Dockerfile .dockerignore
      
      if git commit -q -m "Add Dockerfile and .dockerignore for containerization" && git push -q 2>/dev/null; then
        echo "✅ Added"
        ((SUCCESS++))
      else
        echo "❌ Failed"
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
echo "✅ Successfully added: $SUCCESS"
echo "⚠️  Already have Dockerfile: $SKIPPED"
echo "❌ Failed: $FAILED"
echo "=========================================="

exit 0