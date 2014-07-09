#URI for postgresql
# postgresql://<user>:<password>@<host>:<port>/<dbname>
#http://docs.sqlalchemy.org/en/rel_0_9/dialects/postgresql.html#psycopg2
SQLALCHEMY_DATABASE_URI = 'postgresql://navitia:navitia@localhost/chaos_testing'
JORMUNGANDR_URL = 'http://par-vm196.srv.canaltp.fr'
JORMUNGANDR_TOKEN = None
COVERAGE = 'jdr'

DEBUG = True

#Log Level available
# - DEBUG
# - INFO
# - WARN
# - ERROR

# logger configuration
LOGGER = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters':{
        'default': {
            'format': '[%(asctime)s] [%(levelname)5s] [%(process)5s] [%(name)25s] %(message)s',
        },
    },
    'handlers': {
        'default': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'default',
        },
    },
    'loggers': {
        '': {
            'handlers': ['default'],
            'level': 'DEBUG',
        },
        'celery':{
            'level': 'INFO',
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
        'alembic.migration': {
            'handlers': ['default'],
            'level': 'WARN',
            'propagate': False
        },
    }
}
