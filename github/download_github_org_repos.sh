#!/bin/bash
# Usage: ./download_github_org_repos.sh <org_name> [github_token]
# Downloads (clones) all repositories in a GitHub organization

ORG="Wonderful-Agency"
TOKEN="$1"

API_URL="https://api.github.com/orgs/$ORG/repos?per_page=100&type=all"
HEADER="Accept: application/vnd.github+json"

PAGE=1
REPOS=()

while :; do
  RESP=$(curl -sSL -H "$HEADER" -H "Authorization: token $TOKEN" "$API_URL&page=$PAGE")
  NAMES=$(echo "$RESP" | grep -o '"clone_url": *"[^"]*"' | cut -d '"' -f4)
  if [ -z "$NAMES" ]; then
    break
  fi
  REPOS+=( $NAMES )
  ((PAGE++))
done

if [ ${#REPOS[@]} -eq 0 ]; then
  echo "No repositories found for organization: $ORG"
  exit 0
fi


echo "Found ${#REPOS[@]} repositories. Cloning..."
for REPO in "${REPOS[@]}"; do
  repo_name=$(basename "$REPO" .git)
  CLONE_DIR=~/Documents/github_org_repos/$repo_name/
  echo "Cloning $REPO ..."
  git clone "$REPO" "$CLONE_DIR"
done

echo "All repositories cloned."
