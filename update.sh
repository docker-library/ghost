#!/bin/bash
set -e

current="$(
	git ls-remote --tags https://github.com/TryGhost/Ghost.git \
		| cut -d$'\t' -f2 \
		| grep -E '^refs/tags/[0-9]+\.[0-9]+' \
		| cut -d/ -f3 \
		| grep -vE 'beta' \
		| sort -rV \
		| head -1
)"

set -x
sed -ri 's/^(ENV GHOST_VERSION) .*/\1 '"$current"'/' Dockerfile
