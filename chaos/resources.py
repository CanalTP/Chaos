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

from flask import current_app, request, url_for
import flask_restful
from flask_restful import fields, marshal_with, marshal, reqparse, types
from sqlalchemy import exc

from chaos import models, db
from jsonschema import validate, ValidationError
import logging
import errors

__all__ = ['Disruptions']


class FieldDateTime(fields.Raw):
    def format(self, value):
        if value:
            return value.strftime('%Y-%m-%dT%H:%M:%SZ')
        else:
            return 'null'


disruption_fields = {'id': fields.Raw,
                     'self': {'href': fields.Url('disruption', absolute=True)},
                     'reference': fields.Raw,
                     'note': fields.Raw,
                     'status': fields.Raw,
                     'created_at': FieldDateTime,
                     'updated_at': FieldDateTime,
                     }


disruptions_fields = {'disruptions': fields.List(fields.Nested(disruption_fields))
                     }

one_disruption_fields = {'disruption': fields.Nested(disruption_fields)
                     }

error_field = {'id': fields.String(),
                'message': fields.String()}
error_fields = {'error': error_field}

#see http://json-schema.org/
disruptions_input_format = {'type': 'object',
                            'properties': {'reference': {'type': 'string', 'maxLength': 250},
                                           'note': {'type': 'string'}
                            },
                            'required': ['reference']
        }

class Index(flask_restful.Resource):

    def get(self):
        url = url_for('disruption', _external=True)
        response = {
            "disruptions": {"href": url},
            "disruption": {"href": url + '/{id}', "templated": True}
        }
        return response, 200

class Disruptions(flask_restful.Resource):
    def __init__(self):
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser(
            argument_class=argument.ArgumentDoc)
        parser_get = self.parsers["get"]
        parser_get.add_argument("start_index", type=int, default=1)
        parser_get.add_argument("items_per_page", type=int, default=20)

    def get_value(self, args, param, default):
        if param in args:
            return args[param]
        else:
            return default

    def paginate(self, result, response):

        prev = None
        next = None
        if result.has_prev:
            prev = url_for('disruption',
                           start_index=result.prev_num,
                           items_per_page=result.per_page,
                           _external=True)

        if result.has_next:
            next = url_for('disruption',
                           start_index=result.next_num,
                           items_per_page=result.per_page,
                           _external=True)

        last = url_for('disruption',
                       start_index=result.pages,
                       items_per_page=result.per_page,
                       _external=True)

        first = url_for('disruption',
                        start_index=1,
                        items_per_page=result.per_page,
                        _external=True)

        response["meta"] = {
            "pagination":{
            "start_index": result.page,
            "items_per_page": result.per_page,
            "total_results": result.total,
            "prev": {"href": prev},
            "next": {"href": next},
            "first": {"href": first},
            "last": {"href": last}
            }
        }
        return response

    def get(self, id=None):
        if id:
            return marshal({'disruption': models.Disruption.get(id)},
                           one_disruption_fields)
        else:
            args = self.parsers['get'].parse_args()
            page_index = self.get_value(args, 'start_index', 1)
            if page_index == 0:
                return {"error": errors.get_message(errors.Error_Enum.page_index)}, 400

            items_per_page = self.get_value(args, 'items_per_page', 20)
            if items_per_page == 0:
                return {"error": errors.get_message(errors.Error_Enum.items_per_page)}, 400

            result = models.Disruption.paginate(page_index, items_per_page)
            response = marshal({'disruptions': result.items},
                            disruptions_fields)

            return self.paginate(result, response)

    def post(self):
        try:
            json = request.get_json()
        except Exception as e:
            return {"error": errors.get_message(errors.Error_Enum.parse_json)}, 400

        logging.getLogger(__name__).debug(json)
        try:
            validate(json, disruptions_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            return {"error": errors.get_message(errors.Error_Enum.schema_json)}, 400

        disruption = models.Disruption()
        disruption.fill_from_json(json)
        db.session.add(disruption)
        db.session.commit()
        return marshal({'disruption': disruption}, one_disruption_fields), 201


    def put(self, id):
        try:
            disruption = models.Disruption.get(id)
        except exc.DataError as e:
            return {"error": errors.get_message(errors.Error_Enum.id_not_exist)}, 400

        try:
            json = request.get_json()
        except Exception as e:
            return {"error": errors.get_message(errors.Error_Enum.parse_json)}, 400
        logging.getLogger(__name__).debug(json)

        try:
            validate(json, disruptions_input_format)
        except ValidationError, e:
            logging.getLogger(__name__).debug(str(e))
            return {"error": errors.get_message(errors.Error_Enum.schema_json)}, 400

        disruption.fill_from_json(json)
        db.session.commit()
        return marshal({'disruption': disruption}, one_disruption_fields), 200

    def delete(self, id):
        disruption = models.Disruption.get(id)
        disruption.archive()
        db.session.commit()
        return None, 204
