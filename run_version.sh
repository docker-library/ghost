#!/usr/bin/env bash
# based on https://github.com/mmornati/docker-ghostblog/blob/master/update_push_version.sh

# A better class of script
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

VERSION=$1 && \
sed -i '' "s/^ARG GHOST_VERSION=.*$/ARG GHOST_VERSION=\"$VERSION\"/" Dockerfile && \
git add . && \
git commit -m "Ghost updated to $VERSION version" && \
git tag -a $VERSION -m "Ghost updated to $VERSION version"


##################################################
# PUSH RELEASE


# This is specific to my local set up
source .env .

# Set env_var before running this script:
# GITHUB_TOKEN="3122133122133211233211233211233211322313123"

# vars
my_repo="ghostfire"
GIT_REPO="https://github.com/firepress-org/${my_repo}.git"
GOPATH=${HOME}/go

# The tag must be ready to push on git remote
cd ${HOME}/Documents/Github/firepress-org/${my_repo} && \
git push --tags && \

# Find the latest tag
tag_version="$(
	git ls-remote --tags ${GIT_REPO} \
		| cut -d$'\t' -f2 \
		| grep -E '^refs/tags/[0-9]+\.[0-9]+' \
		| cut -d/ -f3 \
		| sort -rV \
		| head -n1)" && \
echo ${tag_version} && \

# Push release on GitHub like a boss
# Requires: https://github.com/aktau/github-release
$GOPATH/bin/github-release release \
  --user firepress-org \
  --repo ${my_repo} \
  --tag ${tag_version} \
  --name ${tag_version} \
  --description "Refer to [CHANGELOG.md](https://github.com/firepress-org/${my_repo}/blob/master/CHANGELOG.md) for all details about this release."
