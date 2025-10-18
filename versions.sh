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

	doc="$(curl -fsSL "https://raw.githubusercontent.com/TryGhost/Ghost/refs/tags/v$fullVersion/yarn.lock" \
		| jq --compact-output --raw-input --null-input '
			reduce (
				inputs
				| capture("^ *\"@img/sharp-(?<name>linux[a-z0-9-]+)\" \"[0-9.]+\"$")
				| .name
				| split("-")
				| {
					dist: {
						linux: [
							# list of debian versions, in descending order
							#"trixie", # TODO
							"bookworm",
							empty # trailing comma
						],
						linuxmusl: [
							# list of alpine versions, in descending order
							"3.22",
							empty
							| "alpine" + .
						]
					}[.[0]],
					arch: {
						x64: "amd64",
						arm64: "arm64v8",
						arm: "arm32v7",
						s390x: "s390x",
					}[.[1]],
				}
			) as $item ({}; .[$item.dist[]].arches += [ $item.arch ])
			| with_entries(.value.arches |= sort)
		'
	)"

	export fullVersion cliVersion
	json="$(jq <<<"$json" -c --argjson doc "$doc" '
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
					# e.g. "node:22-alpine3.22" or "node:22-trixie-slim"
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
	| sort_by(.value.version | split("[.-]"; "") | map(tonumber? // .) )
	| reverse

	# move alpine variants to the end of the object
	# debian suites and alpine versions are each relatively sorted already
	| map(.value.variants |= ( to_entries | sort_by(.key | contains("alpine")) | from_entries))

	| from_entries
'> versions.json
