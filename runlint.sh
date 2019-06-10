#!/usr/bin/env bash
# based on https://github.com/mmornati/docker-ghostblog/blob/master/update_push_version.sh

# A better class of script
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

docker run --rm hadolint/hadolint:v1.16.3-4-gc7f877d hadolint --version && echo;

docker run --rm -i hadolint/hadolint:v1.16.3-4-gc7f877d hadolint \
  --ignore DL3000 \
  - < Dockerfile

