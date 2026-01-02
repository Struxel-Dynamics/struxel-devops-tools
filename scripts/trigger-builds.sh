#!/bin/bash

# Script to trigger docker.yml workflows across all Struxel repositories
# Usage: ./trigger-builds.sh [GITHUB_TOKEN]
# If GITHUB_TOKEN is not provided as argument, it will use the GITHUB_TOKEN environment variable

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get GitHub token from argument or environment variable
GITHUB_TOKEN="${1:-${GITHUB_TOKEN}}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: GitHub token not provided${NC}"
    echo "Usage: $0 [GITHUB_TOKEN]"
    echo "Or set GITHUB_TOKEN environment variable"
    exit 1
fi

# GitHub API base URL
GITHUB_API="https://api.github.com"
OWNER="Struxel-Dynamics"
WORKFLOW_FILE="docker.yml"

# Array of all 44 Struxel repositories
REPOSITORIES=(
    "struxel-devops-tools"
    "struxel-core"
    "struxel-api"
    "struxel-web"
    "struxel-mobile"
    "struxel-analytics"
    "struxel-auth"
    "struxel-billing"
    "struxel-cache"
    "struxel-cdn"
    "struxel-chat"
    "struxel-ci"
    "struxel-cli"
    "struxel-config"
    "struxel-dashboard"
    "struxel-database"
    "struxel-docs"
    "struxel-email"
    "struxel-events"
    "struxel-files"
    "struxel-gateway"
    "struxel-integrations"
    "struxel-logs"
    "struxel-metrics"
    "struxel-migrations"
    "struxel-monitoring"
    "struxel-notifications"
    "struxel-payments"
    "struxel-queue"
    "struxel-reports"
    "struxel-search"
    "struxel-security"
    "struxel-sms"
    "struxel-storage"
    "struxel-streaming"
    "struxel-testing"
    "struxel-terraform"
    "struxel-ui-components"
    "struxel-users"
    "struxel-video"
    "struxel-webhooks"
    "struxel-workers"
    "struxel-infrastructure"
    "struxel-ml-pipeline"
)

# Counters
SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

echo "=================================================="
echo "Struxel Docker Workflow Trigger Script"
echo "=================================================="
echo "Target: $OWNER"
echo "Workflow: $WORKFLOW_FILE"
echo "Total Repositories: ${#REPOSITORIES[@]}"
echo "Started at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=================================================="
echo ""

# Function to trigger workflow
trigger_workflow() {
    local repo=$1
    local url="$GITHUB_API/repos/$OWNER/$repo/actions/workflows/$WORKFLOW_FILE/dispatches"
    
    echo -n "Triggering $repo... "
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$url" \
        -d '{"ref":"main"}' 2>&1)
    
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "204" ]; then
        echo -e "${GREEN}✓ Success${NC}"
        ((SUCCESS_COUNT++))
    elif [ "$http_code" = "404" ]; then
        echo -e "${YELLOW}⚠ Skipped (workflow not found)${NC}"
        ((SKIPPED_COUNT++))
    else
        echo -e "${RED}✗ Failed (HTTP $http_code)${NC}"
        ((FAILED_COUNT++))
    fi
}

# Main loop - trigger workflows for all repositories
for repo in "${REPOSITORIES[@]}"; do
    trigger_workflow "$repo"
    # Small delay to avoid rate limiting
    sleep 0.5
done

echo ""
echo "=================================================="
echo "Summary"
echo "=================================================="
echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
echo -e "${YELLOW}Skipped: $SKIPPED_COUNT${NC}"
echo -e "${RED}Failed: $FAILED_COUNT${NC}"
echo "Total: ${#REPOSITORIES[@]}"
echo "Completed at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=================================================="

# Exit with error if any failures occurred
if [ $FAILED_COUNT -gt 0 ]; then
    exit 1
fi

exit 0
