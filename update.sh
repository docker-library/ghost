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
		| sort -rV
)"

travisEnv=
for version in "${versions[@]}"; do
	fullVersion="$(
		echo "$allVersions" \
			| grep -E "^${version}([.-]|$)" \
			| grep -vE 'alpha|beta' \
			| head -1
	)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "error: cannot determine full version for '$version'"
	fi

	(
		set -x
		sed -ri \
			-e 's/^(ENV GHOST_VERSION) .*/\1 '"$fullVersion"'/' \
			"$version"/*/Dockerfile
	)

	for variant in alpine debian; do
		travisEnv='\n  - VERSION='"$version"' VARIANT='"$variant$travisEnv"
	done
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
