#!/bin/bash
set -e

# logging functions
mydocker_log() {
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date -R)"
	printf '%s [%s] [Entrypoint]: %s\n' "$dt" "$type" "$text"
}
mydocker_note() {
	mydocker_log Note "$@"
}
mydocker_warn() {
	mydocker_log Warn "$@" >&2
}
mydocker_error() {
	mydocker_log ERROR "$@" >&2
	exit 1
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	mydocker_log "var: $var filevar: $fileVar dev: $def"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		mydocker_error "Both $var and $fileVar are set (but are exclusive)"
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# Loads various settings that are used elsewhere in the script
docker_setup_env() {
  # Initialize values that might be stored in a file
  for env_var in $(env | grep '_FILE=' | awk -F= '{print $1}'); do
	  file_env "${env_var%_FILE}"
  done
}

# allow the container to be started with `--user`
if [[ "$*" == node*current/index.js* ]] && [ "$(id -u)" = '0' ]; then
	find "$GHOST_CONTENT" \! -user node -exec chown node '{}' +
	exec gosu node "$BASH_SOURCE" "$@"
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
fi

# enable secrets _FILE
docker_setup_env "$@"

exec "$@"
