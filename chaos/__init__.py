# Copyright (c) Kisio Digital and/or its affiliates. All rights reserved.
#
# This file is part of Navitia,
#     the software to build cool stuff with public transport.
#
# Hope you'll enjoy and contribute to this project,
#     powered by Canal TP (www.canaltp.fr).
# Help us simplify mobility and open public transport:
#     a non ending quest to the responsive locomotion way of traveling!
#
# LICENCE: This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Stay tuned using
# twitter @navitia
# IRC #navitia on freenode
# https://groups.google.com/d/forum/navitia
# www.navitia.io

VERSION = 'v1.2.20-dev'

# http://bugs.python.org/issue7980
import datetime
datetime.datetime.strptime('', '')

# remplace blocking method by a non blocking equivalent
# this enable us to use gevent for launching background task
from gevent import monkey
monkey.patch_all(thread=False, subprocess=False, os=False, signal=False)

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import logging.config
import sys
from chaos.utils import Request
from chaos.publisher import Publisher
from flask_cache import Cache

app = Flask(__name__)
app.config.from_object('chaos.default_settings')
app.config.from_envvar('CHAOS_CONFIG_FILE')
app.request_class = Request


if 'LOGGER' in app.config:
    logging.config.dictConfig(app.config['LOGGER'])
else:  # Default is std out
    handler = logging.StreamHandler(stream=sys.stdout)
    app.logger.addHandler(handler)
    app.logger.setLevel('INFO')


db = SQLAlchemy(app)

publisher = Publisher(app.config['RABBITMQ_CONNECTION_STRING'], app.config['EXCHANGE'], app.config['ENABLE_RABBITMQ'])
cache = Cache(app, config=app.config['CACHE_CONFIGURATION'])

import chaos.api
