#!/bin/bash

################################################################################
# Deploy Docker Workflow Script
# 
# This script deploys the reusable Docker workflow to all Struxel-Dynamics
# repositories by creating .github/workflows/docker.yml in each repository.
#
# Requirements:
#   - GH_TOKEN environment variable must be set with appropriate permissions
#   - GitHub CLI (gh) must be installed
#
# Usage:
#   export GH_TOKEN=your_github_token
#   ./deploy-workflow.sh
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
    echo "Please export GH_TOKEN with a valid GitHub token:"
    echo "  export GH_TOKEN=your_github_token"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}ERROR: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Organization name
ORG="Struxel-Dynamics"

# Array of all 47 repositories
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
)

# Docker workflow content
WORKFLOW_CONTENT='name: Docker Build and Push

on:
  push:
    branches:
      - main
      - develop
    tags:
      - "v*.*.*"
  pull_request:
    branches:
      - main
      - develop

jobs:
  docker:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/reusable-docker.yml@main
    secrets: inherit
'

# Counters for summary
SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_REPOS=()

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}Docker Workflow Deployment Script${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "Organization: ${GREEN}${ORG}${NC}"
echo -e "Total repositories: ${GREEN}${#REPOSITORIES[@]}${NC}"
echo ""
echo -e "${YELLOW}Starting deployment...${NC}"
echo ""

# Function to deploy workflow to a single repository
deploy_to_repo() {
    local repo=$1
    local repo_full="${ORG}/${repo}"
    
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} Processing: ${repo}"
    
    # Create temporary file for workflow content
    local temp_file=$(mktemp)
    echo "$WORKFLOW_CONTENT" > "$temp_file"
    
    # Check if repository exists and is accessible
    if ! gh repo view "$repo_full" &> /dev/null; then
        echo -e "  ${RED}✗ Failed: Repository not found or not accessible${NC}"
        rm "$temp_file"
        return 1
    fi
    
    # Create .github/workflows directory structure and push workflow file
    # Using gh api to create/update file
    local encoded_content=$(base64 < "$temp_file" | tr -d '\n')
    local file_path=".github/workflows/docker.yml"
    
    # Check if file already exists to get its SHA
    local existing_sha=""
    existing_sha=$(gh api "repos/${repo_full}/contents/${file_path}" \
        --jq '.sha' 2>/dev/null || echo "")
    
    # Prepare API request
    local api_data="{
        \"message\": \"Add Docker workflow using reusable workflow from struxel-devops-tools\",
        \"content\": \"${encoded_content}\",
        \"branch\": \"main\"
    }"
    
    # Add SHA if file exists (update) instead of create
    if [ -n "$existing_sha" ]; then
        api_data=$(echo "$api_data" | jq --arg sha "$existing_sha" '. + {sha: $sha}')
        echo -e "  ${YELLOW}ℹ Updating existing workflow file${NC}"
    else
        echo -e "  ${YELLOW}ℹ Creating new workflow file${NC}"
    fi
    
    # Create or update the file
    if echo "$api_data" | gh api "repos/${repo_full}/contents/${file_path}" \
        --method PUT \
        --input - &> /dev/null; then
        echo -e "  ${GREEN}✓ Successfully deployed workflow${NC}"
        rm "$temp_file"
        return 0
    else
        echo -e "  ${RED}✗ Failed to deploy workflow${NC}"
        rm "$temp_file"
        return 1
    fi
}

# Deploy to all repositories
for repo in "${REPOSITORIES[@]}"; do
    if deploy_to_repo "$repo"; then
        ((SUCCESS_COUNT++))
    else
        ((FAILED_COUNT++))
        FAILED_REPOS+=("$repo")
    fi
    echo ""
done

# Print summary
echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}Deployment Summary${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "Total repositories: ${BLUE}${#REPOSITORIES[@]}${NC}"
echo -e "Successful deployments: ${GREEN}${SUCCESS_COUNT}${NC}"
echo -e "Failed deployments: ${RED}${FAILED_COUNT}${NC}"
echo ""

# Print failed repositories if any
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "${RED}Failed repositories:${NC}"
    for repo in "${FAILED_REPOS[@]}"; do
        echo -e "  - ${repo}"
    done
    echo ""
    exit 1
else
    echo -e "${GREEN}✓ All workflows deployed successfully!${NC}"
    echo ""
    exit 0
fi
