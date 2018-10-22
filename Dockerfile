# Author: Pascal Andy | pascalandy.com/blog/now/
# Forked from https://github.com/docker-library/ghost/blob/2f6ac6c7770e428a4a50d23d46ec470d5e727456/1/alpine/Dockerfile
# https://docs.ghost.org/supported-node-versions/
# https://github.com/nodejs/LTS | FROM node:8.12.0-alpine | devmtl/node-alpine:8.11.4
#
# VAR TO UPDATE -> see lines: 8, 12, 13

FROM node:8.12.0-alpine

LABEL maintainer="Pascal Andy | pascalandy.com/blog/now"

ENV GHOST_VERSION="2.2.4"                       \
    GHOST_CLI_VERSION="1.9.6"                   \
    GHOST_INSTALL="/var/lib/ghost"              \
    GHOST_CONTENT="/var/lib/ghost/content"      \
    NODE_ENV="production"

RUN set -ex                                                     && \
    apk --update --no-cache add 'su-exec>=0.2'                     \
        bash curl tini ca-certificates                          && \
    update-ca-certificates                                      && \
    rm -rf /var/cache/apk/*;

RUN set -ex                                                     && \
    npm install --production -g "ghost-cli@$GHOST_CLI_VERSION"  && \
    \
    mkdir -p "$GHOST_INSTALL";                                  \
    chown node:node "$GHOST_INSTALL";                           \
    \
# Install Ghost
    su-exec node ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
    \
# Tell Ghost to listen on all ips and not prompt for additional configuration
    cd "$GHOST_INSTALL"; \
    su-exec node ghost config --ip 0.0.0.0 --port 2368 --no-prompt --db sqlite3 --url http://localhost:2368 --dbpath "$GHOST_CONTENT/data/ghost.db"; \
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
    \
# sanity check to ensure knex-migrator was installed
    "$GHOST_INSTALL/current/node_modules/knex-migrator/bin/knex-migrator" --version \
    \
# uninstall ghost-cli
    su-exec node npm uninstall -S -D -O -g "ghost-cli@$GHOST_CLI_VERSION";

# add knex-migrator bins into PATH
# we want these from the context of Ghost's "node_modules" directory (instead of doing "npm install -g knex-migrator") so they can share the DB driver modules
ENV PATH $PATH:$GHOST_INSTALL/current/node_modules/knex-migrator/bin

# TODO multiarch sqlite3 (once either "node:6-alpine" has multiarch or we switch to a base that does)

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]

EXPOSE 2368

# Healthcheck setting are made during docker service create (...)

CMD ["node", "current/index.js"]
