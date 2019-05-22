#!/usr/bin/env bash

# --- Best practices to manage errors ---
set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o nounset

###############################################################################
# Functions
###############################################################################

# --- VARS | Find the most recent Docker image here: https://hub.docker.com/r/devmtl/ghostfire/tags/
GHOSTFIRE_IMG="devmtl/ghostfire:stable"
CTN_NAME="ghostUAT"
WAIT_TIMER="3600"


echo; echo "--- Unit Test for image: <${GHOSTFIRE_IMG}> - Start ---"; \

# Remove Container (in case the image is already running)
echo; echo "--- Removing Container: $CTN_NAME ---"; \
docker rm -f $CTN_NAME || true; echo; echo;

# Start Container
echo; echo "--- Unit Test for image: <${GHOSTFIRE_IMG}> - START ---";

docker run -d \
--name "$CTN_NAME" \
-p 2368:2368 \
-e WEB_URL=http://localhost:2368 \
${GHOSTFIRE_IMG}; \

docker inspect $CTN_NAME; echo; echo;
docker logs $CTN_NAME; echo;

echo; echo "--- TEST 01 | uname -a ---"; \
docker exec -it $CTN_NAME \
uname -a; sleep 0.5; \

echo; echo "--- TEST 02 | node --version ---"; \
docker exec -it $CTN_NAME \
node --version; sleep 0.5; \

echo; echo "--- TEST 03 | Theme version (aka casper) ---"; \
docker exec -it $CTN_NAME \
cat /var/lib/ghost/current/content/themes/casper/package.json | grep version; sleep 0.5; \

echo; echo "--- TEST 04 | Ghost version ---"; \
docker exec -it $CTN_NAME \
cat /var/lib/ghost/current/package.json | grep version

echo; echo "--- TEST 05 | docker ps ---"; \
docker ps; sleep 2; echo;
docker ps; sleep 2; echo;
docker ps; sleep 2;

echo; echo "--- TEST 06 | Check HTTP/1.1 200 ---"; \
curl -Is --head "http://localhost:2368" | grep -F -o "HTTP/1.1 200 OK" || echo "Error --> http://localhost:2368"


echo; echo "--- Unit Test for image: <${GHOSTFIRE_IMG}> - END ---";


echo; echo "--- Will shutdown in $WAIT_TIMER secs ---";
sleep $WAIT_TIMER;
docker rm -f "$CTN_NAME";

# UAT (User Acceptance Testing)
# Easy to copy paste in your terminal
# Pascal Andy https://pascalandy.com/blog/now/ | 2018-12-22_14h35