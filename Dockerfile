FROM node:0.10-slim

WORKDIR /usr/local/ghost

ENV GHOST_VERSION 0.5.8

RUN buildDeps=' \
		curl \
		ca-certificates \
		unzip \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -sSL "https://ghost.org/archives/ghost-${GHOST_VERSION}.zip" -o ghost.zip \
	&& unzip ghost.zip \
	&& rm ghost.zip && apt-get purge -y --auto-remove $buildDeps

RUN buildDeps=' \
		gcc \
		make \
		python \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& npm install --production \
	&& apt-get purge -y --auto-remove $buildDeps

RUN [ ! -e config.js ] \
	&& sed 's/127.0.0.1/0.0.0.0/g' config.example.js > config.js
EXPOSE 2368
CMD ["npm", "start"]
