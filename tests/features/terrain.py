from lettuce import *
import chaos
import logging
import json
import os

import flask_migrate
from flask_migrate import Migrate
migrate = Migrate(chaos.app, chaos.db)

migration_dir = 'migrations' if os.path.isdir('migrations') else '../migrations'


@before.all
def setup_db():
    logging.getLogger('alembic').setLevel(logging.ERROR)
    with chaos.app.app_context():
        flask_migrate.upgrade(directory=migration_dir)


@before.each_scenario
def setup_tester(scenario):
    world.client = chaos.app.test_client()
    world.headers = {}
    world.headers['content-type'] = 'application/json'

@after.all
def teardown_db(total):
    with chaos.app.app_context():
        flask_migrate.downgrade(revision='base', directory=migration_dir)


@after.each_scenario
def truncate_db(scenario):
    with chaos.app.app_context():
        tables = [str(table) for table in chaos.db.metadata.sorted_tables]
        chaos.db.session.execute('TRUNCATE {} CASCADE;'.format(', '.join(tables)))
        chaos.db.session.commit()


@before.each_step
def retrieve_json_response(step):
    if hasattr(world, 'response'):
        try:
            world.response_json = json.loads(world.response.get_data())
        except ValueError:
            pass
