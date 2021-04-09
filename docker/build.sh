#!/bin/sh

# Script to build an app image.
# Two sections : FUNCTIONS are used in MAIN section


############################ FUNCTIONS ############################
askMissingParams()
{
    if [ -z "${REGISTRY_HOST}" ]; then read -p "REGISTRY_HOST: " REGISTRY_HOST; fi
    if [ -z "${VERSION}" ]; then read -p "VERSION: " VERSION; fi
}

validateParams()
{
    if [ -z "${REGISTRY_HOST}" ]; then echo "Environment variable \$REGISTRY_HOST is empty, please set it before running script" && exit 1; fi
    if [ -z "${VERSION}" ]; then echo "Environment variable \$VERSION is empty, please set it before running script" && exit 1; fi
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
    RABBITMQ_EXCHANGE="" \
    RABBITMQ_ENABLED="" \
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
