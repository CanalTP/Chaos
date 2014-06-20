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
from errors import errors_dict, ChaosException
from werkzeug.exceptions import BadRequest

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

    def get(self, id=None):
        try:
            if id:
                return marshal({'disruption': models.Disruption.get(id)},
                               one_disruption_fields)
            else:
                return marshal({'disruptions': models.Disruption.all()},
                           disruptions_fields)

        except exc.DataError as e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["id_not_exist"]}, 400
        except exc.DatabaseError as e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["database"]}, 400
        except Exception, e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["unknown"]}, 400

    def post(self):
        try:
            json = request.get_json()
            logging.getLogger(__name__).debug(json)
            validate(json, disruptions_input_format)
            disruption = models.Disruption()
            disruption.fill_from_json(json)
            db.session.add(disruption)
            db.session.commit()
        except BadRequest as e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["parse_json"]}, 400
        except ValidationError, e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["schema_json"]}, 400
        except Exception, e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["unknown"]}, 400

        return marshal({'disruption': disruption}, one_disruption_fields), 201

    def put(self, id):
        try:
            disruption = models.Disruption.get(id)
            json = request.get_json()
            logging.getLogger(__name__).debug(json)
            validate(json, disruptions_input_format)
            disruption.fill_from_json(json)
            db.session.commit()
        except exc.DataError as e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["id_not_exist"]}, 400
        except BadRequest as e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["parse_json"]}, 400
        except ValidationError, e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["schema_json"]}, 400
        except Exception, e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["unknown"]}, 400

        return marshal({'disruption': disruption}, one_disruption_fields), 200

    def delete(self, id):
        try:
            disruption = models.Disruption.get(id)
            disruption.archive()
            db.session.commit()
        except exc.DataError as e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["id_not_exist"]}, 400
        except Exception, e:
            logging.getLogger(__name__).error(str(e))
            return {"error": errors_dict["unknown"]}, 400

        return None, 204
