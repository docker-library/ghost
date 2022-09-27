### STAGE GHA env
#
# At FirePress we run most things in Docker containers
# These env/arg are required during by GHA (Github Actions)
ARG APP_NAME="ghostfire"
ARG VERSION="5.15.0"
ARG GITHUB_USER="firepress-org"
ARG DEFAULT_BRANCH="master"
ARG GITHUB_ORG="firepress-org"
ARG DOCKERHUB_USER="devmtl"
ARG GITHUB_REGISTRY="registry"

### Not needed by GHA
ARG BASE_OS="ubuntu"
ARG USER="node"
ARG GHOST_CLI_VERSION="1.23.0"
ARG GOSU_VERSION="1.12"

### Define base image versions
FROM node:16.17.0-bullseye-slim as node
FROM ubuntu:jammy-20220815 as ubuntu
#
# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/Release (looking for "LTS")
# https://github.com/TryGhost/Ghost/blob/v4.1.2/package.json#L38
#
# ubuntu base with nodejs coppied in from official image, for a more secure base
# https://hub.docker.com/_/ubuntu
# https://hub.docker.com/_/node


### STAGE base
#
FROM ubuntu as base
# Install node: copy in the specific version we want from a docker image
# This avoids depdency package installs (python3) that the deb package requires
COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/

# tini: replace npm in CMD with tini for better kernel signal handling
# You may also need development tools to build native npm addons:
# apt-get install gcc g++ make
RUN apt-get update \
    && apt-get -qq install -y --no-install-recommends \
        ca-certificates dirmngr gnupg wget tini curl \
    && rm -rf /var/lib/apt/lists/* \
    # prevent symlimk errors
    && corepack disable && corepack enable \
    \
    # create node user and group, then create app dir
    && groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

ARG VERSION
ARG GHOST_CLI_VERSION
ARG USER
ARG GOSU_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"              \
    GHOST_CONTENT="/var/lib/ghost/content"      \
    NODE_ENV="production"                       \
    USER="${USER}"                              \
    VERSION="${VERSION}"                        \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"    \
    GOSU_VERSION="${GOSU_VERSION}"

# credit to https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.authors="Pascal Andy https://firepress.org/en/contact/"  \
    org.opencontainers.image.vendors="https://firepress.org/"                         \
    org.opencontainers.image.created="$(date "+%Y-%m-%d_%HH%Ms%S")"                   \
    org.opencontainers.image.commit="$(git rev-parse --short HEAD)"                   \
    org.opencontainers.image.title="Ghost"                                            \
    org.opencontainers.image.description="Docker image for Ghost ${VERSION}"          \
    org.opencontainers.image.url="https://hub.docker.com/r/devmtl/ghostfire/tags/"    \
    org.opencontainers.image.source="https://github.com/firepress-org/ghostfire"      \
    org.opencontainers.image.licenses="GNUv3 https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE/blob/master/LICENSE.md" \
    org.firepress.image.ghost_cli_version="${GHOST_CLI_VERSION}"                      \
    org.firepress.image.user="${USER}"                                                \
    org.firepress.image.node_env="${NODE_ENV}"                                        \
    org.firepress.image.base_os="${BASE_OS}"

### STAGE build
###
### from https://github.com/docker-library/ghost/5/debian/Dockerfile
FROM node AS build

ARG VERSION
ARG GHOST_CLI_VERSION
ARG USER
ARG GOSU_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"              \
    GHOST_CONTENT="/var/lib/ghost/content"      \
    NODE_ENV="production"                       \
    USER="${USER}"                              \
    VERSION="${VERSION}"                        \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"    \
    GOSU_VERSION="${GOSU_VERSION}"

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
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

RUN set -eux; \
    npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
    npm cache clean --force

RUN set -eux; \
	mkdir -p "$GHOST_INSTALL"; \
	chown node:node "$GHOST_INSTALL"; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	aptPurge=; \
	\
	installCmd='gosu node ghost install "$VERSION" --db mysql --dbhost mysql --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"'; \
	if ! eval "$installCmd"; then \
		aptPurge=1; \
		apt-get update; \
		apt-get install -y --no-install-recommends g++ make python3; \
		eval "$installCmd"; \
	fi; \
	\
# Tell Ghost to listen on all ips and not prompt for additional configuration
	cd "$GHOST_INSTALL"; \
	gosu node ghost config --no-prompt --ip '::' --port 2368 --url 'http://localhost:2368'; \
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
# force install a few extra packages manually since they're "optional" dependencies
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
	cd "$GHOST_INSTALL/current"; \
# scrape the expected versions directly from Ghost/dependencies
	packages="$(node -p ' \
		var ghost = require("./package.json"); \
		var transform = require("./node_modules/@tryghost/image-transform/package.json"); \
		[ \
			"sharp@" + transform.optionalDependencies["sharp"], \
			"sqlite3@" + ghost.optionalDependencies["sqlite3"], \
		].join(" ") \
	')"; \
	if echo "$packages" | grep 'undefined'; then exit 1; fi; \
	for package in $packages; do \
		installCmd='gosu node yarn add "$package" --force'; \
		if ! eval "$installCmd"; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
			aptPurge=1; \
			apt-get update; \
			apt-get install -y --no-install-recommends g++ make python3; \
			case "$package" in \
				# TODO sharp@*) apt-get install -y --no-install-recommends libvips-dev ;; \
				sharp@*) echo >&2 "sorry: libvips 8.10 in Debian bullseye is not new enough (8.12.2+) for sharp 0.30 😞"; continue ;; \
			esac; \
			\
			eval "$installCmd --build-from-source"; \
		fi; \
	done; \
	\
	if [ -n "$aptPurge" ]; then \
		apt-mark showmanual | xargs apt-mark auto > /dev/null; \
		[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
		apt-get purge -y --auto-remove; \
		rm -rf /var/lib/apt/lists/*; \
	fi; \
	\
	gosu node yarn cache clean; \
	gosu node npm cache clean --force; \
	npm cache clean --force; \
	rm -rv /tmp/yarn* /tmp/v8*

### STAGE debug
###
#FROM build AS debug

### STAGE prod
###
### HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1
### HEALTHCHECK attributes are passed during runtime <docker service create with var depending on the client IDs>
FROM base as prod
COPY --chown="${USER}":"${USER}" /v5-debian/docker-entrypoint.sh /usr/local/bin
COPY --from=build --chown="${USER}":"${USER}" "${GHOST_INSTALL}" "${GHOST_INSTALL}"

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
EXPOSE 2368
# tiny is missing as we test
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]
