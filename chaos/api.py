# Copyright (c) 2001-2014, Canal TP and/or its affiliates. All rights reserved.
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

from chaos import resources
import flask_restful

from chaos import app

# we always want pretty json
flask_restful.representations.json.settings = {'indent': 4}

api = flask_restful.Api(app, catch_all_404s=True)
api.app.url_map.strict_slashes = False

api.add_resource(resources.Index,
                 '/',
                 endpoint='index')

api.add_resource(resources.DisruptionsSearch,
                 '/disruptions/_search',
                 endpoint='search')

api.add_resource(resources.Disruptions,
                 '/disruptions',
                 '/disruptions/<string:id>',
                 endpoint='disruption')

api.add_resource(resources.Severity,
                 '/severities',
                 '/severities/<string:id>',
                 endpoint='severity')

api.add_resource(resources.Cause,
                 '/causes',
                 '/causes/<string:id>',
                 endpoint='cause')

api.add_resource(resources.Category,
                 '/categories',
                 '/categories/<string:id>',
                 endpoint='category')

api.add_resource(resources.Tag,
                 '/tags',
                 '/tags/<string:id>',
                 endpoint='tag')

api.add_resource(resources.Impacts,
                 '/disruptions/<string:disruption_id>/impacts',
                 '/disruptions/<string:disruption_id>/impacts/<string:id>',
                 endpoint='impact')

api.add_resource(resources.ImpactsByObject,
                 '/impacts')

api.add_resource(resources.Channel,
                 '/channels',
                 '/channels/<string:id>',
                 endpoint='channel')

api.add_resource(resources.ChannelType,
                 '/channel_types')

api.add_resource(resources.Status,
                 '/status')

api.add_resource(resources.TrafficReport,
                 '/traffic_reports')

api.add_resource(resources.Property,
                 '/properties',
                 '/properties/<string:id>',
                 endpoint='property')


@app.errorhandler(Exception)
def error_handler(exception):
    """
    log all exceptions not catch before
    """
    app.logger.exception('')


if api.app.config.get('ACTIVATE_PROFILING'):
    api.app.logger.warning('=======================================================')
    api.app.logger.warning('activation of the profiling, all query will be slow !')
    api.app.logger.warning('=======================================================')
    from werkzeug.contrib.profiler import ProfilerMiddleware, MergeStream
    import sys

    api.app.config['PROFILE'] = True
    f = open('/tmp/profiler.log', 'a+')
    stream = MergeStream(sys.stdout, f)
    api.app.wsgi_app = ProfilerMiddleware(api.app.wsgi_app, stream, restrictions=[80], profile_dir='/tmp/profile', sort_by=('time', 'calls'))
