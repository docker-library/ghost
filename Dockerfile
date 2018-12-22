#
# Forked from https://github.com/docker-library/ghost/blob/2f6ac6c7770e428a4a50d23d46ec470d5e727456/1/alpine/Dockerfile
# https://docs.ghost.org/supported-node-versions/ | https://github.com/nodejs/LTS
#
# VAR TO UPDATE -> lines: 7, 11, 12 

FROM node:10.14-alpine

LABEL maintainer="Pascal Andy | https://pascalandy.com/"

ENV GHOST_VERSION="2.9.1"                       \
    GHOST_CLI_VERSION="1.9.8"                   \
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
# install Ghost / optional: --verbose
    su-exec node ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
    \
# tell Ghost to listen on all ips and not prompt for additional configuration
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
# uninstall ghost-cli / Let's save a few bytes
    su-exec node npm uninstall -S -D -O -g "ghost-cli@$GHOST_CLI_VERSION";

# add knex-migrator bins into PATH
# we want these from the context of Ghost's "node_modules" directory (instead of doing "npm install -g knex-migrator") so they can share the DB driver modules
ENV PATH $PATH:$GHOST_INSTALL/current/node_modules/knex-migrator/bin

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT
EXPOSE 2368

COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]

# HEALTHCHECK, attributes are passed when > docker service create

CMD ["node", "current/index.js"]
