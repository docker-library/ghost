#!/usr/bin/env bash

# .bashlava_env.sh, required by bashlava

# Dont update env_var within .bashlava_env.sh
# Create a new file: .bashlava_env_override.sh
# Override these env_var from .bashlava_env_override.sh
CFG_OVERRIDE_WITH_CUSTOM_CONFIG="false"
APP_NAME="ghostfire"
GITHUB_USER="firepress-org"
APP_VERSION="4.47.3"

### BRANCH NAMES
CFG_DEFAULT_BRANCH="master"
CFG_DEFAULT_DEV_BRANCH="edge"
CFG_USER_IS="${USER}"

### FUNCTION OPTIONS
CFG_EDGE_EXTENTED="false"   # #edge() not programmed yet.
CFG_LOG_LINE_NBR_SHORT="4"  # log() default line number.
CFG_LOG_LINE_NBR_LONG="12"  # log() default line number.

### SOURCE /components
#CFG_ARR_COMPONENTS_SCRIPTS
#CFG_ARR_DOCS_MARKDOWN

###	DOCKER IMAGES
DOCKER_IMG_FIGLET="devmtl/figlet:1.1"
DOCKER_IMG_GLOW="devmtl/glow:1.4.1"
