#!/usr/bin/env bash
# based on https://github.com/mmornati/docker-ghostblog/blob/master/update_push_version.sh

# A better class of script
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

VERSION="2.23.4-0254867"
docker run --rm -v $HOME/Library/Caches:/root/.cache/ knqyf263/trivy devmtl/ghostfire:${VERSION}