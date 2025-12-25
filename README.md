# Struxel DevOps Tools

A collection of DevOps automation tools and scripts for managing the Struxel-Dynamics organization infrastructure.

## 🛠️ Tools Available

### Docker Hub Secrets Manager
**File:** `verify-dockerhub-secrets.py`

Comprehensive tool for verifying and managing Docker Hub secrets across all Struxel-Dynamics repositories.

**Features:**
- ✅ Verifies organization-level GitHub secrets
- 🔍 Checks repository access to secrets
- 🔧 Automatically grants access to all required repositories
- 📊 Provides detailed summary and status reports
- 🎨 Color-coded terminal output for easy reading

## 🚀 Quick Start

### Docker Hub Secrets Verification

```bash
# Clone the repository
git clone https://github.com/Struxel-Dynamics/struxel-devops-tools.git
cd struxel-devops-tools

# Install requirements
pip3 install -r requirements.txt

# Set your GitHub token
export GITHUB_TOKEN="your_github_personal_access_token"

# Run the verification tool
python3 verify-dockerhub-secrets.py
```

### One-Liner (Direct Download)

```bash
curl -sSL https://raw.githubusercontent.com/Struxel-Dynamics/struxel-devops-tools/main/verify-dockerhub-secrets.py | python3 -
```

## 📋 Prerequisites

- **Python 3.6+**
- **requests library:** `pip3 install requests`
- **GitHub Personal Access Token** with `admin:org` and `repo` scopes

### Creating a GitHub Token

1. Go to https://github.com/settings/tokens/new
2. Name: `DevOps Tools`
3. Expiration: `90 days` (or as needed)
4. Select scopes:
   - ✅ `admin:org` - Full control of orgs and teams
   - ✅ `repo` - Full control of private repositories
5. Click **Generate token**
6. Copy the token immediately

## 🎯 What Gets Managed

### Repositories (29 total)

**Core Platform:**
- struxel-core
- struxel-bias-engine
- struxel-governance-framework
- struxel-predictive-module

**Infrastructure & Monitoring:**
- struxel-vendor-analyzer
- struxel-compliance-monitor
- struxel-data-validator

**AI Products:**
- struxel-api-gateway
- struxel-audit-logger
- struxel-identity-manager
- struxel-risk-forecast
- struxel-contributor-risk
- struxel-audit-simulator
- struxel-credential-verifier
- struxel-data-lineage
- struxel-prompt-risk

**Contributor Modules:**
- struxel-task-runner
- struxel-rubric-checker
- struxel-audit-artifact-kit
- struxel-badge-issuer
- struxel-client-intake-helper
- struxel-dataset-cataloger
- struxel-prompt-sanitizer

**Industry Bundles:**
- struxel-fintech-stack
- struxel-hrtech-suite
- struxel-retail-analytics-suite
- struxel-insurtech-suite
- struxel-manufacturtech-suite
- struxel-energy-utilities-suite

### Organization Secrets

- `DOCKERHUB_USERNAME` - Docker Hub account username
- `DOCKERHUB_TOKEN` - Docker Hub access token

## 🔒 Security Notes

- ⚠️ **Never commit GitHub tokens to version control**
- ⚠️ **Keep access tokens secure**
- ⚠️ **Rotate tokens periodically**
- ⚠️ **Limit token scopes to minimum required**
- ⚠️ **Use environment variables for sensitive data**

## 📊 Example Output

```
============================================================
      Docker Hub Secrets Verification Tool
============================================================

Organization: Struxel-Dynamics
Repositories to check: 29
Required secrets: DOCKERHUB_USERNAME, DOCKERHUB_TOKEN

✓ Found GITHUB_TOKEN in environment

▶ Testing Authentication

✓ Authenticated as: cynitressecarter-creator
✓ Organization access: Struxel-Dynamics

▶ Checking Organization Secrets

Found 2 organization secret(s)

✓ DOCKERHUB_USERNAME
  Visibility: all
  Updated: 2025-12-25T10:30:00Z

✓ DOCKERHUB_TOKEN
  Visibility: all
  Updated: 2025-12-25T10:30:00Z

▶ Checking Repository Access

DOCKERHUB_USERNAME:
  Visibility: all
  ✓ Available to ALL repositories

DOCKERHUB_TOKEN:
  Visibility: all
  ✓ Available to ALL repositories

▶ Detailed Summary

✓ Full Access: 29/29
⚠ Partial Access: 0/29
✗ No Access: 0/29

✓ ALL REPOSITORIES HAVE PROPER ACCESS!

Next steps:
  1. ✓ Secrets configured (DONE!)
  2. ⏳ Wait for Docker Hub workflow PRs to be created
  3. 📝 Review and merge the PRs
  4. 🚀 Workflows will automatically run
  5. 🎉 Check Docker Hub: https://hub.docker.com/u/cyncarter11
```

## 🤝 Contributing

This repository is maintained by the Struxel-Dynamics DevOps team.

## 📄 License

MIT License - See LICENSE file for details.

## 🔗 Related Links

- [Struxel-Dynamics Organization](https://github.com/Struxel-Dynamics)
- [Docker Hub](https://hub.docker.com/u/cyncarter11)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**Made with ❤️ for Struxel-Dynamics**
