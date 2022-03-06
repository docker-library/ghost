# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/Release (looking for "LTS")
# https://github.com/TryGhost/Ghost/blob/v4.1.2/package.json#L38
FROM node:14-bullseye-slim

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.12
RUN set -eux; \
# save list of currently installed packages for later so we can clean up
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates dirmngr gnupg wget; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true

ENV NODE_ENV production

ENV GHOST_CLI_VERSION 1.18.1
RUN set -eux; \
	npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
	npm cache clean --force

ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

ENV GHOST_VERSION 4.38.0

RUN set -eux; \
	mkdir -p "$GHOST_INSTALL"; \
	chown node:node "$GHOST_INSTALL"; \
	\
	gosu node ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
	\
# Tell Ghost to listen on all ips and not prompt for additional configuration
	cd "$GHOST_INSTALL"; \
	gosu node ghost config --ip '::' --port 2368 --no-prompt --db sqlite3 --url http://localhost:2368 --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	gosu node ghost config paths.contentPath "$GHOST_CONTENT"; \
	\
# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
	gosu node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
	readlink -f "$GHOST_INSTALL/config.development.json"; \
	\
# need to save initial content for pre-seeding empty volumes
	mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
	mkdir -p "$GHOST_CONTENT"; \
	chown node:node "$GHOST_CONTENT"; \
	chmod 1777 "$GHOST_CONTENT"; \
	\
# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
	cd "$GHOST_INSTALL/current"; \
# scrape the expected version of sqlite3 directly from Ghost itself
	sqlite3Version="$(node -p 'require("./package.json").optionalDependencies.sqlite3')"; \
	sharpVersion="$(node -p 'require("./node_modules/@tryghost/image-transform/package.json").optionalDependencies.sharp')"; \
	gosu node yarn add "sqlite3@$sqlite3Version" --force && sqlite3Installed=Y || sqlite3Installed=N; \
	gosu node yarn add "sharp@$sharpVersion" --force && sharpInstalled=Y || sharpInstalled=N; \
	if [ "$sqlite3Installed" = "N" ] || [ "$sharpInstalled" = "N" ]; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends g++ gcc libc-dev make python2; \
		rm -rf /var/lib/apt/lists/*; \
		\
		[ "$sqlite3Installed" = "N" ] && npm_config_python='python2' gosu node yarn add "sqlite3@$sqlite3Version" --force --build-from-source --ignore-optional; \
		[ "$sqlite3Installed" = "N" ] && \
			# We need a recent copy of "libvips-dev". We're running Debian bullseye.
			# So we build the bookworm version of "libvips-dev" against the existing bullseye runtime. This gives us best compatibility.
			( mkdir -p /tmp/libvips-build; \
			cd /tmp/libvips-build; \
			# Add a repo source code entry for Debian bookworm.
			echo "deb-src http://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list; \
			apt-get update; \
			# First we build bookworm "libcgif-dev", a prerequisite for "libvips-dev" that's not in Debian bullseye
			apt-get build-dep -y libcgif-dev; \
			apt-get -b source libcgif-dev; \
			dpkg -i libcgif0_*.deb libcgif-dev_*.deb; \
			# Next we build bookworm "libvips-dev" against the rest of the bullseye packages.
			apt-get build-dep -y libvips-dev; \
			apt-get -b source libvips-dev; \
			dpkg -i libvips42_*.deb gir1.2-vips-8.0_*.deb libvips-dev_*.deb; \
			# We've finally got "libvips-dev" installed, now we can build sharp.
			cd "$GHOST_INSTALL/current"; \
			npm_config_python='python2' npm_config_build_from_source=true gosu node yarn add "sharp@$sharpVersion"; ) || echo "sharp@$sharpVersion: build failed, continuing..."; \
		apt-mark showmanual | xargs apt-mark auto > /dev/null; \
		[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
		[ "$sharpInstalled" = "N" ] && apt-mark manual libvips42; \
		apt-get purge -y --auto-remove; \
	fi; \
	\
	gosu node yarn cache clean; \
	gosu node npm cache clean --force; \
	npm cache clean --force; \
	rm -rv /tmp/yarn* /tmp/v8* /tmp/libvips-build

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2368
CMD ["node", "current/index.js"]
