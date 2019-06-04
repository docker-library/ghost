#!/usr/bin/env bash
# based on https://github.com/mmornati/docker-ghostblog/blob/master/update_push_version.sh

# A better class of script
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

# Capture tag number / i.e. ./run_tag.sh 2.12.3
version=$1;


##################################################
# create and push tag

git tag ${version} && \
git push --tags;


##################################################
# PUSH RELEASE
my_repo="ghostfire"
localpath="${HOME}/Documents/Github/firepress-org/${my_repo}"
gopath="${HOME}/go"

cd ${localpath} && \

# Push release on GitHub like a boss
# Requires: https://github.com/aktau/github-release
#
$gopath/bin/github-release release \
  --user firepress-org \
  --repo ${my_repo} \
  --tag ${version} \
  --name ${version} \
  --description "Refer to [CHANGELOG.md](https://github.com/firepress-org/${my_repo}/blob/master/CHANGELOG.md) for all details about this release."
