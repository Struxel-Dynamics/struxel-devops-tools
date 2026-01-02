#!/bin/bash

################################################################################
# deploy-workflow.sh
# 
# Deploys Docker workflow configuration to all Struxel-Dynamics repositories
# This script clones each repository, creates .github/workflows/docker.yml
# that uses the reusable workflow from struxel-devops-tools
#
# Author: Struxel-Dynamics DevOps Team
# Created: 2026-01-02
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if GH_TOKEN is set
if [ -z "$GH_TOKEN" ]; then
    echo -e "${RED}ERROR: GH_TOKEN environment variable is not set${NC}"
    echo "Please set your GitHub Personal Access Token:"
    echo "export GH_TOKEN=your_token_here"
    exit 1
fi

# Organization name
ORG="Struxel-Dynamics"

# List of all 47 repositories
REPOSITORIES=(
    "struxel-platform-api"
    "struxel-export-worker"
    "struxel-infra"
    "struxel-admin-ui"
    "struxel-core"
    "struxel-bias-engine"
    "struxel-governance-framework"
    "struxel-predictive-module"
    "struxel-vendor-analyzer"
    "struxel-compliance-monitor"
    "struxel-data-validator"
    "curriculum-training"
    "struxel-api-gateway"
    "struxel-audit-logger"
    "struxel-identity-manager"
    "struxel-predictive-compliance"
    "struxel-risk-forecast"
    "struxel-policy-drift"
    "struxel-contributor-risk"
    "struxel-audit-simulator"
    "struxel-credential-verifier"
    "struxel-consent-tracker"
    "struxel-data-lineage"
    "struxel-prompt-risk"
    "struxel-model-registry"
    "struxel-sla-monitor"
    "struxel-task-runner"
    "struxel-rubric-checker"
    "struxel-audit-artifact-kit"
    "struxel-badge-issuer"
    "struxel-sla-notifier"
    "struxel-client-intake-helper"
    "struxel-dataset-cataloger"
    "struxel-prompt-sanitizer"
    "struxel-fintech-stack"
    "struxel-healthtech-suite"
    "struxel-hrtech-suite"
    "struxel-govtech-suite"
    "struxel-edtech-suite"
    "struxel-retail-analytics-suite"
    "struxel-insurtech-suite"
    "struxel-manufacturtech-suite"
    "struxel-legaltech-suite"
    "struxel-energy-utilities-suite"
    "struxel-devops-tools"
    "struxel-documentation"
    "struxel-terraform-modules"
)

# Workflow content
WORKFLOW_CONTENT='name: Docker Build and Push

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop
  workflow_dispatch:

jobs:
  docker:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/reusable-docker.yml@main
    secrets: inherit
    with:
      image-name: ${{ github.event.repository.name }}
      context: .
      dockerfile: ./Dockerfile
'

# Counters
SUCCESS_COUNT=0
FAILURE_COUNT=0
SKIPPED_COUNT=0
declare -a FAILED_REPOS
declare -a SUCCESSFUL_REPOS
declare -a SKIPPED_REPOS

# Create temporary working directory
WORK_DIR=$(mktemp -d)
echo -e "${BLUE}Working directory: ${WORK_DIR}${NC}"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up temporary directory...${NC}"
    cd /
    rm -rf "$WORK_DIR"
}

trap cleanup EXIT

# Main deployment function
deploy_workflow() {
    local repo=$1
    local repo_url="https://${GH_TOKEN}@github.com/${ORG}/${repo}.git"
    local repo_dir="${WORK_DIR}/${repo}"
    
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Processing: ${repo}${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Clone the repository
    echo -e "${YELLOW}Cloning repository...${NC}"
    if ! git clone --depth 1 "$repo_url" "$repo_dir" 2>&1 | grep -v "Cloning into"; then
        echo -e "${RED}Failed to clone ${repo}${NC}"
        FAILED_REPOS+=("$repo (clone failed)")
        ((FAILURE_COUNT++))
        return 1
    fi
    
    cd "$repo_dir"
    
    # Configure git
    git config user.name "Struxel-Dynamics DevOps Bot"
    git config user.email "devops@struxel-dynamics.com"
    
    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows
    
    # Check if docker.yml already exists
    if [ -f ".github/workflows/docker.yml" ]; then
        echo -e "${YELLOW}docker.yml already exists, checking if update needed...${NC}"
        if echo "$WORKFLOW_CONTENT" | diff -q - .github/workflows/docker.yml > /dev/null 2>&1; then
            echo -e "${GREEN}Workflow is already up to date, skipping...${NC}"
            SKIPPED_REPOS+=("$repo")
            ((SKIPPED_COUNT++))
            cd "$WORK_DIR"
            return 0
        fi
        echo -e "${YELLOW}Updating existing workflow...${NC}"
    fi
    
    # Create the workflow file
    echo "$WORKFLOW_CONTENT" > .github/workflows/docker.yml
    
    # Add and commit changes
    git add .github/workflows/docker.yml
    
    if git diff --staged --quiet; then
        echo -e "${GREEN}No changes to commit, workflow already exists${NC}"
        SKIPPED_REPOS+=("$repo")
        ((SKIPPED_COUNT++))
    else
        echo -e "${YELLOW}Committing changes...${NC}"
        git commit -m "Add Docker workflow using reusable workflow from struxel-devops-tools

This workflow will:
- Build Docker images on push to main/develop branches
- Push images to container registry
- Use the centralized reusable workflow for consistency

Deployed by: deploy-workflow.sh
Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        
        # Push changes
        echo -e "${YELLOW}Pushing changes...${NC}"
        if git push origin main 2>&1; then
            echo -e "${GREEN}Successfully deployed workflow to ${repo}${NC}"
            SUCCESSFUL_REPOS+=("$repo")
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}Failed to push changes to ${repo}${NC}"
            FAILED_REPOS+=("$repo (push failed)")
            ((FAILURE_COUNT++))
        fi
    fi
    
    cd "$WORK_DIR"
}

# Main execution
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Struxel-Dynamics Docker Workflow Deployment Tool       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n${BLUE}Deploying Docker workflows to ${#REPOSITORIES[@]} repositories...${NC}\n"

START_TIME=$(date +%s)

# Process each repository
for repo in "${REPOSITORIES[@]}"; do
    deploy_workflow "$repo"
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Display summary
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    DEPLOYMENT SUMMARY                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n${BLUE}Total repositories processed: ${#REPOSITORIES[@]}${NC}"
echo -e "${GREEN}✓ Successful deployments: ${SUCCESS_COUNT}${NC}"
echo -e "${YELLOW}⊘ Skipped (already up to date): ${SKIPPED_COUNT}${NC}"
echo -e "${RED}✗ Failed deployments: ${FAILURE_COUNT}${NC}"
echo -e "${BLUE}⏱ Total duration: ${DURATION} seconds${NC}\n"

# List successful deployments
if [ ${SUCCESS_COUNT} -gt 0 ]; then
    echo -e "${GREEN}Successful deployments:${NC}"
    for repo in "${SUCCESSFUL_REPOS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $repo"
    done
    echo ""
fi

# List skipped repositories
if [ ${SKIPPED_COUNT} -gt 0 ]; then
    echo -e "${YELLOW}Skipped repositories (already up to date):${NC}"
    for repo in "${SKIPPED_REPOS[@]}"; do
        echo -e "  ${YELLOW}⊘${NC} $repo"
    done
    echo ""
fi

# List failed deployments
if [ ${FAILURE_COUNT} -gt 0 ]; then
    echo -e "${RED}Failed deployments:${NC}"
    for repo in "${FAILED_REPOS[@]}"; do
        echo -e "  ${RED}✗${NC} $repo"
    done
    echo ""
    exit 1
fi

echo -e "${GREEN}All deployments completed successfully!${NC}"
exit 0
