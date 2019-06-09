# Forked from official Ghost image https://bit.ly/2JWOTam

ARG GHOST_VERSION="2.23.3"
ARG GHOST_CLI_VERSION="1.11.0"
ARG NODE_VERSION="10.16-alpine"

# Base layer
### ### ### ### ### ### ### ### ###
FROM node:${NODE_VERSION} AS ghost-base

ARG GHOST_VERSION
ARG GHOST_CLI_VERSION
ARG NODE_VERSION

ENV GHOST_INSTALL="/var/lib/ghost"                                \
    GHOST_CONTENT="/var/lib/ghost/content"                        \
    NODE_ENV="production"                                         \
    GHOST_USER="node"                                             \
    GHOST_VERSION=${GHOST_VERSION}                                \
    GHOST_CLI_VERSION=${GHOST_CLI_VERSION}                        \
    MAINTAINER="Pascal Andy <https://firepress.org/en/contact/>"

LABEL org.label-schema.ghost.version="${GHOST_VERSION}"           \
      org.label-schema.ghost.cli-version="${GHOST_CLI_VERSION}"   \
      org.label-schema.ghost.user="${GHOST_USER}"                 \
      org.label-schema.ghost.node-env="${NODE_ENV}"               \
      org.label-schema.ghost.node-version="${NODE_VERSION}"       \
      org.label-schema.ghost.maintainer="${MAINTAINER}"           \
      org.label-schema.schema-version="1.0"

RUN set -eux                                                      && \
    apk --update --no-cache add \
        'su-exec>=0.2' \
        bash \
        curl \
        tini && \
    rm -rf /var/cache/apk/*                                       ;

# Builder layer
### ### ### ### ### ### ### ### ###
FROM ghost-base AS ghost-builder

RUN set -eux                                                      && \
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
# tell Ghost to listen on all ips and not prompt for additional configuration
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
    "${GHOST_INSTALL}/current/node_modules/knex-migrator/bin/knex-migrator" --version \
    \
# uninstall ghost-cli / Let's save a few bytes
    su-exec node npm uninstall -S -D -O -g                        \
      "ghost-cli@${GHOST_CLI_VERSION}"                            ;

RUN set -eux                                                      && \
# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
	cd "${GHOST_INSTALL}/current"                                   ; \
# scrape the expected version of sqlite3 directly from Ghost itself
	sqlite3Version="$(npm view . optionalDependencies.sqlite3)"     ; \
	if ! su-exec node yarn add "sqlite3@$sqlite3Version" --force; then            \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
		apk add --no-cache --virtual .build-deps python make gcc g++ libc-dev;      \
		\
		su-exec node yarn add "sqlite3@$sqlite3Version" --force --build-from-source ; \
		\
		apk del --no-network .build-deps                              ; \
	fi

# Final layer
### ### ### ### ### ### ### ### ###
FROM ghost-base AS ghost-final

COPY --from=ghost-builder --chown=node:node "${GHOST_INSTALL}" "${GHOST_INSTALL}"
COPY docker-entrypoint.sh /usr/local/bin
COPY Dockerfile /usr/local/bin
COPY README.md /usr/local/bin

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
EXPOSE 2368

# USER $GHOST_USER // bypassed as it causes all kinds of permission issues
# HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1 // bypassed as attributes are passed during runtime <docker service create>

ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]
