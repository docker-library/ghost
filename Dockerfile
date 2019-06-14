ARG GHOST_VERSION="2.23.3"
ARG GHOST_CLI_VERSION="1.11.0"
ARG ALPINE_VERSION="3.9"
ARG NODE_VERSION="10.16-alpine"
ARG CREATED_DATE=not-set
ARG SOURCE_COMMIT=not-set

# LAYER node-compress — — — — — — — — — — — — — — — — — — — — — — — —
FROM node:${NODE_VERSION} AS node-compress
RUN set -eux                                                      && \
    apk --update --no-cache add upx="3.95-r1"                     && \
# compress node. Size before=39.8MO and after=14.2MO
    upx /usr/local/bin/node;

# LAYER node-core — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM alpine:${ALPINE_VERSION} AS node-core
# set up node user and group
RUN set -eux                                                      && \
    addgroup -g 1000 node                                         \
    && adduser -u 1000 -G node -s /bin/sh -D node;
# create our node-core layer (no extra stuff like yarn, npm, npx, etc.)
# thanks for the idea https://github.com/mhart/alpine-node/blob/master/slim/Dockerfile
COPY --from=node-compress /usr/local/bin/node /usr/bin/
COPY --from=node-compress /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

# LAYER ghost-base — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM node-core AS ghost-base
COPY docker-entrypoint.sh /usr/local/bin
COPY Dockerfile /usr/local/bin
COPY README.md /usr/local/bin
RUN set -eux                                                      && \
    apk --update --no-cache add 'su-exec>=0.2' bash="4.4.19-r1"   \
      curl="7.64.0-r2" tini="0.18.0-r0"                           && \
    rm -rf /var/cache/apk/*;

ARG GHOST_VERSION
ARG GHOST_CLI_VERSION
ARG NODE_VERSION
ARG ALPINE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    GHOST_USER="node"                                             \
    GHOST_VERSION="${GHOST_VERSION}"                              \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"

# best practice from https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.authors="Pascal Andy https://firepress.org/en/contact/"  \
      org.opencontainers.image.vendors="https://firepress.org/"                         \
      org.opencontainers.image.created="${CREATED_DATE}"                                \
      org.opencontainers.image.revision="${SOURCE_COMMIT}"                              \
      org.opencontainers.image.title="Ghost V2"                                         \
      org.opencontainers.image.description="Docker image for Ghost ${GHOST_VERSION}"    \
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
EXPOSE 2368
#USER $GHOST_USER                                             // bypassed as it causes all kinds of permission issues
#HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1   // bypassed as attributes are passed during runtime <docker service create>

# ==> next, copy the Ghost's app

# LAYER BUILDER — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM node:${NODE_VERSION} AS ghost-builder
 LAYER BUILDER — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM node:${NODE_VERSION} AS ghost-builder

ARG GHOST_VERSION
ARG GHOST_CLI_VERSION
ARG NODE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    GHOST_USER="node"                                             \
    GHOST_VERSION="${GHOST_VERSION}"                              \
    GHOST_CLI_VERSION="${GHOST_CLI_VERSION}"

# installation process from the official Ghost image https://bit.ly/2JWOTam
RUN set -eux                                                      && \
    apk --update --no-cache add su-exec>="0.2" bash="4.4.19-r1"   \
      ca-certificates="20190108-r0"                               && \
    update-ca-certificates                                        && \
    rm -rf /var/cache/apk/*                                       && \
    \
# install Ghost CLI
    npm install --production -g "ghost-cli@${GHOST_CLI_VERSION}"  && \
    npm cache clean --force                                       && \
    \
    mkdir -p "${GHOST_INSTALL}"                                   && \
    chown -R node:node "${GHOST_INSTALL}"                         && \
    \
# install Ghost / optional: --verbose
    su-exec node ghost install "${GHOST_VERSION}"                 \
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
    chown -R node:node "$GHOST_CONTENT"                           && \
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
    sqlite3Version="$(npm view . optionalDependencies.sqlite3)"   && \
    \
    if ! su-exec node yarn add "sqlite3@$sqlite3Version" --force; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
      apk add --no-cache --virtual                                \
        .build-deps python="2.7.16-r1" make="4.2.1-r2"            \
        gcc="2.31.1-r2" g++="1.1.20-r4" libc-dev="1.1.20-r4"      && \
      \
      su-exec node yarn add "sqlite3@$sqlite3Version"             \
        --force --build-from-source                               && \
      \
      apk del --no-network .build-deps                            ; \
    fi                                                            ;

# next, copy the Ghost app into the final layer

# LAYER ghost-source — — — — — — — — — — — — — — — — — — — — — — —
FROM ghost-base AS ghost-source
COPY --from=ghost-builder --chown=node:node "${GHOST_INSTALL}" "${GHOST_INSTALL}"

# LAYER scan — — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM node-slim AS ghost-to-scan
COPY --from=ghost-builder --chown=node:node "${GHOST_INSTALL}" "${GHOST_INSTALL}"
WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
EXPOSE 2368
#USER $GHOST_USER                                             // bypassed as it causes all kinds of permission issues
#HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1   // bypassed as attributes are passed during runtime <docker service create>
ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]

# LAYER audit — — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM ghost-source AS ghost-audit
ARG MICROSCANNER_TOKEN
USER root
ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner                                         && \
    /microscanner "${MICROSCANNER_TOKEN}" --continue-on-failure;

# LAYER final — — — — — — — — — — — — — — — — — — — — — — — — — — —
FROM node-slim AS ghost-final
COPY --from=ghost-builder --chown=node:node "${GHOST_INSTALL}" "${GHOST_INSTALL}"
WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
EXPOSE 2368
#USER $GHOST_USER                                             // bypassed as it causes all kinds of permission issues
#HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1   // bypassed as attributes are passed during runtime <docker service create>
ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]


    ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
    # NOTES
    #
    # multi-stage / using node-slim
    # devmtl/ghostfire:edge               fd2a63304e85        198MB (73MO)
    #
    # multi-stage / using node_10.16-alpine
    # devmtl/ghostfire:2.23.3-bf541c7     7c9797443ff5        246MB (79MO)
    #
    # single stage / using node_10.16-alpine
    # devmtl/ghostfire:2.22.2-407acbd      bea1138a850f       552MB (210MO)
    #
    # WIP: comform the ghost node app as a binary and compress this binary
    # 223 MO npm build
    # 170 MO (ghostapp binary)
    # 58 MO (ghostapp binary with upx)
    #
    ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###