# ----------------------------------------------
# At FirePress we run most things in Docker containers.
# These ARG are required during the Github Actions CI
# ----------------------------------------------
ARG APP_NAME="ghostfire"
ARG VERSION="5.16.0"
ARG GITHUB_USER="firepress-org"
ARG DEFAULT_BRANCH="master"
# remove ORG
ARG GITHUB_ORG="firepress-org"
ARG DOCKERHUB_USER="devmtl"
ARG GITHUB_REGISTRY="registry"

# ----------------------------------------------
# 1) Start your Dockerfile from here 
#   https://docs.ghost.org/faq/node-versions/
#   https://github.com/nodejs/Release (looking for "LTS")
#   https://github.com/TryGhost/Ghost/blob/v4.1.2/package.json#L38
# ----------------------------------------------
ARG GHOST_CLI_VERSION="1.23.0"
ARG NODE_VERSION="16-alpine3.16"
ARG BASE_OS="alpine"
ARG USER="node"

# ----------------------------------------------
# 2) LAYER to manage base image versioning. Credentials Tõnis Tiigi https://bit.ly/2RoCmvG
# ----------------------------------------------
FROM node:${NODE_VERSION} AS mynode

ARG VERSION
ARG GHOST_CLI_VERSION
ARG USER
ARG NODE_VERSION
ARG ALPINE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"          \
  GHOST_CONTENT="/var/lib/ghost/content"  \
  NODE_ENV="production"                   \
  USER="${USER}"                          \
  NODE_VERSION="${NODE_VERSION}"          \
  VERSION="${VERSION}"                    \
  GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"

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
  org.firepress.image.node_version="${NODE_VERSION}"                                \
  org.firepress.image.base_os="${BASE_OS}"                                          \
  org.firepress.image.schema_version="1.0"

# grab su-exec for easy step-down from root
# add "bash" for "[["
RUN set -eux && apk update && apk add --no-cache                  \
  'su-exec>=0.2' bash curl tzdata                               &&\
  # set up timezone
  cp /usr/share/zoneinfo/America/New_York /etc/localtime        &&\
  echo "America/New_York" > /etc/timezone                       &&\
  apk del tzdata                                                &&\
  rm -rvf /var/cache/apk/* /tmp/*                               ;

# ----------------------------------------------
# 3) LAYER debug
#   If a package crash on layers 4 or 5, we don't know which one crashed.
#   This layer reveal package(s) versions and keep a trace in the CI's logs.
# ----------------------------------------------
FROM mynode AS debug
RUN apk upgrade

# ----------------------------------------------
# 4) LAYER builder
#   from the official Ghost image https://bit.ly/2JWOTam
# ----------------------------------------------
FROM mynode AS builder

RUN set -eux; \
	npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
	npm cache clean --force ; \
	\
	mkdir -p "$GHOST_INSTALL"; \
	chown node:node "$GHOST_INSTALL"; \
	\
	apkDel=; \
	\
	installCmd='su-exec node ghost install "$VERSION" --db mysql --dbhost mysql --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"'; \
	if ! eval "$installCmd"; then \
		virtual='.build-deps-ghost'; \
		apkDel="$apkDel $virtual"; \
		apk add --no-cache --virtual "$virtual" g++ make python3; \
		eval "$installCmd"; \
	fi; \
	\
# Tell Ghost to listen on all ips and not prompt for additional configuration
	cd "$GHOST_INSTALL"; \
	su-exec node ghost config --no-prompt --ip '::' --port 2368 --url 'http://localhost:2368'; \
	su-exec node ghost config paths.contentPath "$GHOST_CONTENT"; \
	\
# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
	su-exec node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
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
#
# We have a RUN step here as sqlite cause trouble and it's easier to confirm where the build crash.
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
		installCmd='su-exec node yarn add "$package" --force'; \
		if ! eval "$installCmd"; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
			virtualPackages='g++ make python3'; \
			case "$package" in \
				# TODO sharp@*) virtualPackages="$virtualPackages pkgconf vips-dev"; \
				sharp@*) echo >&2 "sorry: libvips 8.12.1 in Alpine 3.15 is not new enough (8.12.2+) for sharp 0.30 😞"; continue ;; \
			esac; \
			virtual=".build-deps-${package%%@*}"; \
			apkDel="$apkDel $virtual"; \
			apk add --no-cache --virtual "$virtual" $virtualPackages; \
			\
			eval "$installCmd --build-from-source"; \
		fi; \
	done; \
	\
	if [ -n "$apkDel" ]; then \
		apk del --no-network $apkDel; \
	fi; \
	\
	su-exec node yarn cache clean; \
	su-exec node npm cache clean --force; \
	npm cache clean --force; \
	rm -rv /tmp/yarn* /tmp/v8*

# ----------------------------------------------
# 5) LAYER final
#   HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1
#   HEALTHCHECK attributes are passed during runtime <docker service create with var depending on the client IDs>
# ----------------------------------------------
FROM mynode AS final

COPY --chown="${USER}":"${USER}" /v5/docker-entrypoint.sh /usr/local/bin
COPY --from=builder --chown="${USER}":"${USER}" "${GHOST_INSTALL}" "${GHOST_INSTALL}"

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
USER "${USER}"
EXPOSE 2368

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]