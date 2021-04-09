# Build & Deploy for Production

## Table of Contents
1. [Requirements](#1-requirements)
2. [Environment variables](#2-environment-variables)
3. [Build](#3-build-image)
4. [Deploy](#4-deploy)


## 1. Requirements

- [Traefik](https://docs.traefik.io/) in Swarm mode
- Docker attachable network `lb-common`
- [Fluentd](https://docs.fluentd.org/) for data log


## 2. Environment variables

| Name | Description | Example value |
| --- |--- | --- |
| SQLALCHEMY_DATABASE_URI | DB URI | postgresql://navitia:navitia@localhost/chaos |
| DEBUG | enable mode DEBUG | 0 |
| NAVITIA_URL | Navitia api to use | https://api.navitia.io |
| NAVITIA_TIMEOUT | Navitia request timeout in seconds | 1 |
| RABBITMQ_CONNECTION_STRING | RabbitMQ to use | pyamqp://guest:guest@localhost:5672//?heartbeat=60 |
| CACHE_TYPE | Type cache | redis |
| CACHE_DEFAULT_TIMEOUT | Default cache timeout | 86400 |
| NAVITIA_CACHE_TIMEOUT | Navitia cache timeout in seconds | 2 * 24 * 3600 |
| NAVITIA_PUBDATE_CACHE_TIMEOUT | Check Navitia publication date every 'n' seconds | 600 |
| CACHE_REDIS_HOST | Redis host | localhost |
| CACHE_REDIS_PORT | Redis port | 6379 |
| CACHE_REDIS_PASSWORD | Redis password | None |
| CACHE_REDIS_DB | Redis DB enabled  | 0 |
| CACHE_KEY_PREFIX | Cache key prefix | chaos |
| RABBITMQ_EXCHANGE | amqp exchange used to send disruptions | navitia |
| RABBITMQ_ENABLED | RabbitMQ enabled | 1 |
| PROFILING_ENABLED | Profiling enabled | 0 |
| IMPACT_EXPORT_DIR | Path to export files storage | /tmp |
| IMPACT_EXPORT_PYTHON | Python path (possible local config problems) |  |
| NEW_RELIC_CONFIG_FILE | NewRelic config file | newrelic.ini |
| CACHE_CONFIGURATION* | array of mandatory ENV VARS for cache configurations ENV VARS | { <br>'CACHE_TYPE': 'redis', <br>'CACHE_DEFAULT_TIMEOUT': ${CACHE_DEFAULT_TIMEOUT}, <br>'NAVITIA_CACHE_TIMEOUT': ${NAVITIA_CACHE_TIMEOUT}, <br>'NAVITIA_PUBDATE_CACHE_TIMEOUT': ${NAVITIA_PUBDATE_CACHE_TIMEOUT} <br>} |
| CACHE_CONFIGURATION* | if CACHE_TYPE is 'redis', array of mandatory ENV VARS for cache + redis configurations | { <br>'CACHE_TYPE': 'redis', <br>'CACHE_DEFAULT_TIMEOUT': ${CACHE_DEFAULT_TIMEOUT}, <br>'NAVITIA_CACHE_TIMEOUT': ${NAVITIA_CACHE_TIMEOUT}, <br>'NAVITIA_PUBDATE_CACHE_TIMEOUT': ${NAVITIA_PUBDATE_CACHE_TIMEOUT}, <br>'CACHE_REDIS_HOST' : ${CACHE_REDIS_HOST}, <br> 'CACHE_REDIS_PORT' : ${CACHE_REDIS_PORT}, <br>'CACHE_REDIS_PASSWORD' : ${CACHE_REDIS_PASSWORD}, <br>'CACHE_REDIS_DB' : ${CACHE_REDIS_DB}, <br>'CACHE_KEY_PREFIX' : ${CACHE_KEY_PREFIX} <br>} |
| VERSION | Application version | 1.0.42 |
| ENV | Environment to be deployed | internal |
| FLUENTD_ADDRESS | URL of fluentd | localhost:24224 |
| REGISTRY_HOST | Docker registry host for app images | localhost |

\* CACHE_CONFIGURATION : one definition only. Content is related to your CACHE_TYPE choice

For more information about cache configurations, see https://pythonhosted.org/Flask-Cache/

## 3. Build image

### Automated method

A [Makefile](../Makefile) is dedicated to this.

If undefined you will be asked to set some environment variables.

    make build_prod_env

### Manual method

    git submodule init
    git submodule update
    
    REGISTRY_HOST=localhost VERSION=1.0.42 ./docker/build.sh



## 4. Deploy

Use the deployment technique of you choice to use your freshly generated app image.

If with Jenkins, we recommend [Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/) usage.