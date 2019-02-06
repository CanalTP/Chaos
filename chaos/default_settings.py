import os
# URI for postgresql
# postgresql://<user>:<password>@<host>:<port>/<dbname>
# http://docs.sqlalchemy.org/en/rel_0_9/dialects/postgresql.html#psycopg2
SQLALCHEMY_DATABASE_URI = str(os.getenv('SQLALCHEMY_DATABASE_URI', 'postgresql://navitia:navitia@localhost/chaos'))

DEBUG = (os.getenv('DEBUG', 1) == 1)

NAVITIA_URL = str(os.getenv('NAVITIA_URL', 'http://navitia2-ws.ctp.dev.canaltp.fr'))
NAVITIA_TIMEOUT = os.getenv('NAVITIA_TIMEOUT', 1)

# rabbitmq connections string: http://kombu.readthedocs.org/en/latest/userguide/connections.html#urls
RABBITMQ_CONNECTION_STRING = str(
    os.getenv(
        'RABBITMQ_CONNECTION_STRING',
        'pyamqp://guest:guest@localhost:5672//?heartbeat=60'))

# Cache configuration, see https://pythonhosted.org/Flask-Cache/ for more information
cache_type = str(os.getenv('CACHE_TYPE', 'simple'))
CACHE_CONFIGURATION = {
    'CACHE_TYPE': cache_type,
    'CACHE_DEFAULT_TIMEOUT': os.getenv('CACHE_DEFAULT_TIMEOUT', 86400),  # in seconds
    'NAVITIA_CACHE_TIMEOUT': os.getenv('NAVITIA_CACHE_TIMEOUT', 2 * 24 * 3600),  # in seconds
    'NAVITIA_PUBDATE_CACHE_TIMEOUT': os.getenv('NAVITIA_PUBDATE_CACHE_TIMEOUT', 600),  # in seconds
}

if cache_type == 'redis':
    CACHE_CONFIGURATION['CACHE_REDIS_HOST'] = str(os.getenv('CACHE_REDIS_HOST', 'localhost'))
    CACHE_CONFIGURATION['CACHE_REDIS_PORT'] = os.getenv('CACHE_REDIS_PORT', 6379)
    CACHE_CONFIGURATION['CACHE_REDIS_PASSWORD'] = os.getenv('CACHE_REDIS_PASSWORD', None)
    CACHE_CONFIGURATION['CACHE_REDIS_DB'] = os.getenv('CACHE_REDIS_DB', 0)
    CACHE_CONFIGURATION['CACHE_KEY_PREFIX'] = 'Chaos'

# amqp exchange used for sending disruptions
EXCHANGE = str(os.getenv('RABBITMQ_EXCHANGE', 'navitia'))

ENABLE_RABBITMQ = (os.getenv('RABBITMQ_ENABLED', 1) == 1)

ACTIVATE_PROFILING = (os.getenv('PROFILING_ENABLED', 0) == 1)

# config newrelic
NEW_RELIC_ENVIRONMENT = 'development'
NEW_RELIC_CONFIG_FILE = 'newrelic.ini'

# Log Level available
# - DEBUG
# - INFO
# - WARN
# - ERROR

# logger configuration

from chaos.logging_utils import ChaosFilter

LOGGER = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'default': {
            'format': '[%(asctime)s] [%(request_id)s] [%(levelname)5s] [%(process)5s] [%(name)25s] %(message)s',
        },
    },
    'filters': {
        'ChaosFilter': {
            '()': ChaosFilter,
        }
    },
    'handlers': {
        'default': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'default',
            'filters': ['ChaosFilter'],
        },
    },
    'loggers': {
        '': {
            'handlers': ['default'],
            'level': 'DEBUG',
        },
        'sqlalchemy.engine': {
            'handlers': ['default'],
            'level': 'WARN',
            'propagate': False
        },
        'sqlalchemy.pool': {
            'handlers': ['default'],
            'level': 'WARN',
            'propagate': False
        },
        'sqlalchemy.dialects.postgresql': {
            'handlers': ['default'],
            'level': 'WARN',
            'propagate': False
        },
    }
}
