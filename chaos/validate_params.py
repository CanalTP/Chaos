# Copyright (c) 2001-2014, Canal TP and/or its affiliates. All rights reserved.
#
# This file is part of Navitia,
#     the software to build cool stuff with public transport.
#
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


from functools import wraps
from chaos.navitia import Navitia
from utils import get_client_code, get_contributor_code, get_token, \
    get_coverage, get_clients_tokens, client_token_is_allowed
from chaos import exceptions, models, utils, fields
from flask_restful import marshal
from flask import request, current_app
from formats import id_format
from os import path


class validate_client(object):
    def __init__(self, create_client=False):
        self.create_client = create_client

    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                client_code = get_client_code(request)
            except exceptions.HeaderAbsent as e:
                return marshal({'error': {'message': utils.parse_error(e)}},
                               fields.error_fields), 400
            if self.create_client:
                client = models.Client.get_or_create(client_code)
            else:
                client = models.Client.get_by_code(client_code)
            if not client:
                return marshal(
                    {'error': {'message': 'X-Customer-Id {} Not Found'.format(client_code)}},
                    fields.error_fields
                ), 404
            return func(*args, client=client, **kwargs)
        return wrapper


class validate_contributor(object):
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                contributor_code = get_contributor_code(request)
            except exceptions.HeaderAbsent as e:
                return marshal({'error': {'message': utils.parse_error(e)}},
                               fields.error_fields), 400
            contributor = models.Contributor.get_by_code(contributor_code)
            if not contributor:
                return marshal(
                    {'error': {'message': 'X-Contributors {} Not Found'.format(contributor_code)}},
                    fields.error_fields
                ), 404
            return func(*args, contributor=contributor, **kwargs)
        return wrapper


class validate_navitia(object):
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                coverage = get_coverage(request)
                token = get_token(request)
            except exceptions.HeaderAbsent as e:
                return marshal(
                    {'error': {'message': utils.parse_error(e)}},
                    fields.error_fields
                ), 400
            nav = Navitia(current_app.config['NAVITIA_URL'], coverage, token)
            return func(*args, navitia=nav, **kwargs)
        return wrapper


class manage_navitia_error(object):
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except exceptions.NavitiaError as e:
                return marshal(
                    {'error': {'message': '{}'.format(e.message)}},
                    fields.error_fields
                ), 503
        return wrapper


class validate_id(object):
    def __init__(self, required=False):
        self.required = required

    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            resp = marshal(
                {'error': {'message': "id invalid"}},
                fields.error_fields
            ), 400

            if self.required and ('id' not in kwargs):
                return resp

            if 'id' in kwargs:
                if not id_format.match(kwargs['id']):
                    return resp

            return func(*args, **kwargs)
        return wrapper


class validate_client_token(object):
    def __init__(self, file_name='clients_tokens.json'):

        current_dir_path = path.dirname(path.realpath(__file__))
        file_path = path.join(current_dir_path, file_name)

        self.clients_tokens = get_clients_tokens(file_path)

    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                token = get_token(request)
                client_code = get_client_code(request)
                client_token_is_allowed(self.clients_tokens, client_code, token)
            except (exceptions.HeaderAbsent, exceptions.Unauthorized) as e:
                return marshal(
                    {'error': {'message': utils.parse_error(e)}},
                    fields.error_fields
                ), 401
            return func(*args, **kwargs)
        return wrapper

class validate_send_notifications_and_notification_date(object):
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            json = request.get_json(silent=True)
            impacts = []
            if json and 'impacts' in json:
                impacts = json['impacts']
            elif json and 'send_notifications' in json:
                impacts = [json]
            for impact in impacts:
                if ('send_notifications' in impact) and impact['send_notifications'] and \
                ('notification_date' in impact and impact['notification_date'] is None):
                    return marshal(
                        {'error': {'message': "notification_date should not be empty if send_notifications is true"}},
                        fields.error_fields
                    ), 400
            return func(*args, **kwargs)
        return wrapper


# To override the default validator message "[] is too short"
class validate_impact_lists(object):
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            json = request.get_json(silent=True)
            impacts = []

            # in disruption
            if json and 'impacts' in json:  # json is disruption
                impacts = json['impacts']
                if not impacts:
                    return marshal(
                        {'error': {'message': "impacts should not be empty"}},
                        fields.error_fields
                    ), 400
            elif json and 'severity' in json:  # json is impact
                impacts = [json]

            # in each impact
            required_arrays_for_impact = ['objects', 'application_periods', 'application_period_patterns']
            for impact in impacts:
                for required_array in required_arrays_for_impact:  # type: str
                    if (required_array in impact) and not impact[required_array]:
                        return marshal(
                            {'error': {'message': "{} should not be empty".format(required_array)}},
                            fields.error_fields
                        ), 400

            return func(*args, **kwargs)
        return wrapper
