# Struxel DevOps Tools

Automated Docker build and push workflows for all 47 Struxel-Dynamics repositories.

## 🚀 Features

- **Reusable Docker Workflow**: Centralized workflow for building and pushing Docker images to Docker Hub
- **Automated Deployment**: Script to deploy workflows across all repositories
- **Smart Tagging**: Automatic tags based on branches, versions, and commits
- **Multi-platform Support**: Build for multiple architectures
- **Docker Layer Caching**: Faster builds with GitHub Actions cache

## 📋 Quick Start

### 1. Set Organization Secrets

Add these secrets at: https://github.com/organizations/Struxel-Dynamics/settings/secrets/actions

- **DOCKER_USERNAME**: cyncarter11
- **DOCKER_PASSWORD**: Your Docker Hub access token

### 2. Deploy to All Repositories

```bash
export GH_TOKEN="your_github_token"
cd struxel-devops-tools
chmod +x scripts/deploy-workflow.sh
./scripts/deploy-workflow.sh
```

## 📦 Usage

### Basic Usage in Any Repository

Create `.github/workflows/docker.yml`:

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

### Advanced Configuration

```yaml
jobs:
  build:
    uses: Struxel-Dynamics/struxel-devops-tools/.github/workflows/docker-build-push.yml@main
    with:
      dockerfile_path: 'docker/Dockerfile'
      docker_context: '.'
      image_name: 'custom-name'
      docker_platforms: 'linux/amd64,linux/arm64'
      push_latest: true
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## 🏷️ Image Tags

Images are automatically tagged as:
- `cyncarter11/<repo>:main` - Main branch builds
- `cyncarter11/<repo>:latest` - Latest stable version
- `cyncarter11/<repo>:v1.2.3` - Version tags
- `cyncarter11/<repo>:pr-42` - Pull request builds
- `cyncarter11/<repo>:main-abc123` - Branch + commit SHA

## 📊 Supported Repositories (47)

### Core Services (13)
struxel-platform-api, struxel-export-worker, struxel-infra, struxel-admin-ui, struxel-core, struxel-bias-engine, struxel-governance-framework, struxel-predictive-module, struxel-vendor-analyzer, struxel-compliance-monitor, struxel-data-validator, curriculum-training, struxel-devops-tools

### AI Products (14)
struxel-api-gateway, struxel-audit-logger, struxel-identity-manager, struxel-predictive-compliance, struxel-risk-forecast, struxel-policy-drift, struxel-contributor-risk, struxel-audit-simulator, struxel-credential-verifier, struxel-consent-tracker, struxel-data-lineage, struxel-prompt-risk, struxel-model-registry, struxel-sla-monitor

### Contributor Modules (10)
struxel-task-runner, struxel-rubric-checker, struxel-audit-artifact-kit, struxel-badge-issuer, struxel-sla-notifier, struxel-client-intake-helper, struxel-dataset-cataloger, struxel-prompt-sanitizer

### Industry Bundles (10)
struxel-fintech-stack, struxel-healthtech-suite, struxel-hrtech-suite, struxel-govtech-suite, struxel-edtech-suite, struxel-retail-analytics-suite, struxel-insurtech-suite, struxel-manufacturtech-suite, struxel-legaltech-suite, struxel-energy-utilities-suite

## 🔧 Configuration Options

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `dockerfile_path` | string | `Dockerfile` | Path to Dockerfile |
| `docker_context` | string | `.` | Build context directory |
| `image_name` | string | repo name | Docker image name |
| `docker_platforms` | string | `linux/amd64` | Target platforms |
| `push_latest` | boolean | `true` | Push latest tag |

## 🎯 View Your Images

After successful builds, view images at:
- Docker Hub: https://hub.docker.com/u/cyncarter11
- Specific repo: https://hub.docker.com/r/cyncarter11/<repo-name>

## 📖 Documentation

See [docs/DOCKER_WORKFLOW_SETUP.md](docs/DOCKER_WORKFLOW_SETUP.md) for complete documentation.

## 🤝 Contributing

To add new tools or improve workflows:
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

**Maintained by**: Struxel-Dynamics DevOps Team  
**Last Updated**: 2026-01-02
