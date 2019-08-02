#!/usr/bin/env bash
# based on https://github.com/mmornati/docker-ghostblog/blob/master/update_push_version.sh

# A better class of script
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)


##################################################
# Update the Dockerfile
tag_version=$1 && \
sed -i '' "s/^ARG GHOST_VERSION=.*$/ARG GHOST_VERSION=\"$tag_version\"/" Dockerfile && \
git add . && \
git commit -m "Ghost updated to $tag_version version" && \
git push && \
sleep 1 && \
# push tag
git tag ${tag_version} && \
git push --tags && \

echo "Update CHANGELOG.md / ./runrelease.sh";
