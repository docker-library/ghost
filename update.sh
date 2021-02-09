#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

allVersions="$(
	git ls-remote --tags https://github.com/TryGhost/Ghost.git \
		| cut -d$'\t' -f2 \
		| grep -E '^refs/tags/[0-9]+\.[0-9]+' \
		| cut -d/ -f3 \
		| cut -d^ -f1 \
		| sort -ruV
)"

cliVersion="$(
	git ls-remote --tags https://github.com/TryGhost/Ghost-CLI.git \
		| cut -d$'\t' -f2 \
		| grep -E '^refs/tags/[0-9]+\.[0-9]+' \
		| cut -d/ -f3 \
		| cut -d^ -f1 \
		| grep -vE -- '-(alpha|beta|rc)' \
		| sort -ruV \
		| head -n1
)"

for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"
	rcGrepV='-v'
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
	fi
	rcGrepV+=' -E'
	rcGrepExpr='alpha|beta|rc'

	fullVersion="$(
		echo "$allVersions" \
			| grep -E "^${rcVersion}([.-]|$)" \
			| grep $rcGrepV -- "$rcGrepExpr" \
			| head -1
	)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "error: cannot determine full version for '$version'"
	fi

	# https://github.com/TryGhost/Ghost-CLI/commit/29848c090b9aaea32f19df5731fcf833b885f621
	channel='stable'
	if [ "$rcVersion" != "$version" ]; then
		channel='next'
	fi

	echo "$version: $fullVersion ($channel; cli $cliVersion)"

	sed -ri \
		-e 's/^(ENV GHOST_VERSION) .*/\1 '"$fullVersion"'/' \
		-e 's/^(ENV GHOST_CHANNEL) .*/\1 '"$channel"'/' \
		-e 's/^(ENV GHOST_CLI_VERSION) .*/\1 '"$cliVersion"'/' \
		"$version"/*/Dockerfile
done
