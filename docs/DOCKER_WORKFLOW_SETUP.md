# Docker Workflow Setup Guide

Complete documentation for the Struxel-Dynamics Docker automation system.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Steps](#setup-steps)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Organization Secrets

Configure these secrets at the organization level:
https://github.com/organizations/Struxel-Dynamics/settings/secrets/actions

1. **DOCKER_USERNAME**: cyncarter11
2. **DOCKER_PASSWORD**: Your Docker Hub access token (recommended) or password

### Docker Hub Access Token

1. Log in to Docker Hub: https://hub.docker.com
2. Go to Account Settings → Security
3. Click "New Access Token"
4. Name: "Struxel-GitHub-Actions"
5. Copy and save as DOCKER_PASSWORD secret

## Setup Steps

### 1. Initial Setup

The reusable workflow is already configured in this repository at:
`.github/workflows/docker-build-push.yml`

### 2. Deploy to Repositories

#### Option A: Automated Deployment (All 47 Repos)

```bash
# Set your GitHub token
export GH_TOKEN="your_github_personal_access_token"

# Run deployment script
cd struxel-devops-tools
./scripts/deploy-workflow.sh
```

#### Option B: Manual Deployment (Single Repo)

Create `.github/workflows/docker.yml` in any repository:

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]
    tags: ["v*"]
  workflow_dispatch:

jobs:
  build:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## Configuration

### Basic Configuration

Uses repository name as image name:

```yaml
jobs:
  build:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

### Advanced Configuration

```yaml
jobs:
  build:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    with:
      dockerfile_path: 'docker/Dockerfile'      # Custom Dockerfile location
      docker_context: './src'                   # Custom build context
      image_name: 'custom-image-name'           # Override image name
      docker_platforms: 'linux/amd64,linux/arm64'  # Multi-platform
      push_latest: true                         # Push latest tag
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## Deployment

### Workflow Triggers

The workflow runs automatically on:
- Push to main branch
- Push tags matching v* (e.g., v1.0.0)
- Manual trigger via GitHub Actions UI

### Image Tags

Generated tags:
- `cyncarter11/<repo>:main` - Main branch builds
- `cyncarter11/<repo>:latest` - Latest from main
- `cyncarter11/<repo>:v1.2.3` - Version tags
- `cyncarter11/<repo>:main-abc123` - Branch + commit SHA
- `cyncarter11/<repo>:pr-42` - Pull request builds

## Troubleshooting

### Authentication Failed

**Problem**: Docker login fails

**Solution**:
1. Verify DOCKER_USERNAME is set to: cyncarter11
2. Verify DOCKER_PASSWORD is a valid Docker Hub token
3. Check organization secrets are accessible to repositories

### Dockerfile Not Found

**Problem**: Build fails with "Dockerfile not found"

**Solution**:
1. Add Dockerfile to repository root
2. Or specify custom path:
   ```yaml
   with:
     dockerfile_path: 'path/to/Dockerfile'
   ```

### Build Fails

**Problem**: Docker build errors

**Solution**:
1. Check Dockerfile syntax
2. Review build logs in GitHub Actions
3. Test build locally: `docker build -t test .`

### Push Failed

**Problem**: Image push fails

**Solution**:
1. Verify Docker Hub credentials
2. Check Docker Hub repository exists
3. Ensure sufficient Docker Hub storage

### Deployment Script Fails

**Problem**: deploy-workflow.sh fails

**Solution**:
1. Ensure GH_TOKEN is set and valid
2. Verify token has repo and workflow scopes
3. Check repository access permissions

## Best Practices

1. **Use Docker Hub Access Tokens** instead of passwords
2. **Test locally first** before pushing
3. **Use .dockerignore** to exclude unnecessary files
4. **Implement health checks** in Dockerfiles
5. **Use multi-stage builds** to reduce image size
6. **Pin base image versions** for reproducibility

## Monitoring

### GitHub Actions

Monitor workflow runs:
- Organization: https://github.com/Struxel-Dynamics/actions
- Repository: https://github.com/Struxel-Dynamics/<repo>/actions

### Docker Hub

View images:
- Profile: https://hub.docker.com/u/cyncarter11
- Repository: https://hub.docker.com/r/cyncarter11/<repo-name>

## Support

For issues or questions:
1. Check this documentation
2. Review workflow logs
3. Create an issue in struxel-devops-tools
4. Contact DevOps team

---

**Last Updated**: 2026-01-02  
**Maintained by**: Struxel-Dynamics DevOps Team
