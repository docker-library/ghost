# ALPINE

###################################
# REQUIRED for bashLaVa https://github.com/firepress-org/bashlava
# REQUIRED for Github Action CI template https://github.com/firepress-org/ghostfire/tree/master/.github/workflows
###################################

ARG APP_NAME="ghostfire"
ARG VERSION="3.35.5"
ARG RELEASE="3.35.5"
ARG GITHUB_USER="firepress-org"

###################################
# REQUIRED BY OUR GITHUB ACTION CI
###################################

ARG GIT_PROJECT_NAME="ghostfire"
ARG DOCKERHUB_USER="devmtl"
ARG GITHUB_ORG="firepress-org"
ARG GITHUB_REGISTRY="registry"

ARG GIT_REPO_DOCKERFILE="https://github.com/firepress-org/ghostfire"
ARG GIT_REPO_SOURCE="https://github.com/TryGhost/Ghost"

###################################
# Start your Dockerfile from here
###################################
ARG OS="alpine"
ARG NODE_VERSION="12.18.4-alpine3.12"
  # node version issue: https://github.com/docker-library/ghost/issues/208
  # https://hub.docker.com/_/node/
ARG GHOST_CLI_VERSION="1.14.1"
ARG ALPINE_VERSION="3.12"
ARG USER="node"
ARG GHOST_USER="node"
ARG CREATED_DATE=not-set
ARG SOURCE_COMMIT=not-set

# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/LTS


# ----------------------------------------------
# 1) LAYER to manage base image(s) versioning
#   credit to Tõnis Tiigi / https://bit.ly/2RoCmvG
# ----------------------------------------------
FROM alpine:${ALPINE_VERSION} AS myalpine
FROM node:${NODE_VERSION} AS mynode

# ----------------------------------------------
# 2) LAYER app-version-debug
#   If a package crash on further layers, we don't know
#   which one did crash. This layer reveal package(s)
#   versions and keep a trace in the CI's logs.
# ----------------------------------------------
FROM myalpine AS app-version-debug

# grab su-exec for easy step-down from root
# add "bash" for "[["
RUN set -eux && apk update && apk add --no-cache \
    'su-exec>=0.2' bash upx curl tini tzdata && \
    apk upgrade

# ----------------------------------------------
# 3) LAYER node-compress
#   before node=39.8MO / after node=14.2MO
#   We copy from node image as it's using alpine.
#   It creates delta between app versions such upx.
# ----------------------------------------------
FROM myalpine AS node-compress
COPY --from=mynode /usr/local/bin/node /usr/local/bin/node
RUN set -eux                                                      && \
    apk --update add --no-cache                                   \
      upx="3.96-r0"                                               && \
    upx /usr/local/bin/node                                       && \
    upx -t /usr/local/bin/node                                    ;

# ----------------------------------------------
# 4) LAYER node-core
# Build our node-core layer (no extra stuff like yarn, npm, npx, etc.)
# ----------------------------------------------
FROM myalpine AS node-core
ARG GHOST_USER
ENV GHOST_USER="${GHOST_USER}"

# set up node user and group
RUN set -eux                                                      && \
    addgroup -g 1000 "${GHOST_USER}"                              && \
    adduser -u 1000 -G "${GHOST_USER}" -s /bin/sh -D node         ;

COPY --from=node-compress --chown=node:node /usr/local/bin/node /usr/bin/
COPY --from=mynode --chown=node:node /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/
# credit to https://github.com/mhart/alpine-node/blob/master/slim/Dockerfile

# ----------------------------------------------
# 5) LAYER ghost-base
# ----------------------------------------------
FROM node-core AS ghost-base
RUN set -eux && apk add --no-cache \
      # grab su-exec for easy step-down from root
      'su-exec>=0.2-r1' \
      bash="5.0.17-r0" \
      curl="7.69.1-r1" \
      tini="0.19.0-r0" \
      tzdata="2020c-r0" && \
    cp /usr/share/zoneinfo/America/New_York /etc/localtime        && \
    echo "America/New_York" > /etc/timezone                       && \
    apk del tzdata                                                && \
    rm -rvf /var/cache/apk/* /tmp/*                               ;

COPY --chown=node:node docker-entrypoint.sh /usr/local/bin
COPY --chown=node:node Dockerfile /usr/local/bin
COPY --chown=node:node README.md /usr/local/bin

ARG VERSION
ARG GHOST_CLI_VERSION
ARG NODE_VERSION
ARG ALPINE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    GHOST_USER="${GHOST_USER}"                                    \
    VERSION="${VERSION}"                                          \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"

# add knex-migrator bins into PATH
# we want these from the context of Ghost's "node_modules" directory (instead of doing "npm install -g knex-migrator") so they can share the DB driver modules
ENV PATH $PATH:$GHOST_INSTALL/current/node_modules/knex-migrator/bin

# credit to https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.authors="Pascal Andy https://firepress.org/en/contact/"  \
      org.opencontainers.image.vendors="https://firepress.org/"                         \
      org.opencontainers.image.created="$(date "+%Y-%m-%d_%HH%Ms%S")"                   \
      org.opencontainers.image.commit="$(git rev-parse --short HEAD)"                   \
      org.opencontainers.image.title="Ghost V2"                                         \
      org.opencontainers.image.description="Docker image for Ghost ${VERSION}"          \
      org.opencontainers.image.url="https://hub.docker.com/r/devmtl/ghostfire/tags/"    \
      org.opencontainers.image.source="https://github.com/firepress-org/ghostfire"      \
      org.opencontainers.image.licenses="GNUv3 https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE/blob/master/LICENSE.md" \
      org.firepress.image.cliversion="${GHOST_CLI_VERSION}"                             \
      org.firepress.image.user="${GHOST_USER}"                                          \
      org.firepress.image.node-env="${NODE_ENV}"                                        \
      org.firepress.image.nodeversion="${NODE_VERSION}"                                 \
      org.firepress.image.alpineversion="${ALPINE_VERSION}"                             \
      org.firepress.image.schemaversion="1.0"

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
USER "${GHOST_USER}"
EXPOSE 2368
  # HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1   // bypassed as attributes are passed during runtime <docker service create>
  # Next, copy Ghost's app in the final layer

# ----------------------------------------------
# 6) LAYER BUILDER
# ----------------------------------------------
FROM mynode AS ghost-builder

ARG VERSION
ARG GHOST_CLI_VERSION
ARG GHOST_USER
ARG NODE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    GHOST_USER="${GHOST_USER}"                                    \
    VERSION="${VERSION}"                                          \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"

# installation process from the official Ghost image https://bit.ly/2JWOTam
RUN set -eux && apk --update add --no-cache \
      su-exec>="0.2" \
      bash \
      ca-certificates                                             && \
    update-ca-certificates                                        && \
    rm -rvf /var/cache/apk/*                                      && \
    \
# install Ghost CLI
    npm install --production -g "ghost-cli@${GHOST_CLI_VERSION}"  && \
    npm cache clean --force                                       && \
    \
    mkdir -p "${GHOST_INSTALL}"                                   && \
    chown -R "${GHOST_USER}":"${GHOST_USER}" "${GHOST_INSTALL}"   && \
    \
# install Ghost / optional: --verbose
    su-exec node ghost install "${VERSION}"                       \
      --db sqlite3 --no-prompt --no-stack                         \
      --no-setup --dir "${GHOST_INSTALL}"                         && \
    \
# tell Ghost to listen on all IPs and not prompt for additional configuration
    cd "${GHOST_INSTALL}"                                         && \
    su-exec node ghost config --ip 0.0.0.0                        \
      --port 2368 --no-prompt --db sqlite3                        \
      --url http://localhost:2368                                 \
      --dbpath "${GHOST_CONTENT}/data/ghost.db"                   && \
    su-exec node ghost config                                     \
      paths.contentPath "${GHOST_CONTENT}"                        && \
    \
# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
    su-exec node ln -s config.production.json \
      "${GHOST_INSTALL}/config.development.json"                  && \
    readlink -f "${GHOST_INSTALL}/config.development.json"        && \
    \
# need to save initial content for pre-seeding empty volumes
    mv "${GHOST_CONTENT}" "${GHOST_INSTALL}/content.orig"         && \
    mkdir -p "${GHOST_CONTENT}"                                   && \
    chown -R "${GHOST_USER}":"${GHOST_USER}" "$GHOST_CONTENT"     && \
    \
# sanity check to ensure knex-migrator was installed
    "${GHOST_INSTALL}/current/node_modules/knex-migrator/bin/knex-migrator" --version && \
# sanity check to list all packages
    npm config list                                               ;

# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
RUN set -eux                                                      && \
    cd "${GHOST_INSTALL}/current"                                 && \
# scrape the expected version of sqlite3 directly from Ghost itself
    sqlite3Version="$(node -p 'require("./package.json").optionalDependencies.sqlite3')" && \
    \
    if ! su-exec node yarn add \
      "sqlite3@$sqlite3Version" --force; then                     \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
      apk add --no-cache --virtual                                \
        .build-deps                                               \
        python                                                    \
        make                                                      \
        gcc                                                       \
        g++                                                       \
        libc-dev                                                  && \
      \
      su-exec node yarn add "sqlite3@$sqlite3Version"             \
        --force --build-from-source                               && \
      \
      apk del --no-network .build-deps                            ; \
    fi                                                            && \
    su-exec node yarn cache clean                                 && \
    su-exec node npm cache clean --force                          && \
    npm cache clean --force                                       && \
    rm -rv /tmp/yarn* /tmp/v8*                                    ;

# ----------------------------------------------
# 7) LAYER final
# ----------------------------------------------
FROM ghost-base AS ghost-final
COPY --from=ghost-builder --chown=node:node "${GHOST_INSTALL}" "${GHOST_INSTALL}"
ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]
