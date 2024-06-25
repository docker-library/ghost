# syntax=docker/dockerfile:1

# ----------------------------------------------
# 1a) ENV variables (core for all our projects at FirePress)
# ----------------------------------------------
ARG APP_NAME="ghostfire"
ARG VERSION="5.85.2"

ARG GITHUB_USER="firepress-org"
ARG DEFAULT_BRANCH="master"
ARG GITHUB_ORG="firepress-org"
ARG DOCKERHUB_USER="devmtl"
ARG GITHUB_REGISTRY="registry"

# ----------------------------------------------
# 1b) ENV variables (for this project)
# Various docs about our Dockerfile - https://github.com/firepress-org/ghostfire/issues/529
# ----------------------------------------------
ARG GHOST_CLI_VERSION="1.26.0"
ARG NODE_VERSION="18-alpine3.19"
ARG BASE_OS="alpine"
ARG USER="node"

# ----------------------------------------------
# 2) LAYER to manage base image versioning
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

LABEL org.opencontainers.image.authors="Pascal Andy https://firepress.org/en/contact/" \
	org.opencontainers.image.vendor="https://firepress.org/" \
	org.opencontainers.image.created="${BUILD_DATE}" \
	org.opencontainers.image.revision="${VCS_REF}" \
	org.opencontainers.image.title="Ghost" \
	org.opencontainers.image.description="Docker image for Ghost ${VERSION}" \
	org.opencontainers.image.url="https://hub.docker.com/r/devmtl/ghostfire/tags/" \
	org.opencontainers.image.source="https://github.com/firepress-org/ghostfire" \
	org.opencontainers.image.licenses="GNUv3 https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE/blob/master/LICENSE.md" \
	com.firepress.image.ghost_cli_version="${GHOST_CLI_VERSION}" \
	com.firepress.image.user="${USER}" \
	com.firepress.image.node_env="${NODE_ENV}" \
	com.firepress.image.node_version="${NODE_VERSION}" \
	com.firepress.image.base_os="${BASE_OS}" \
	com.firepress.image.schema_version="1.0"

# Install gosu for easy step-down from root
ENV GOSU_VERSION 1.17
RUN set -eux; \
	apk add --no-cache --virtual .gosu-deps \
	ca-certificates \
	dpkg \
	gnupg \
	; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apk del --no-network .gosu-deps; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

# Add bash and set timezone
RUN apk add --no-cache bash curl tzdata && \
	cp /usr/share/zoneinfo/America/New_York /etc/localtime && \
	echo "America/New_York" > /etc/timezone && \
	apk del tzdata && \
	rm -rvf /var/cache/apk/* /tmp/*

# ----------------------------------------------
# 3) LAYER debug
#   If a package crash on layers 4 or 5, we don't know which one crashed.
#   This layer reveal package(s) versions and keep a trace in the CI's logs.
# ----------------------------------------------
FROM mynode AS debug
RUN apk upgrade

# ----------------------------------------------
# 4) LAYER builder
# ----------------------------------------------
FROM mynode AS builder

RUN set -eux; \
	npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
	npm cache clean --force; \
	mkdir -p "$GHOST_INSTALL"; \
	chown node:node "$GHOST_INSTALL"; \
	apkDel=; \
	installCmd='gosu node ghost install "$VERSION" --db mysql --dbhost mysql --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"'; \
	if ! eval "$installCmd"; then \
	virtual='.build-deps-ghost'; \
	apkDel="$apkDel $virtual"; \
	apk add --no-cache --virtual "$virtual" g++ linux-headers make python3; \
	eval "$installCmd"; \
	fi; \
	cd "$GHOST_INSTALL"; \
	gosu node ghost config --no-prompt --ip '::' --port 2368 --url 'http://localhost:2368'; \
	gosu node ghost config paths.contentPath "$GHOST_CONTENT"; \
	gosu node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
	readlink -f "$GHOST_INSTALL/config.development.json"; \
	mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
	mkdir -p "$GHOST_CONTENT"; \
	chown node:node "$GHOST_CONTENT"; \
	chmod 1777 "$GHOST_CONTENT"; \
	cd "$GHOST_INSTALL/current"; \
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
	virtualPackages='g++ make python3'; \
	case "$package" in \
	sharp@*) echo >&2 "sorry: libvips 8.12.1 in Alpine 3.15 is not new enough (8.12.2+) for sharp 0.30 😞"; continue ;; \
	esac; \
	virtual=".build-deps-${package%%@*}"; \
	apkDel="$apkDel $virtual"; \
	apk add --no-cache --virtual "$virtual" $virtualPackages; \
	eval "$installCmd --build-from-source"; \
	fi; \
	done; \
	if [ -n "$apkDel" ]; then \
	apk del --no-network $apkDel; \
	fi; \
	gosu node yarn cache clean; \
	gosu node npm cache clean --force; \
	npm cache clean --force; \
	rm -rv /tmp/yarn* /tmp/v8*

# ----------------------------------------------
# 5) LAYER final
# ----------------------------------------------
FROM mynode AS final

COPY --chown="${USER}":"${USER}" /v5/docker-entrypoint.sh /usr/local/bin
COPY --from=builder --chown="${USER}":"${USER}" "${GHOST_INSTALL}" "${GHOST_INSTALL}"

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
USER "${USER}"
EXPOSE 2368

# HEALTHCHECK attributes are passed during runtime <docker service>
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
	CMD wget --quiet --tries=1 --spider http://localhost:2368 || exit 1

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]