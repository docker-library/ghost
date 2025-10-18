#!/usr/bin/env bash
set -Eeuo pipefail

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

getArchesJson() {
	local repo="$1"; shift
	: "${BASHBREW_LIBRARY:-https://github.com/docker-library/official-images/raw/HEAD/library}/"

	jq --raw-output '.[].variants[].from' versions.json \
		| sort -u \
		| xargs -r bashbrew cat --format '{ "{{ .RepoName }}:{{ .TagName }}": {{ json .TagEntry.Architectures }} }' \
		| jq --compact-output --null-input '[ inputs ] | add'
}
parentArchesJson="$(getArchesJson 'ghost')"

commit="$(fileCommit '*/**')" #

cat <<-EOH
# this file is generated via https://github.com/docker-library/ghost/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit),
             Austin Burdine <austin@acburdine.me> (@acburdine)
GitRepo: https://github.com/docker-library/ghost.git
GitCommit: $commit
EOH

jq --raw-output --argjson parentArches "$parentArchesJson" '
	# explodes a version to a list of tags
	# usage: .version | tags
	# e.g. "1.2.3.4" | tags -> [ "1.2.3.4", "1.2.3", "1.2", "1" ]
	def tags:
		# TODO improve rc suffix support (e.g. this wont work for -beta or -rc.1 versioned software)
		(if endswith("-rc") then "-rc" else "" end) as $suffix
		| rtrimstr($suffix)
		| split(".")
		| [ foreach .[] as $c ([]; .+=[$c]) | join(".") + $suffix ]
		| reverse
	;

	# returns a list of tags for this variant
	# usage: variant_tags("version"; [sortedVersionList]; "variant"; [sortedVariantList])
	# e.g. variant_tags("1.2.3.4"; ["1.2.3.4", "0.1.2.3"]; "trixie"; ["trixie", "alpine3.22"]) -> ["1.2.3.4-trixie", "1.2.3-trixie", ...]
	def variant_tags($version; $versionListSorted; $variant; $variantListSorted):
		$version | tags
		| . + [ if index($versionListSorted[0]) then "latest" else empty end ]
		| [
			# add tags with variant
			(.[] | "\(.)-\($variant)"), # "1.2.3" -> "1.2.3-alpine3.22" or "1.2.3-bookworm"

			# if it is the newest alpine, add tags without alpine version
			if ($variantListSorted | map(select(contains("alpine")))[0]) == $variant then
				(.[] | "\(.)-\($variant | sub("[0-9.]+$"; ""))") # "1.2.3-alpine3.22" -> "1.2.3-alpine"
			else empty end,

			# if it is the newest debian, add the plain tags
			if ($variantListSorted | map(select(contains("alpine") | not))[0]) == $variant then
				.[]
				# and add latest tag if it is also the newest ghost release
			else empty end,
			empty
		]
		| map(gsub("^latest-"; "")) # plain suite tags: "latest-trixie" -> "trixie"
	;

	# list of versions sorted in version order (already sorted in versions.json)
	[ .[].version ] as $allVersions
	# list of all variants in version.json order (debian suites followed by alpine versions, each in descending order)
	| [ .[].variants | keys_unsorted[] ] as $allVariants

	# loop over major versions
	| to_entries[]

	# only the major versions asked for "./generate-stackbrew-library.sh X Y ..."
	| if $ARGS.positional | length > 0 then
		select(IN(.key; $ARGS.positional[]))
	else . end

	| .key as $majorVersion
	| .value.version as $version

	# loop over variants sorted with debian variants followed by alpine variants (each in their own sorted order)
	| .value.variants | to_entries[]
	# sort_by(.key as $k | $allVariants | index($k))[]

	| (
		"", # newline between library entries
		"Tags: \(variant_tags($version; $allVersions; .key; $allVariants) | join(", "))",
		"Directory: \($majorVersion)/\(.key)",
		"Architectures: \(.value.arches - (.value.arches - $parentArches[.value.from]) | join(", "))",
		empty
	)
	' versions.json \
	--args -- "$@"
