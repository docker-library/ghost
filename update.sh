#!/bin/bash
set -e

current="$(curl -sSL 'https://api.github.com/repos/TryGhost/Ghost/releases/latest' | awk -F '": "|"' '$2 == "tag_name" { print $3; exit }')"

set -x
sed -ri 's/^(ENV GHOST_VERSION) .*/\1 '"$current"'/' Dockerfile
