#!/bin/bash

# Unit test script which is also 
# easy to copy paste in your terminal
# Pascal Andy 2017-01-30

CTN_NAME=ghost-base
IMG_TEST=ghost:0.11.4
TEST_01="uname -a"
TEST_02="node --version"
TEST_03="npm show"
TEST_04="ls -AlhF /usr/src/ghost/content/themes"
\
echo; echo "Unit Test for image: <$IMG_TEST> - Start"; echo;
\
docker run -d \
--name $CTN_NAME \
$IMG_TEST; echo; sleep 0.1; \
echo "Container Started: $CTN_NAME"; echo; \
\
docker exec -it $CTN_NAME \
$TEST_01; echo; sleep 0.1; \
\
docker exec -it $CTN_NAME \
$TEST_02; echo; sleep 0.1; \
\
docker exec -it $CTN_NAME \
$TEST_03; echo; sleep 0.1; \
\
docker exec -it $CTN_NAME \
$TEST_04; echo; sleep 0.1; \
\
docker rm -f $CTN_NAME && \
echo "Container Removed: $CTN_NAME"; \
echo; sleep 0.1; \
\
docker ps; echo; \
\
echo; echo "Unit Test for image: <$IMG_TEST> - End"; echo;
