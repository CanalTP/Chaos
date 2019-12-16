# Copyright (c) since 2001, Kisio Digital and/or its affiliates. All rights reserved.

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

api.add_resource(resources.ImpactsSearch,
                 '/impacts/_search',
                 endpoint='impacts_search')

api.add_resource(resources.DisruptionsHistory,
                 '/disruptions/<string:disruption_id>/history',
                 endpoint='disruption_history')

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

api.add_resource(resources.ImpactsExports,
                 '/impacts/exports',
                 '/impacts/exports/<string:id>',
                 endpoint='impacts_exports')

api.add_resource(resources.ImpactsExportDownload,
                 '/impacts/exports/<string:id>/download',
                 endpoint='impacts_exports_donwload')

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

api.add_resource(resources.Contributor,
                 '/contributors',
                 endpoint='contributor')

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
    from werkzeug.contrib.profiler import ProfilerMiddleware
    api.app.config['PROFILE'] = True
    f = open('/tmp/profiler.log', 'a+')
    api.app.wsgi_app = ProfilerMiddleware(api.app.wsgi_app, f, restrictions=[80], profile_dir='/tmp/profile')
