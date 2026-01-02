#!/bin/bash

# Deploy Workflow Script
# This script manages the deployment workflow for Struxel applications

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Configuration
ENVIRONMENT="${ENVIRONMENT:-production}"
DEPLOYMENT_TYPE="${DEPLOYMENT_TYPE:-standard}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-ghcr.io}"
NAMESPACE="${NAMESPACE:-struxel-apps}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."
    
    local required_tools=("docker" "kubectl" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed or not in PATH"
            exit 1
        fi
    done
    
    log_info "All prerequisites validated successfully"
}

# Check environment configuration
check_environment() {
    log_info "Checking environment configuration for: $ENVIRONMENT"
    
    case "$ENVIRONMENT" in
        development|staging|production)
            log_info "Valid environment: $ENVIRONMENT"
            ;;
        *)
            log_error "Invalid environment: $ENVIRONMENT"
            log_error "Must be one of: development, staging, production"
            exit 1
            ;;
    esac
}

# Build Docker images
build_images() {
    log_info "Building Docker images..."
    
    if [ -f "${PROJECT_ROOT}/docker-compose.yml" ]; then
        docker-compose -f "${PROJECT_ROOT}/docker-compose.yml" build
    else
        log_warn "No docker-compose.yml found, skipping image build"
    fi
}

# Push Docker images to registry
push_images() {
    log_info "Pushing Docker images to registry: $DOCKER_REGISTRY"
    
    # Get image tags
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^${DOCKER_REGISTRY}")
    
    if [ -z "$images" ]; then
        log_warn "No images found to push"
        return
    fi
    
    echo "$images" | while read -r image; do
        log_info "Pushing $image"
        docker push "$image"
    done
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    log_info "Deploying to Kubernetes namespace: $NAMESPACE"
    
    if [ -d "${PROJECT_ROOT}/k8s/${ENVIRONMENT}" ]; then
        kubectl apply -f "${PROJECT_ROOT}/k8s/${ENVIRONMENT}" -n "$NAMESPACE"
    else
        log_warn "No Kubernetes manifests found for environment: $ENVIRONMENT"
    fi
}

# Workflow integration
# This section references reusable workflows from the repository
workflow_reference() {
    cat << EOF
name: Deploy Application

on:
  push:
    branches:
      - main
      - staging
      - develop

jobs:
  build-and-push:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    with:
      environment: \${{ github.ref_name }}
      registry: ghcr.io
    secrets: inherit

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to environment
        run: |
          ./scripts/deploy-workflow.sh
        env:
          ENVIRONMENT: \${{ github.ref_name }}
EOF
}

# Main execution
main() {
    log_info "Starting deployment workflow..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Deployment Type: $DEPLOYMENT_TYPE"
    
    validate_prerequisites
    check_environment
    
    case "$DEPLOYMENT_TYPE" in
        full)
            build_images
            push_images
            deploy_to_kubernetes
            ;;
        build-only)
            build_images
            ;;
        deploy-only)
            deploy_to_kubernetes
            ;;
        *)
            build_images
            push_images
            deploy_to_kubernetes
            ;;
    esac
    
    log_info "Deployment workflow completed successfully!"
}

# Run main function
main "$@"
