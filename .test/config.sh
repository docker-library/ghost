#!/usr/bin/env bash

# https://github.com/docker-library/bashbrew/blob/a67d6088ac9971c8a73e057152be73322e988b09/scripts/github-actions/generate.sh#L108
# https://github.com/docker-library/official-images/blob/5f915a272d7446666dbf02007616a7b63d645e2f/test/config.sh

imageTests+=(
	[ghost]='
		ghost-basics
	'
)
