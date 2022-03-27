# ----------------------------------------------
# At FirePress we run most things in Docker containers.
# These ARG are required during the Github Actions CI
# ----------------------------------------------
ARG APP_NAME="ghostfire"
ARG VERSION="4.41.3"
ARG RELEASE="4.41.3"
ARG GITHUB_USER="firepress-org"

ARG GIT_PROJECT_NAME="ghostfire"
ARG DOCKERHUB_USER="devmtl"
ARG GITHUB_ORG="firepress-org"
ARG GITHUB_REGISTRY="registry"

# ----------------------------------------------
# 1) Start your Dockerfile from here 
#   https://docs.ghost.org/faq/node-versions/
#   https://github.com/nodejs/Release (looking for "LTS")
#   https://github.com/TryGhost/Ghost/blob/v4.1.2/package.json#L38
# ----------------------------------------------
ARG GHOST_CLI_VERSION="1.19.0"
ARG NODE_VERSION="14-alpine3.14"
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
RUN set -eux                                                      &&\
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
  npm config list                                               ;

# force install "sqlite3" manually since it's an optional dependency of "ghost"
# (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
# see https://github.com/TryGhost/Ghost/pull/7677 for more details
RUN set -eux                                                      &&\
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
# 5) LAYER final
#   HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1
#   HEALTHCHECK attributes are passed during runtime <docker service create>
# ----------------------------------------------
FROM mynode AS final

COPY --chown="${USER}":"${USER}" docker-entrypoint.sh /usr/local/bin
COPY --from=builder --chown="${USER}":"${USER}" "${GHOST_INSTALL}" "${GHOST_INSTALL}"

WORKDIR "${GHOST_INSTALL}"
VOLUME "${GHOST_CONTENT}"
USER "${USER}"
EXPOSE 2368

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "node", "current/index.js" ]
