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
ADMIN_TEAM_NAME=admins
CREATOR_NAME=Namuuna # CHANGE THIS TO YOUR GITHUB USERNAME

extract_repo_name() {
    echo "$1" | sed -E 's/.*\/([^/]+)(\.git)?$/\1/' | sed 's/\.git$//'
}

# read bitbucket urls from "repos" file"
while IFS= read -r bb_url; do
  repo_name=$(extract_repo_name "$bb_url")
  echo "Processing repository: $bb_url"

  # if the repository already exists on GitHub, skip it
  if gh repo list $ORG_NAME | cut -f1 | sed 's|.*/||' | grep -qFx $repo_name; then
    echo "Repository '$repo_name' does exists. Skipping ..."
  else
    echo "Creating repository '$repo_name' on GitHub"
    gh repo create Wonderful-Agency/$repo_name --internal

    # Add the repository to the GitHub admin team (push=write access)
    gh api \
    --method PUT \
	  --silent \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /orgs/${ORG_NAME}/teams/${ADMIN_TEAM_NAME}/repos/${ORG_NAME}/${repo_name} \
    -f "permission=admin"

    # Add the repository to the GitHub team (push=write access)
    gh api \
    --method PUT \
	  --silent \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /orgs/${ORG_NAME}/teams/${TEAM_NAME}/repos/${ORG_NAME}/${repo_name} \
    -f "permission=push"

    # the person who runs the script will be removed from the collaborators
    # gh api \
    # --method DELETE \
	  # --silent \
    # -H "Accept: application/vnd.github+json" \
    # -H "X-GitHub-Api-Version: 2022-11-28" \
    # /repos/${ORG_NAME}/${repo_name}/collaborators/${CREATOR_NAME}

    # create a temporary directory
    # temp_dir=$(mktemp -d)
    temp_dir=/var/folders/k3/j4_1p3kn0p52rwym5wqpk0cc8f4j86/T/tmp.t4wGNnbDgS
    echo "Cloning repository to $temp_dir"
    cd "$temp_dir"

    # Clone the Bitbucket repository
    # git clone --bare "$bb_url"
    cd "${repo_name}.git"

    for branch in master develop
    do
        if git show-ref --verify "refs/heads/$branch"; then
          echo "Pushing branch $branch"
          if ! git push "https://github.com/${ORG_NAME}/${repo_name}.git" "$branch"; then
              echo "Error pushing branch $branch. Exiting."
              exit 1
          fi
            sleep 3 # wait for 3 seconds before pushing the next branch
        fi
    done

    git push -q --tags "https://github.com/${ORG_NAME}/${repo_name}.git"

    # Clean up
    cd ../..
    echo "Cleaning up $temp_dir"
    rm -rf "$temp_dir"

    echo "Migration completed for $repo_name"
  fi
done < repos

echo "All repositories have been migrated"