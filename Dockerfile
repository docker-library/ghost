# ----------------------------------------------
# At FirePress we run virtually everything in Docker
# Dockerfile required by https://github.com/firepress-org/bashlava
# Dockerfile required by our Github Actions CI 
# ----------------------------------------------
ARG APP_NAME="ghostfire"
ARG VERSION="4.6.3"
ARG RELEASE="4.6.3"
ARG GITHUB_USER="firepress-org"

ARG GIT_PROJECT_NAME="ghostfire"
ARG DOCKERHUB_USER="devmtl"
ARG GITHUB_ORG="firepress-org"
ARG GITHUB_REGISTRY="registry"

ARG GIT_REPO_DOCKERFILE="https://github.com/firepress-org/ghostfire"
ARG GIT_REPO_SOURCE="https://github.com/TryGhost/Ghost"

# ----------------------------------------------
# Start your Dockerfile from here
# ----------------------------------------------
# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/Release (looking for "LTS")
# https://github.com/TryGhost/Ghost/blob/v4.1.2/package.json#L38
ARG GHOST_CLI_VERSION="1.17.3"
ARG NODE_VERSION="12-alpine3.12"
ARG ALPINE_VERSION="3.12"
ARG OS="alpine"
ARG USER="node"

# ----------------------------------------------
# 1) LAYER to manage base image(s) versioning.
# Credit to Tõnis Tiigi https://bit.ly/2RoCmvG
# ----------------------------------------------
FROM alpine:${ALPINE_VERSION} AS myalpine
FROM node:${NODE_VERSION} AS mynode

# ----------------------------------------------
# 2) LAYER version-debug
#   If a package crash on layers 3-4, we don't know
#   which one crashed. This layer reveal package(s)
#   versions and keep a trace in the CI's logs.
# ----------------------------------------------
FROM myalpine AS version-debug
# grab su-exec for easy step-down from root
# add "bash" for "[["
RUN set -eux && apk update && apk add --no-cache                  \
    'su-exec>=0.2' bash curl tzdata                               &&\
    apk upgrade

# ----------------------------------------------
# 3) LAYER ghost-builder
# ----------------------------------------------
FROM mynode AS ghost-builder

ARG VERSION
ARG GHOST_CLI_VERSION
ARG USER
ARG NODE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    USER="${USER}"                                                \
    VERSION="${VERSION}"                                          \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"

# installation process from the official Ghost image https://bit.ly/2JWOTam
RUN set -eux && apk update && apk add --no-cache                  \
    'su-exec>=0.2' bash curl tzdata                               &&\
    \
# install Ghost CLI
    npm install --production -g "ghost-cli@${GHOST_CLI_VERSION}"  &&\
    npm cache clean --force                                       &&\
    mkdir -p "${GHOST_INSTALL}"                                   &&\
    chown -R "${USER}":"${USER}" "${GHOST_INSTALL}"               &&\
    \
# install Ghost / optional: --verbose
    su-exec "${USER}" ghost install "${VERSION}"                  \
      --db sqlite3 --no-prompt --no-stack                         \
      --no-setup --dir "${GHOST_INSTALL}"                         &&\
    \
# tell Ghost to listen on all IPs and not prompt for additional configuration
    cd "${GHOST_INSTALL}"                                         &&\
    su-exec "${USER}" ghost config --ip 0.0.0.0                   \
      --port 2368 --no-prompt --db sqlite3                        \
      --url http://localhost:2368                                 \
      --dbpath "${GHOST_CONTENT}/data/ghost.db"                   &&\
    su-exec "${USER}" ghost config                                \
      paths.contentPath "${GHOST_CONTENT}"                        &&\
    \
# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
    su-exec "${USER}" ln -s config.production.json \
      "${GHOST_INSTALL}/config.development.json"                  &&\
    readlink -f "${GHOST_INSTALL}/config.development.json"        &&\
    \
# need to save initial content for pre-seeding empty volumes
    mv "${GHOST_CONTENT}" "${GHOST_INSTALL}/content.orig"         &&\
    mkdir -p "${GHOST_CONTENT}"                                   &&\
    chown -R "${USER}":"${USER}" "${GHOST_CONTENT}"               &&\
    chmod 1777 "${GHOST_CONTENT}"                                 &&\
    \
# sanity check to ensure knex-migrator was installed
    "${GHOST_INSTALL}/current/node_modules/knex-migrator/bin/knex-migrator" --version &&\
# sanity check to list all packages
    npm config list                                               &&\
    \
# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
    cd "${GHOST_INSTALL}/current"                                 &&\
# scrape the expected version of sqlite3 directly from Ghost itself
# WARNING: crash when using node:14.16-alpine3.13
    sqlite3Version="$(node -p 'require("./package.json").optionalDependencies.sqlite3')" &&\
    \
    if ! su-exec "${USER}" yarn add "sqlite3@$sqlite3Version" --force; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
      apk add --no-cache --virtual .build-deps g++                \
        gcc libc-dev make python3 vips-dev                        &&\
      npm_config_python='python3' su-exec "${USER}"               \
        yarn add "sqlite3@$sqlite3Version" --force                \
        --build-from-source --ignore-optional                     &&\
      apk del --no-network .build-deps                            ; \
    fi                                                            &&\
    \
    su-exec "${USER}" yarn cache clean                            &&\
    su-exec "${USER}" npm cache clean --force                     &&\
    npm cache clean --force                                       &&\
    rm -rv /tmp/yarn* /tmp/v8*                                    ;

# ----------------------------------------------
# 4) LAYER ghost-final
# ----------------------------------------------
FROM mynode AS ghost-final

ARG VERSION
ARG GHOST_CLI_VERSION
ARG USER
ARG NODE_VERSION
ARG ALPINE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    USER="${USER}"                                                \
    VERSION="${VERSION}"                                          \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"


RUN set -eux && apk update && apk add --no-cache                  \
    'su-exec>=0.2' bash curl tzdata                               &&\
# set up timezone
    cp /usr/share/zoneinfo/America/New_York /etc/localtime        &&\
    echo "America/New_York" > /etc/timezone                       &&\
    apk del tzdata                                                &&\
    rm -rvf /var/cache/apk/* /tmp/*                               ;

COPY --chown="${USER}":"${USER}" docker-entrypoint.sh /usr/local/bin
COPY --chown="${USER}":"${USER}" Dockerfile /usr/local/bin
COPY --chown="${USER}":"${USER}" README.md /usr/local/bin
COPY --from=ghost-builder --chown="${USER}":"${USER}" "${GHOST_INSTALL}" "${GHOST_INSTALL}"

# add knex-migrator bins into PATH
# we want these from the context of Ghost's "node_modules" directory (instead of doing "npm install -g knex-migrator") so they can share the DB driver modules
# ENV PATH $PATH:${GHOST_INSTALL}/current/node_modules/knex-migrator/bin

# credit to https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.authors="Pascal Andy https://firepress.org/en/contact/"  \
      org.opencontainers.image.vendors="https://firepress.org/"                         \
      org.opencontainers.image.created="$(date "+%Y-%m-%d_%HH%Ms%S")"                   \
      org.opencontainers.image.commit="$(git rev-parse --short HEAD)"                   \
      org.opencontainers.image.title="Ghost v${VERSION}"                                \
      org.opencontainers.image.description="Docker image for Ghost ${VERSION}"          \
      org.opencontainers.image.url="https://hub.docker.com/r/devmtl/ghostfire/tags/"    \
      org.opencontainers.image.source="https://github.com/firepress-org/ghostfire"      \
      org.opencontainers.image.licenses="GNUv3 https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE/blob/master/LICENSE.md" \
      org.firepress.image.ghost_cli_version="${GHOST_CLI_VERSION}"                      \
      org.firepress.image.user="${USER}"                                                \
      org.firepress.image.node_env="${NODE_ENV}"                                        \
      org.firepress.image.node_version="${NODE_VERSION}"                                \
      org.firepress.image.alpine_version="${ALPINE_VERSION}"                            \
      org.firepress.image.schema_version="1.0"

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
USER "${USER}"
EXPOSE 2368

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]

# ----------------------------------------------
# HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1
# HEALTHCHECK attributes are passed during runtime <docker service create>
# ----------------------------------------------
