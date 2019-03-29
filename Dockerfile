#
# Forked from https://github.com/docker-library/ghost/blob/2f6ac6c7770e428a4a50d23d46ec470d5e727456/1/alpine/Dockerfile
# docs.ghost.org/faq/node-versions/ (Node v10 since 2.13.2) | https://github.com/nodejs/LTS
#
# UPDATE LINES -> 7, 9, 10, 13, 14

FROM node:10.15-alpine

LABEL com.ghost.version="2.19.1"                                \
      com.baseimage.version="node:10.15-alpine"                 \
      maintainer="Pascal Andy https://firepress.org/en/contact/"

ENV GHOST_VERSION="2.19.1"                                      \
    GHOST_CLI_VERSION="1.9.9"                                   \
    GHOST_INSTALL="/var/lib/ghost"                              \
    GHOST_CONTENT="/var/lib/ghost/content"                      \
    NODE_ENV="production"

RUN set -ex                                                     && \
    apk --update --no-cache add 'su-exec>=0.2'                  \
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

RUN set -eux; \
# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
  cd "$GHOST_INSTALL/current"; \
# scrape the expected version of sqlite3 directly from Ghost itself
  sqlite3Version="$(npm view . optionalDependencies.sqlite3)"; \
  if ! su-exec node yarn add "sqlite3@$sqlite3Version" --force; then \
# must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
    apk add --no-cache --virtual .build-deps python make gcc g++ libc-dev; \
    \
    su-exec node yarn add "sqlite3@$sqlite3Version" --force --build-from-source; \
    \
    apk del --no-network .build-deps; \
  fi

# add knex-migrator bins into PATH
# we want these from the context of Ghost's "node_modules" directory (instead of doing "npm install -g knex-migrator") so they can share the DB driver modules
ENV PATH $PATH:$GHOST_INSTALL/current/node_modules/knex-migrator/bin

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT
EXPOSE 2368

COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT [ "/sbin/tini", "--", "docker-entrypoint.sh" ]

# HEALTHCHECK / attributes are passed on runtime <docker service create>

CMD ["node", "current/index.js"]
