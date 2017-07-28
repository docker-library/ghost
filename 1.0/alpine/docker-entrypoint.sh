#!/bin/bash
set -e

# allow the container to be started with `--user`
if [[ "$*" == node*current/index.js* ]] && [ "$(id -u)" = '0' ]; then
	chown -R node "$GHOST_INSTALL"
	exec su-exec node "$BASH_SOURCE" "$@"
fi

if [[ "$*" == node*current/index.js* ]]; then
	knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"
fi

exec "$@"