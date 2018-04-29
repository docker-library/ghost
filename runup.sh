#!/usr/bin/env bash
set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o nounset
###############################################################################
# Functions
###############################################################################

CTN_NAME="ghostUAT"

# Is defined during the in fct_builder (around line 3344)
source /Users/p_andy/deploy-setup/_dockerfile/ghostfire/build-config.sh .
IMG_TO_TEST="$ENV_GHOST_IMG_VERSION"

echo; echo "--- Unit Test for image: <$IMG_TO_TEST> - Start ---"; \

# Remove Container (in case the image is already running)
echo; echo "--- Removing Container: $CTN_NAME ---"; \
docker rm -f $CTN_NAME || true; echo; echo;

# Start Container
echo; echo "--- Unit Test for image: <$IMG_TO_TEST> - START ---";

docker run -d \
--name "$CTN_NAME" \
-p 2368:2368 \
-e WEB_URL=http://localhost:2368 \
"$IMG_TO_TEST"; \

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


echo; echo "--- Unit Test for image: <$IMG_TO_TEST> - END ---";


WAIT_FOR=1
echo; echo "--- Will shutdown in $WAIT_FOR secs ---";
sleep $WAIT_FOR;
docker rm -f "$CTN_NAME";

# UAT (User Acceptance Testing)
# Easy to copy paste in your terminal
# By Pascal Andy @askpascalandy 2017-11-15_14h52