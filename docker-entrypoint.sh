#!/usr/bin/env bash
# source https://github.com/docker-library/ghost/blob/master/1/alpine/docker-entrypoint.sh

set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o nounset

# allow the container to be started with `--user`
if [[ "$*" == node*current/index.js* ]] && [ "$(id -u)" = '0' ]; then
	chown -R node "$GHOST_CONTENT"
	exec su-exec node "$BASH_SOURCE" "$@"
fi

if [[ "$*" == node*current/index.js* ]]; then
	baseDir="$GHOST_INSTALL/content.orig"
	for src in "$baseDir"/*/ "$baseDir"/themes/*; do
		src="${src%/}"
		target="$GHOST_CONTENT/${src#$baseDir/}"
		mkdir -p "$(dirname "$target")"
		if [ ! -e "$target" ]; then
			tar -cC "$(dirname "$src")" "$(basename "$src")" | tar -xC "$(dirname "$target")"
		fi
	done

	knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"
fi

exec "$@"
