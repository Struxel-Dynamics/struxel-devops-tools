#!/bin/bash

# Script to trigger Docker workflow builds for all Struxel-Dynamics repositories
# Usage: ./trigger-builds.sh [GITHUB_TOKEN]
# 
# Requirements:
# - GitHub Personal Access Token with 'workflow' scope
# - curl installed
# - jq installed (optional, for pretty output)

set -e

# Configuration
ORG="Struxel-Dynamics"
WORKFLOW_FILE="docker-build.yml"  # Adjust if your workflow file has a different name
REF="main"  # Branch to trigger the workflow on

# GitHub token (can be passed as argument or environment variable)
GITHUB_TOKEN="${1:-${GITHUB_TOKEN}}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GitHub token is required"
    echo "Usage: $0 [GITHUB_TOKEN]"
    echo "Or set GITHUB_TOKEN environment variable"
    exit 1
fi

# List of all 44 repositories
REPOSITORIES=(
    "struxel-ai-platform"
    "struxel-api-gateway"
    "struxel-auth-service"
    "struxel-analytics-engine"
    "struxel-blockchain-integration"
    "struxel-cache-service"
    "struxel-cdn-manager"
    "struxel-chat-service"
    "struxel-ci-cd-pipeline"
    "struxel-cloud-connector"
    "struxel-config-service"
    "struxel-content-delivery"
    "struxel-data-lake"
    "struxel-database-manager"
    "struxel-devops-tools"
    "struxel-edge-computing"
    "struxel-email-service"
    "struxel-event-bus"
    "struxel-file-storage"
    "struxel-iot-platform"
    "struxel-load-balancer"
    "struxel-logging-service"
    "struxel-machine-learning"
    "struxel-message-queue"
    "struxel-microservices-core"
    "struxel-monitoring-dashboard"
    "struxel-notification-service"
    "struxel-payment-gateway"
    "struxel-performance-optimizer"
    "struxel-queue-manager"
    "struxel-realtime-sync"
    "struxel-recommendation-engine"
    "struxel-reporting-service"
    "struxel-search-service"
    "struxel-security-scanner"
    "struxel-serverless-functions"
    "struxel-session-manager"
    "struxel-stream-processor"
    "struxel-task-scheduler"
    "struxel-testing-framework"
    "struxel-user-management"
    "struxel-video-processing"
    "struxel-webhook-service"
    "struxel-workflow-engine"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Struxel-Dynamics Docker Build Trigger"
echo "=========================================="
echo "Organization: $ORG"
echo "Workflow: $WORKFLOW_FILE"
echo "Branch: $REF"
echo "Total Repositories: ${#REPOSITORIES[@]}"
echo "=========================================="
echo ""

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_REPOS=()

# Function to trigger workflow
trigger_workflow() {
    local repo=$1
    local api_url="https://api.github.com/repos/${ORG}/${repo}/actions/workflows/${WORKFLOW_FILE}/dispatches"
    
    echo -n "Triggering build for ${repo}... "
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$api_url" \
        -d "{\"ref\":\"${REF}\"}")
    
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "204" ]; then
        echo -e "${GREEN}✓ Success${NC}"
        ((SUCCESS_COUNT++))
        return 0
    else
        echo -e "${RED}✗ Failed (HTTP $http_code)${NC}"
        ((FAILED_COUNT++))
        FAILED_REPOS+=("$repo")
        return 1
    fi
}

# Trigger workflows for all repositories
for repo in "${REPOSITORIES[@]}"; do
    trigger_workflow "$repo"
    # Add a small delay to avoid rate limiting
    sleep 0.5
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
echo -e "${RED}Failed: $FAILED_COUNT${NC}"

if [ $FAILED_COUNT -gt 0 ]; then
    echo ""
    echo "Failed repositories:"
    for repo in "${FAILED_REPOS[@]}"; do
        echo -e "  ${RED}- $repo${NC}"
    done
    exit 1
fi

echo ""
echo -e "${GREEN}All workflows triggered successfully!${NC}"
exit 0
