#!/bin/bash
# Script to migrate all repositories from Bitbucket to GitHub
# Usage: ./migration_script.sh >> log_output.txt
# Prerequisites:
# 1. Install the GitHub CLI: https://cli.github.com/
#    - Authenticate with GitHub: gh auth login
#    - Check for correct Github user and token: gh auth status
# 2. Set the following environment variables:
# - BITBUCKET_USERNAME: Your Bitbucket username
# - BITBUCKET_PASSWORD: Your Bitbucket password
# - GITHUB_USERNAME: Your GitHub username
# - GITHUB_TOKEN: Your GitHub personal access token with the 'createRepository' scope
# 3. Create a file named 'repos' in the same directory as this script, containing the Bitbucket repository URLs
BB_USERNAME=$BITBUCKET_USERNAME
BB_PASSWORD=$BITBUCKET_PASSWORD
GH_TOKEN=$GITHUB_TOKEN
GH_USERNAME=$GITHUB_USERNAME
ORG_NAME=Wonderful-Agency
TEAM_NAME=agency-devs
CREATOR_NAME=Namuuna # CHANGE THIS TO YOUR GITHUB USERNAME

extract_repo_name() {
    echo "$1" | sed -E 's/.*\/([^/]+)(\.git)?$/\1/' | sed 's/\.git$//'
}

# read bitbucket urls from "repos" file"
while IFS= read -r bb_url; do
  repo_name=$(extract_repo_name "$bb_url")
  echo "Processing repository: $bb_url"

    echo "Removing the admin member from collaborators"
    # remove the admin member from collaborators
    gh api \
    --method DELETE \
    --silent \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /repos/${ORG_NAME}/${repo_name}/collaborators/${CREATOR_NAME}
done < repos

echo "All repositories have been migrated"