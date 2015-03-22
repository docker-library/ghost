#!/bin/bash
set -e

if [[ "$*" == npm*start* ]]; then
	if [ ! -e "$GHOST_CONTENT/config.js" ]; then
		tar -c --one-file-system -C "$GHOST_SOURCE/content" . | tar xC "$GHOST_CONTENT"

		sed -r '
			s/127\.0\.0\.1/0.0.0.0/g;
			s!path.join\(__dirname, (.)/content!path.join(process.env.GHOST_CONTENT, \1!g;
		' "$GHOST_SOURCE/config.example.js" > "$GHOST_CONTENT/config.js"
                sed -i "/\(production:\)/a \ \ \ \ \ \ \ \ paths: { contentPath: path.join(process.env.GHOST_CONTENT, \'/\'\) }," "$GHOST_CONTENT/config.js"
	fi

	ln -sf "$GHOST_CONTENT/config.js" "$GHOST_SOURCE/config.js"

	chown -R user "$GHOST_CONTENT"

	set -- gosu user "$@"
fi

exec "$@"
