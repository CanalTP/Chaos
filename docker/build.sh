#!/bin/sh

# Description:
# Before to continuous keep in mind, there are two parts. FUNCTIONS and MAIN

############################ FUNCTIONS ############################
askMissingParams()
{
    if [ -z "${REGISTRY_HOST}" ]; then read -p "REGISTRY_HOST: " REGISTRY_HOST; fi
    if [ -z "${VERSION}" ]; then read -p "VERSION: " VERSION; fi
}

validateParams()
{
    if [ -z "${REGISTRY_HOST}" ]; then echo "Environment variable \$REGISTRY_HOST is empty, please set this before run build script" && exit 1; fi
    if [ -z "${VERSION}" ]; then echo "Environment variable \$VERSION is empty, please set this before run build script" && exit 1; fi
}

build()
{
    SQLALCHEMY_DATABASE_URI="" \
    DEBUG="" \
    NAVITIA_URL="" \
    NAVITIA_TIMEOUT="" \
    RABBITMQ_CONNECTION_STRING="" \
    CACHE_TYPE="" \
    CACHE_DEFAULT_TIMEOUT="" \
    NAVITIA_CACHE_TIMEOUT="" \
    NAVITIA_PUBDATE_CACHE_TIMEOUT="" \
    CACHE_REDIS_HOST="" \
    CACHE_REDIS_PORT="" \
    CACHE_REDIS_PASSWORD="" \
    CACHE_REDIS_DB="" \
    CACHE_KEY_PREFIX="" \
    EXCHANGE="" \
    ENABLE_RABBITMQ="" \
    PROFILING_ENABLED="" \
    IMPACT_EXPORT_DIR="" \
    IMPACT_EXPORT_PYTHON="" \
    NEW_RELIC_CONFIG_FILE="" \
    CACHE_CONFIGURATION="" \
    NEW_RELIC_CONFIG_FILE="" \
    REPLICAS_CHAOS_APACHE=2 \
    VERSION=${VERSION} \
    FLUENTD_ADDRESS=127.0.0.1 \
    ENV=prod \
    REGISTRY_HOST=${REGISTRY_HOST} \
    docker-compose build

}
###################################################################

############################## MAIN ###############################
askMissingParams
validateParams
build
###################################################################
