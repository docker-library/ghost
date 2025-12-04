#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

allVersions="$(
	git ls-remote --tags https://github.com/TryGhost/Ghost.git \
		| sed -rne 's!^.*\trefs/tags/v?|\^\{\}$!!g; /^[0-9][.][0-9]+/p' \
		| sort -ruV
)"

cliVersion="$(
	git ls-remote --tags https://github.com/TryGhost/Ghost-CLI.git \
		| sed -rne 's!^.*\trefs/tags/v?|\^\{\}$!!g; /^[0-9][.][0-9]+/p' \
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
	export version

	fullVersion="$(
		echo "$allVersions" \
			| grep -E "^${rcVersion}([.-]|$)" \
			| grep $rcGrepV -- "$rcGrepExpr" \
			| head -1
	)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "error: cannot determine full version for '$version'"
		exit 1
	fi

	# get a list of architectures supported by the sharp module's prebuilt libraries
	# we cannot build it on other arches since the dep, libvips, is usually too old in Debian and Alpine
	doc="$(curl -fsSL "https://raw.githubusercontent.com/TryGhost/Ghost/refs/tags/v$fullVersion/yarn.lock" \
		| jq --compact-output --raw-input --null-input '
			reduce (
				inputs
				| capture("^ *\"@img/sharp-(?<dist>linux[a-z]*)-(?<arch>[a-z0-9]+)\" \"[0-9.]+\"$")
			) as $item ({
				# this controls the variant ordering
				linux: [], # non-Alpine first
				linuxmusl: [], # Alpine second
			}; .[$item.dist] += [ $item.arch ])
			| with_entries(
				select(.value | length > 0)
				| .key = {
					# each of these should be a single distro version unless something *really* exceptional happens
					# if there is more than one, they should be in descending order
					linux: [ "bookworm" ],
					linuxmusl: [ "alpine3.23" ],
				}[.key][]
				| .value = {
					arches: (
						.value | map({
							x64: "amd64",
							arm64: "arm64v8",
							arm: "arm32v7",
							s390x: "s390x",
						}[.] // empty) # TODO maybe warn/error on unexpected values?
						| sort
					)
				}
			)
		'
	)"

	export fullVersion cliVersion
	json="$(jq <<<"$json" --compact-output --argjson doc "$doc" '
		{
			# https://docs.ghost.org/faq/node-versions
			# https://github.com/nodejs/Release (looking for "LTS")
			"5": "20",
			"6": "22",
		}[env.version] as $nodeVersion
		| .[env.version] = {
			version: env.fullVersion,
			cli: { version: env.cliVersion },
			node: { version: $nodeVersion },
			variants: (
				$doc
				| with_entries(
					# add image FROM for Dockerfile template and parent arch lookup in generate-stackbrew-library.sh
					# e.g. "node:22-alpine3.23" or "node:22-trixie-slim"
					.value.from = "node:\($nodeVersion)-\(.key)\(
						if .key | startswith("alpine") then "" else "-slim" end
					)"
				)
			),
		}
	')"
done

jq <<<"$json" '
	to_entries

	# sort by version number, descending
	| sort_by(.value.version | split("[.-]"; "") | map(tonumber? // .))
	| reverse

	| from_entries
' > versions.json
