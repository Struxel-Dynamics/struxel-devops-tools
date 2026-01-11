#!/usr/bin/env python3

"""
Docker Hub Secrets Verification Tool for Struxel-Dynamics
Verifies organization-level secrets and manages repository access via GitHub API
"""

import os
import sys
import requests
from typing import List, Dict, Tuple, Optional

# Configuration
ORG = "Struxel-Dynamics"
REQUIRED_SECRETS = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]

# Repositories that need Docker Hub secrets
REPOS = [
    "struxel-credential-verifier",
    "struxel-audit-simulator",
    "struxel-data-lineage",
    "struxel-bias-engine",
    "struxel-contributor-risk",
    "struxel-identity-manager",
    "struxel-data-validator",
    "struxel-vendor-analyzer",
    "struxel-governance-framework",
    "struxel-predictive-module",
    "struxel-api-gateway",
    "struxel-risk-forecast",
    "struxel-core",
    "struxel-compliance-monitor",
    "struxel-audit-logger",
    "struxel-prompt-risk",
    "struxel-task-runner",
    "struxel-rubric-checker",
    "struxel-audit-artifact-kit",
    "struxel-badge-issuer",
    "struxel-client-intake-helper",
    "struxel-dataset-cataloger",
    "struxel-prompt-sanitizer",
    "struxel-fintech-stack",
    "struxel-hrtech-suite",
    "struxel-retail-analytics-suite",
    "struxel-insurtech-suite",
    "struxel-manufacturtech-suite",
    "struxel-energy-utilities-suite",
]

# ANSI color codes
class Colors:
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    MAGENTA = '\033[0;35m'
    BOLD = '\033[1m'
    NC = '\033[0m'


class GitHubSecretsManager:
    def __init__(self, token: str, org: str):
        self.token = token
        self.org = org
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28"
        }
        self.repo_ids = {}
        self.session = requests.Session()
        self.session.headers.update(self.headers)
    
    def test_authentication(self) -> Tuple[bool, Optional[str]]:
        """Test if the token is valid and has proper permissions"""
        url = f"{self.base_url}/user"
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            user_data = response.json()
            username = user_data.get('login')
            
            org_url = f"{self.base_url}/orgs/{self.org}"
            org_response = self.session.get(org_url)
            
            if org_response.status_code == 404:
                return False, f"Organization '{self.org}' not found or not accessible"
            elif org_response.status_code != 200:
                return False, f"Cannot access organization (Status: {org_response.status_code})"
            
            return True, username
        except requests.exceptions.RequestException as e:
            return False, str(e)
    
    def get_org_secrets(self) -> Tuple[List[Dict], Optional[str]]:
        """Get all organization-level secrets"""
        url = f"{self.base_url}/orgs/{self.org}/actions/secrets"
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            secrets_data = response.json()
            return secrets_data.get('secrets', []), None
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 403:
                return [], "Permission denied. Token needs 'admin:org' scope"
            elif e.response.status_code == 404:
                return [], f"Organization '{self.org}' not found"
            return [], f"HTTP Error {e.response.status_code}"
        except requests.exceptions.RequestException as e:
            return [], str(e)
    
    def get_secret_details(self, secret_name: str) -> Optional[Dict]:
        """Get detailed information about a specific secret"""
        url = f"{self.base_url}/orgs/{self.org}/actions/secrets/{secret_name}"
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException:
            return None
    
    def get_repo_id(self, repo_name: str) -> Optional[int]:
        """Get repository ID"""
        if repo_name in self.repo_ids:
            return self.repo_ids[repo_name]
        
        url = f"{self.base_url}/repos/{self.org}/{repo_name}"
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            repo_id = response.json().get('id')
            self.repo_ids[repo_name] = repo_id
            return repo_id
        except requests.exceptions.RequestException:
            return None
    
    def get_secret_repositories(self, secret_name: str) -> Tuple[List[Dict], Optional[str]]:
        """Get repositories that have access to a secret"""
        url = f"{self.base_url}/orgs/{self.org}/actions/secrets/{secret_name}/repositories"
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            return response.json().get('repositories', []), None
        except requests.exceptions.RequestException as e:
            return [], str(e)
    
    def set_secret_repositories(self, secret_name: str, repo_ids: List[int]) -> Tuple[bool, Optional[str]]:
        """Set the repositories that have access to a secret"""
        url = f"{self.base_url}/orgs/{self.org}/actions/secrets/{secret_name}/repositories"
        data = {"selected_repository_ids": repo_ids}
        
        try:
            response = self.session.put(url, json=data)
            response.raise_for_status()
            return True, None
        except requests.exceptions.RequestException as e:
            return False, str(e)


def print_header(text: str):
    """Print a formatted header"""
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.NC}")
    print(f"{Colors.BOLD}{Colors.CYAN}{text:^60}{Colors.NC}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.NC}\n")


def print_section(text: str):
    """Print a section header"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}▶ {text}{Colors.NC}\n")


def get_github_token() -> str:
    """Get GitHub token from environment or prompt user"""
    token = os.environ.get('GITHUB_TOKEN')
    
    if token:
        print(f"{Colors.GREEN}✓ Found GITHUB_TOKEN in environment{Colors.NC}\n")
        return token
    
    print(f"{Colors.YELLOW}GitHub token not found in environment.{Colors.NC}")
    print(f"{Colors.YELLOW}Please enter your GitHub Personal Access Token:{Colors.NC}")
    print(f"{Colors.CYAN}Create one at: https://github.com/settings/tokens{Colors.NC}")
    print(f"{Colors.CYAN}Required scopes: admin:org, repo{Colors.NC}\n")
    token = input(f"{Colors.BOLD}Token: {Colors.NC}").strip()
    
    if not token:
        print(f"{Colors.RED}Error: GitHub token is required.{Colors.NC}")
        sys.exit(1)
    
    return token


def check_org_secrets(manager: GitHubSecretsManager) -> Tuple[bool, Dict[str, Dict]]:
    """Check if organization has required secrets"""
    print_section("Checking Organization Secrets")
    
    secrets, error = manager.get_org_secrets()
    
    if error:
        print(f"{Colors.RED}✗ Error: {error}{Colors.NC}\n")
        return False, {}
    
    if not secrets:
        print(f"{Colors.YELLOW}⚠ No organization secrets found{Colors.NC}\n")
        return False, {}
    
    print(f"{Colors.CYAN}Found {len(secrets)} organization secret(s){Colors.NC}\n")
    
    secrets_dict = {secret['name']: secret for secret in secrets}
    results = {}
    all_present = True
    
    for secret_name in REQUIRED_SECRETS:
        if secret_name in secrets_dict:
            secret_info = secrets_dict[secret_name]
            details = manager.get_secret_details(secret_name)
            
            visibility = details.get('visibility', 'unknown') if details else 'unknown'
            updated_at = secret_info.get('updated_at', 'unknown')
            
            print(f"{Colors.GREEN}✓ {secret_name}{Colors.NC}")
            print(f"  Visibility: {Colors.CYAN}{visibility}{Colors.NC}")
            print(f"  Updated: {Colors.CYAN}{updated_at}{Colors.NC}")
            
            results[secret_name] = {
                'exists': True,
                'visibility': visibility,
                'updated_at': updated_at,
                'details': details
            }
        else:
            print(f"{Colors.RED}✗ {secret_name} - NOT FOUND{Colors.NC}")
            all_present = False
            results[secret_name] = {'exists': False}
    
    print()
    return all_present, results


def check_repository_access(manager: GitHubSecretsManager, repos: List[str]) -> Dict[str, Dict]:
    """Check which repositories have access to the secrets"""
    print_section("Checking Repository Access")
    
    repo_access = {}
    
    for secret_name in REQUIRED_SECRETS:
        details = manager.get_secret_details(secret_name)
        visibility = details.get('visibility', 'unknown') if details else 'unknown'
        
        repos_with_access, error = manager.get_secret_repositories(secret_name)
        
        if error:
            print(f"{Colors.RED}✗ Error checking {secret_name}: {error}{Colors.NC}\n")
            continue
        
        repo_names_with_access = [repo['name'] for repo in repos_with_access]
        
        print(f"{Colors.CYAN}{secret_name}:{Colors.NC}")
        print(f"  Visibility: {Colors.YELLOW}{visibility}{Colors.NC}")
        
        if visibility == 'all':
            print(f"  {Colors.GREEN}✓ Available to ALL repositories{Colors.NC}")
        elif visibility == 'private':
            print(f"  {Colors.YELLOW}⚠ Available to PRIVATE repositories only{Colors.NC}")
        elif visibility == 'selected':
            print(f"  {Colors.YELLOW}⚠ Available to {len(repo_names_with_access)} selected repositories{Colors.NC}")
        
        for repo in repos:
            if visibility == 'all':
                has_access = True
            else:
                has_access = repo in repo_names_with_access
            
            if repo not in repo_access:
                repo_access[repo] = {}
            repo_access[repo][secret_name] = has_access
        
        print()
    
    return repo_access


def print_detailed_summary(repo_access: Dict[str, Dict]):
    """Print detailed summary of repository access"""
    print_section("Detailed Summary")
    
    repos_with_full_access = []
    repos_with_partial_access = []
    repos_without_access = []
    repos_not_found = []
    
    for repo, secrets in repo_access.items():
        if not secrets:
            repos_not_found.append(repo)
            continue
        
        access_count = sum(secrets.values())
        
        if access_count == len(REQUIRED_SECRETS):
            repos_with_full_access.append(repo)
        elif access_count > 0:
            repos_with_partial_access.append(repo)
        else:
            repos_without_access.append(repo)
    
    print(f"{Colors.GREEN}✓ Full Access: {len(repos_with_full_access)}/{len(REPOS)}{Colors.NC}")
    print(f"{Colors.YELLOW}⚠ Partial Access: {len(repos_with_partial_access)}/{len(REPOS)}{Colors.NC}")
    print(f"{Colors.RED}✗ No Access: {len(repos_without_access)}/{len(REPOS)}{Colors.NC}")
    
    if repos_not_found:
        print(f"{Colors.MAGENTA}? Not Found: {len(repos_not_found)}/{len(REPOS)}{Colors.NC}")
    
    if repos_with_partial_access:
        print(f"\n{Colors.YELLOW}Repositories with PARTIAL access:{Colors.NC}")
        for repo in repos_with_partial_access[:10]:
            missing = [s for s in REQUIRED_SECRETS if not repo_access[repo].get(s, False)]
            print(f"  • {repo}")
            print(f"    Missing: {Colors.RED}{', '.join(missing)}{Colors.NC}")
        
        if len(repos_with_partial_access) > 10:
            print(f"  ... and {len(repos_with_partial_access) - 10} more")
    
    if repos_without_access:
        print(f"\n{Colors.RED}Repositories without access:{Colors.NC}")
        for repo in repos_without_access[:10]:
            print(f"  • {repo}")
        
        if len(repos_without_access) > 10:
            print(f"  ... and {len(repos_without_access) - 10} more")
    
    if repos_not_found:
        print(f"\n{Colors.MAGENTA}Repositories not found (may not exist yet):{Colors.NC}")
        for repo in repos_not_found[:10]:
            print(f"  • {repo}")
        
        if len(repos_not_found) > 10:
            print(f"  ... and {len(repos_not_found) - 10} more")
    
    print()
    
    return len(repos_without_access) == 0 and len(repos_with_partial_access) == 0


def grant_access_to_repos(manager: GitHubSecretsManager, repos: List[str]) -> Dict[str, bool]:
    """Grant all specified repositories access to Docker Hub secrets"""
    print_section("Granting Repository Access")
    
    print(f"{Colors.YELLOW}Fetching repository IDs...{Colors.NC}")
    
    repo_ids = []
    failed_repos = []
    
    for i, repo in enumerate(repos, 1):
        repo_id = manager.get_repo_id(repo)
        if repo_id:
            repo_ids.append(repo_id)
            print(f"  {i}/{len(repos)} {Colors.GREEN}✓{Colors.NC} {repo}", end='\r')
        else:
            failed_repos.append(repo)
            print(f"  {i}/{len(repos)} {Colors.RED}✗{Colors.NC} {repo} (not found)")
    
    print(f"\n\n{Colors.GREEN}Found {len(repo_ids)} repositories{Colors.NC}")
    
    if failed_repos:
        print(f"{Colors.YELLOW}⚠ Could not find {len(failed_repos)} repositories:{Colors.NC}")
        for repo in failed_repos[:5]:
            print(f"  • {repo}")
        if len(failed_repos) > 5:
            print(f"  ... and {len(failed_repos) - 5} more")
        print()
    
    results = {}
    for secret_name in REQUIRED_SECRETS:
        print(f"\n{Colors.CYAN}Setting access for {secret_name}...{Colors.NC}")
        success, error = manager.set_secret_repositories(secret_name, repo_ids)
        results[secret_name] = success
        
        if success:
            print(f"{Colors.GREEN}✓ Successfully granted access to {len(repo_ids)} repositories{Colors.NC}")
        else:
            print(f"{Colors.RED}✗ Failed: {error}{Colors.NC}")
    
    print()
    return results


def main():
    print_header("Docker Hub Secrets Verification Tool")
    print(f"{Colors.CYAN}Organization: {Colors.BOLD}{ORG}{Colors.NC}")
    print(f"{Colors.CYAN}Repositories to check: {Colors.BOLD}{len(REPOS)}{Colors.NC}")
    print(f"{Colors.CYAN}Required secrets: {Colors.BOLD}{', '.join(REQUIRED_SECRETS)}{Colors.NC}\n")
    
    token = get_github_token()
    manager = GitHubSecretsManager(token, ORG)
    
    print_section("Testing Authentication")
    auth_ok, result = manager.test_authentication()
    
    if not auth_ok:
        print(f"{Colors.RED}✗ Authentication failed: {result}{Colors.NC}\n")
        print(f"{Colors.YELLOW}Please check:{Colors.NC}")
        print(f"  1. Token is valid")
        print(f"  2. Token has 'admin:org' and 'repo' scopes")
        print(f"  3. You have access to the organization\n")
        sys.exit(1)
    
    print(f"{Colors.GREEN}✓ Authenticated as: {Colors.BOLD}{result}{Colors.NC}")
    print(f"{Colors.GREEN}✓ Organization access: {Colors.BOLD}{ORG}{Colors.NC}\n")
    
    secrets_ok, secrets_info = check_org_secrets(manager)
    
    if not secrets_ok:
        print(f"{Colors.RED}✗ Organization secrets not properly configured.{Colors.NC}")
        print(f"\n{Colors.YELLOW}Action required:{Colors.NC}")
        print(f"Set up organization-level secrets at:")
        print(f"{Colors.CYAN}https://github.com/organizations/{ORG}/settings/secrets/actions{Colors.NC}\n")
        sys.exit(1)
    
    repo_access = check_repository_access(manager, REPOS)
    all_good = print_detailed_summary(repo_access)
    
    if not all_good:
        print(f"{Colors.YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
        print(f"\n{Colors.BOLD}Would you like to grant access to all {len(REPOS)} repositories?{Colors.NC}")
        print(f"{Colors.YELLOW}This will update both secrets to be accessible by all listed repos.{Colors.NC}")
        response = input(f"\n{Colors.BOLD}Proceed? (y/n): {Colors.NC}").strip().lower()
        
        if response == 'y':
            results = grant_access_to_repos(manager, REPOS)
            
            if all(results.values()):
                print(f"\n{Colors.GREEN}{Colors.BOLD}✓ SUCCESS!{Colors.NC}")
                print(f"{Colors.GREEN}All repositories now have access to Docker Hub secrets!{Colors.NC}\n")
            else:
                print(f"\n{Colors.YELLOW}⚠ PARTIAL SUCCESS{Colors.NC}")
                print(f"{Colors.YELLOW}Some secrets could not be updated. Check errors above.{Colors.NC}\n")
        else:
            print(f"\n{Colors.YELLOW}Skipped automatic grant.{Colors.NC}")
            print(f"You can update manually at:")
            print(f"{Colors.CYAN}https://github.com/organizations/{ORG}/settings/secrets/actions{Colors.NC}\n")
    else:
        print(f"{Colors.GREEN}{Colors.BOLD}✓ ALL REPOSITORIES HAVE PROPER ACCESS!{Colors.NC}\n")
        print(f"{Colors.GREEN}Next steps:{Colors.NC}")
        print(f"  1. ✓ Secrets configured (DONE!)")
        print(f"  2. ⏳ Wait for Docker Hub workflow PRs to be created")
        print(f"  3. 📝 Review and merge the PRs")
        print(f"  4. 🚀 Workflows will automatically run")
        print(f"  5. 🎉 Check Docker Hub: {Colors.CYAN}https://hub.docker.com/u/cyncarter11{Colors.NC}\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Interrupted by user. Exiting...{Colors.NC}\n")
        sys.exit(0)
    except Exception as e:
        print(f"\n{Colors.RED}Unexpected error: {e}{Colors.NC}\n")
        import traceback
        traceback.print_exc()
        sys.exit(1)
