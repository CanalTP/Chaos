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

from flask import request, url_for, g, current_app
import flask_restful
from flask_restful import marshal, reqparse
from chaos import models, db, publisher
from jsonschema import validate, ValidationError
from flask.ext.restful import abort
from fields import *
from formats import *
from formats import impact_input_format, channel_input_format, pt_object_type_values,\
    tag_input_format
from chaos import mapper, exceptions
from chaos import utils
import chaos
from chaos.navitia import Navitia
from sqlalchemy.exc import IntegrityError


import logging
from utils import make_pager, option_value, get_client_code

__all__ = ['Disruptions', 'Index', 'Severity', 'Cause']


disruption_mapping = {
    'reference': None,
    'note': None,
    'publication_period': {
        'begin': mapper.Datetime(attribute='start_publication_date'),
        'end': mapper.Datetime(attribute='end_publication_date')
    },
    'cause': {'id': mapper.AliasText(attribute='cause_id')},
    'localization': [{"id": mapper.AliasText(attribute='localization_id')}]
}

severity_mapping = {
    'wording': None,
    'color': None,
    'priority': None,
    'effect': None,
}

cause_mapping = {
    'wording': None
}

tag_mapping = {
    'name': None
}

object_mapping = {
    "id": mapper.AliasText(attribute='uri'),
    "type": None
}

message_mapping = {
    "text": None,
    'channel': {'id': mapper.AliasText(attribute='channel_id')}
}

application_period_mapping = {
    'begin': mapper.Datetime(attribute='start_date'),
    'end': mapper.Datetime(attribute='end_date')
}

channel_mapping = {
    'name': None,
    'max_size': None,
    'content_type': None
}

line_section_mapping = {
    'line': None,
    'start_point': None,
    'end_point': None,
    'sens': None
}

class Index(flask_restful.Resource):

    def get(self):
        url = url_for('disruption', _external=True)
        response = {
            "disruptions": {"href": url},
            "disruption": {"href": url + '/{id}', "templated": True},
            "severities": {"href": url_for('severity', _external=True)},
            "causes": {"href": url_for('cause', _external=True)},
            "channels": {"href": url_for('channel', _external=True)},
            "impactsbyobject": {"href": url_for('impactsbyobject', _external=True)},
            "tags": {"href": url_for('tag', _external=True)},
            "status": {"href": url_for('status', _external=True)}


        }
        return response, 200


class Severity(flask_restful.Resource):

    def get(self, id=None):
        try:
            client_code = get_client_code(request)
        except exceptions.ClientAbsent, e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        client = models.Client.get_by_code(client_code)
        if not client:
            return marshal({'error': {'message': 'X-Customer-Id {} Not Found'.format(client_code)}},
                           error_fields), 400
        if id:
            if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                               error_fields), 400
            return marshal({'severity': models.Severity.get_by_client_id(id, client.id)}, one_severity_fields)
        else:
            response = {'severities': models.Severity.all(client.id), 'meta': {}}
            return marshal(response, severities_fields)

    def post(self):
        json = request.get_json()
        logging.getLogger(__name__).debug('Post severity: %s', json)
        try:
            client_code = get_client_code(request)
            validate(json, severity_input_format)
        except exceptions.ClientAbsent, e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        severity = models.Severity()
        mapper.fill_from_json(severity, json, severity_mapping)
        severity.client = models.Client.get_by_code(client_code)
        if not severity.client:
            severity.client = models.Client(client_code)
        db.session.add(severity)
        db.session.commit()
        return marshal({'severity': severity}, one_severity_fields), 201

    def put(self, id):
        try:
            client_code = get_client_code(request)
        except exceptions.ClientAbsent, e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        client = models.Client.get_by_code(client_code)
        if not client:
            return marshal({'error': {'message': 'X-Customer-Id {} Not Found'.format(client_code)}},
                           error_fields), 400

        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400

        severity = models.Severity.get_by_client_id(id, client.id)
        json = request.get_json()
        logging.getLogger(__name__).debug('PUT severity: %s', json)

        try:
            validate(json, severity_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(severity, json, severity_mapping)
        db.session.commit()
        return marshal({'severity': severity}, one_severity_fields), 200

    def delete(self, id):
        try:
            client_code = get_client_code(request)
        except exceptions.ClientAbsent, e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        client = models.Client.get_by_code(client_code)
        if not client:
            return marshal({'error': {'message': 'X-Customer-Id {} Not Found'.format(client_code)}},
                           error_fields), 404

        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        severity = models.Severity.get_by_client_id(id, client.id)
        severity.is_visible = False
        db.session.commit()
        return None, 204


class Disruptions(flask_restful.Resource):
    def __init__(self):
        self.navitia = Navitia(current_app.config['NAVITIA_URL'],
                               current_app.config['NAVITIA_COVERAGE'],
                               current_app.config['NAVITIA_TOKEN'])
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]

        parser_get.add_argument("start_page", type=int, default=1)
        parser_get.add_argument("items_per_page", type=int, default=20)
        parser_get.add_argument("publication_status[]",
                                type=option_value(publication_status_values),
                                action="append",
                                default=publication_status_values)
        parser_get.add_argument("tag[]",
                                type=utils.get_uuid,
                                action="append")
        parser_get.add_argument("current_time", type=utils.get_datetime)
        parser_get.add_argument("uri", type=str)

    def get(self, id=None):
        if id:
            if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                               error_fields), 400
            return marshal({'disruption': models.Disruption.get(id)},
                           one_disruption_fields)
        else:
            args = self.parsers['get'].parse_args()
            page_index = args['start_page']
            if page_index == 0:
                abort(400, message="page_index argument value is not valid")
            items_per_page = args['items_per_page']
            if items_per_page == 0:
                abort(400, message="items_per_page argument value is not valid")
            publication_status = args['publication_status[]']
            tags = args['tag[]']
            uri = args['uri']

            g.current_time = args['current_time']
            result = models.Disruption.all_with_filter(page_index=page_index,
                                                       items_per_page=items_per_page,
                                                       publication_status=publication_status,
                                                       tags=tags, uri=uri)
            response = {'disruptions': result.items, 'meta': make_pager(result, 'disruption')}
            return marshal(response, disruptions_fields)

    def post(self):
        json = request.get_json()
        logging.getLogger(__name__).debug('POST disruption: %s', json)
        try:
            validate(json, disruptions_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        disruption = models.Disruption()
        mapper.fill_from_json(disruption, json, disruption_mapping)

        #Add localization present in Json
        if 'localization' in json and json['localization']:
            if not self.navitia.get_pt_object(disruption.localization_id, json['localization'][0]["type"]):
                        return marshal({'error': {'message': 'ptobject {} doesn\'t exist'.format(disruption.localization_id)}},
                            error_fields), 404
        db.session.add(disruption)

        #Add all tags present in Json
        if 'tags' in json:
            for json_tag in json['tags']:
                    tag = models.Tag.get(json_tag['id'])
                    disruption.tags.append(tag)

        db.session.commit()
        chaos.utils.send_disruption_to_navitia(disruption)
        return marshal({'disruption': disruption}, one_disruption_fields), 201

    def put(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        disruption = models.Disruption.get(id)
        json = request.get_json()
        logging.getLogger(__name__).debug('PUT disruption: %s', json)

        try:
            validate(json, disruptions_input_format)
        except ValidationError, e:
            logging.getLogger(__name__).debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(disruption, json, disruption_mapping)

        #Add localization present in Json
        if 'localization' in json and json['localization']:
            if not self.navitia.get_pt_object(disruption.localization_id, json['localization'][0]["type"]):
                    return marshal({'error': {'message': 'ptobject {} doesn\'t exist'.format(disruption.localization_id)}},
                            error_fields), 404

        #Add/delete tags present/ not present in Json
        tags_db = dict((tag.id, tag) for tag in disruption.tags)
        tags_json = {}
        if 'tags' in json:
            tags_json = dict((tag["id"], tag) for tag in json['tags'])
            for tag_json in json['tags']:
                if tag_json["id"] not in tags_db:
                    tag = models.Tag.get(tag_json['id'])
                    disruption.tags.append(tag)
                    tags_db[tag_json['id']] = tag

        difference = set(tags_db) - set(tags_json)
        for diff in difference:
            tag = tags_db[diff]
            disruption.tags.remove(tag)

        db.session.commit()
        chaos.utils.send_disruption_to_navitia(disruption)
        return marshal({'disruption': disruption}, one_disruption_fields), 200

    def delete(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        disruption = models.Disruption.get(id)
        disruption.archive()
        db.session.commit()
        chaos.utils.send_disruption_to_navitia(disruption)
        return None, 204


class Cause(flask_restful.Resource):

    def get(self, id=None):
        if id:
            if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
            response = {'cause': models.Cause.get(id)}
            return marshal(response, one_cause_fields)
        else:
            response = {'causes': models.Cause.all(), 'meta': {}}
            return marshal(response, causes_fields)

    def post(self):
        json = request.get_json()
        logging.getLogger(__name__).debug('Post cause: %s', json)
        try:
            validate(json, cause_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        cause = models.Cause()
        mapper.fill_from_json(cause, json, cause_mapping)
        db.session.add(cause)
        db.session.commit()
        return marshal({'cause': cause}, one_cause_fields), 201

    def put(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                    error_fields), 400
        cause = models.Cause.get(id)
        json = request.get_json()
        logging.getLogger(__name__).debug('PUT cause: %s', json)

        try:
            validate(json, cause_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(cause, json, cause_mapping)
        db.session.commit()
        return marshal({'cause': cause}, one_cause_fields), 200

    def delete(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        cause = models.Cause.get(id)
        cause.is_visible = False
        db.session.commit()
        return None, 204


class Tag(flask_restful.Resource):

    def get(self, id=None):
        if id:
            if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
            response = {'tag': models.Tag.get(id)}
            return marshal(response, one_tag_fields)
        else:
            response = {'tags': models.Tag.all(), 'meta': {}}
            return marshal(response, tags_fields)

    def post(self):
        json = request.get_json()
        logging.getLogger(__name__).debug('Post tag: %s', json)
        try:
            validate(json, tag_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        tag = models.Tag()
        mapper.fill_from_json(tag, json, tag_mapping)
        db.session.add(tag)
        try:
            db.session.commit()
        except IntegrityError, e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        return marshal({'tag': tag}, one_tag_fields), 201

    def put(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                    error_fields), 400
        tag = models.Tag.get(id)
        json = request.get_json()
        logging.getLogger(__name__).debug('PUT tag: %s', json)

        try:
            validate(json, tag_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(tag, json, tag_mapping)
        try:
            db.session.commit()
        except IntegrityError, e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        return marshal({'tag': tag}, one_tag_fields), 200

    def delete(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        tag = models.Tag.get(id)
        tag.is_visible = False
        db.session.commit()
        return None, 204


class ImpactsByObject(flask_restful.Resource):
    def __init__(self):
        current_datetime = utils.get_current_time()
        default_start_date = current_datetime.replace(hour=0, minute=0, second=0)
        default_end_date = current_datetime.replace(hour=23, minute=59, second=59)
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]
        parser_get.add_argument("pt_object_type", type=option_value(pt_object_type_values))
        parser_get.add_argument("start_date", type=utils.get_datetime, default=default_start_date)
        parser_get.add_argument("end_date", type=utils.get_datetime, default=default_end_date)
        parser_get.add_argument("uri[]", type=str, action="append")
        self.navitia = Navitia(current_app.config['NAVITIA_URL'],
                               current_app.config['NAVITIA_COVERAGE'],
                               current_app.config['NAVITIA_TOKEN'])

    def get(self):
        args = self.parsers['get'].parse_args()
        pt_object_type = args['pt_object_type']
        start_date = args['start_date']
        end_date = args['end_date']
        uris = args['uri[]']

        if not pt_object_type and not uris:
                return marshal({'error': {'message': "object type or uri object invalid"}},
                               error_fields), 400
        impacts = models.Impact.all_with_filter(start_date, end_date, pt_object_type, uris)
        result = utils.group_impacts_by_pt_object(impacts, pt_object_type, uris, self.navitia.get_pt_object)
        return marshal({'objects': result}, impacts_by_object_fields)


class Impacts(flask_restful.Resource):
    def __init__(self):
        self.navitia = Navitia(current_app.config['NAVITIA_URL'],
                               current_app.config['NAVITIA_COVERAGE'],
                               current_app.config['NAVITIA_TOKEN'])
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]

        parser_get.add_argument("start_page", type=int, default=1)
        parser_get.add_argument("items_per_page", type=int, default=20)

    def fill_and_get_pt_object(self, all_objects, json, add_to_db=True):
        """
        :param all_objects: dictionary of objects to be added in this session
        :param json: Flux which contains json information of pt_object
        :param add_to_db: ptobject insert into database
        :return: a pt_object and modify all_objects param
        """

        if json["id"] in all_objects:
            return all_objects[json["id"]]

        pt_object = models.PTobject.get_pt_object_by_uri(json["id"])

        if pt_object:
            all_objects[json["id"]] = pt_object
            return pt_object

        if not self.navitia.get_pt_object(json['id'], json['type']):
            raise exceptions.ObjectUnknown()

        pt_object = models.PTobject()
        mapper.fill_from_json(pt_object, json, object_mapping)
        if add_to_db:
            db.session.add(pt_object)
        all_objects[json["id"]] = pt_object
        return pt_object

    def fill_and_add_line_section(self, impact_id, all_objects, pt_object_json):
        """
        :param impact_id: impact_id to construct uri of line_section object
        :param all_objects: dictionary of objects to be added in this session
        :param pt_object_json: Flux which contains json information of pt_object
        :return: pt_object and modify all_objects param
        """
        ptobject = models.PTobject()
        mapper.fill_from_json(ptobject, pt_object_json, object_mapping)
        ptobject.uri = ":".join((ptobject.uri, impact_id))

        #Here we treat all the objects in line_section like line, start_point, end_point
        line_section_json = pt_object_json['line_section']
        line_section = models.LineSection(ptobject.id)

        try:
            line_object = self.fill_and_get_pt_object(all_objects, line_section_json['line'])
        except exceptions.ObjectUnknown:
            raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(line_section_json['line']['type'], line_section_json['line']['id']))
        line_section.line = line_object

        try:
            start_object = self.fill_and_get_pt_object(all_objects, line_section_json['start_point'])
        except exceptions.ObjectUnknown:
            raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(line_section_json['line']['type'], line_section_json['line']['id']))
        line_section.start_point = start_object

        try:
            end_object = self.fill_and_get_pt_object(all_objects, line_section_json['end_point'])
        except exceptions.ObjectUnknown:
            raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(line_section_json['line']['type'], line_section_json['line']['id']))
        line_section.end_point = end_object

        #Here we manage routes in line_section
        #"routes":[{"id":"route:MTD:9", "type": "route"}, {"id":"route:MTD:Nav23", "type": "route"}]
        if 'routes' in line_section_json:
            for route in line_section_json["routes"]:
                try:
                    route_object = self.fill_and_get_pt_object(all_objects, route, True)
                    line_section.routes.append(route_object)
                except exceptions.ObjectUnknown:
                    raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(route['type'], route['id']))

        #Here we manage via in line_section
        #"via":[{"id":"stop_area:MTD:9", "type": "stop_area"}, {"id":"stop_area:MTD:Nav23", "type": "stop_area"}]
        if 'via' in line_section_json:
            for via in line_section_json["via"]:
                try:
                    via_object = self.fill_and_get_pt_object(all_objects, via, True)
                    line_section.via.append(via_object)
                except exceptions.ObjectUnknown:
                    raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(via['type'], via['id']))

        ptobject.insert_line_section(line_section)

        return ptobject

    def manage_message(self, impact, json):
        messages_db = dict((msg.channel_id, msg) for msg in impact.messages)
        messages_json = dict()
        if 'messages' in json:
            messages_json = dict((msg["channel"]["id"], msg) for msg in json['messages'])
            for message_json in json['messages']:
                if message_json["channel"]["id"] in messages_db:
                    msg = messages_db[message_json["channel"]["id"]]
                    mapper.fill_from_json(msg, message_json, message_mapping)
                else:
                    message = models.Message()
                    message.impact_id = impact.id
                    mapper.fill_from_json(message, message_json, message_mapping)
                    impact.insert_message(message)
                    messages_db[message.channel_id] = message

        difference = set(messages_db) - set(messages_json)
        for diff in difference:
            impact.delete_message(messages_db[diff])

    def manage_application_periods(self, impact, json):
        impact.delete_app_periods()
        if 'application_periods' in json:
            for app_period in json["application_periods"]:
                application_period = models.ApplicationPeriods(impact.id)
                mapper.fill_from_json(application_period, app_period, application_period_mapping)
                impact.insert_app_period(application_period)

    def get(self, disruption_id, id=None):
        if id:
            if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
            response = models.Impact.get(id)
            return marshal({'impact': response},
                           one_impact_fields)
        else:
            if not id_format.match(disruption_id):
                return marshal({'error': {'message': "disruption_id invalid"}},
                           error_fields), 400
            args = self.parsers['get'].parse_args()
            page_index = args['start_page']
            if page_index == 0:
                abort(400, message="page_index argument value is not valid")
            items_per_page = args['items_per_page']
            if items_per_page == 0:
                abort(400, message="items_per_page argument value is not valid")

            result = models.Impact.all(page_index=page_index,
                                       items_per_page=items_per_page,
                                       disruption_id=disruption_id)
            response = {'impacts': result.items, 'meta': make_pager(result, 'impact', disruption_id=disruption_id)}
            return marshal(response, impacts_fields)

    def post(self, disruption_id):

        if not id_format.match(disruption_id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400

        json = request.get_json()
        logging.getLogger(__name__).debug('POST impcat: %s', json)

        try:
            validate(json, impact_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        impact = models.Impact()
        impact.severity = models.Severity.get(json['severity']['id'])

        impact.disruption_id = disruption_id
        db.session.add(impact)

        #The ptobject is not added in the database before commit. If we have duplicate ptobject
        #in the json we have to handle it by using a dictionary. Each time we add a ptobject, we also
        #add it in the dictionary
        all_objects = dict()
        if 'objects' in json:
            for pt_object_json in json['objects']:
                if pt_object_json["type"] != 'line_section':
                    try:
                        ptobject = self.fill_and_get_pt_object(all_objects, pt_object_json, False)
                    except exceptions.ObjectUnknown:
                        return marshal({'error': {'message': '{} {} doesn\'t exist'.format(pt_object_json["type"], pt_object_json['id'])}},
                                error_fields), 404

                #For an pt_objects of the type 'line_section' we format uri : uri:impact_id
                # we insert this object in the table pt_object
                if pt_object_json["type"] == 'line_section':
                    try:
                        ptobject = self.fill_and_add_line_section(impact.id, all_objects, pt_object_json)
                    except exceptions.ObjectUnknown, e:
                        return marshal({'error': {'message': '{}'.format(e.message)}}, error_fields), 404

                impact.objects.append(ptobject)

        self.manage_application_periods(impact, json)
        self.manage_message(impact, json)
        db.session.commit()
        chaos.utils.send_disruption_to_navitia(models.Disruption.get(disruption_id))
        return marshal({'impact': impact}, one_impact_fields), 201

    def put(self, disruption_id, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        json = request.get_json()
        logging.getLogger(__name__).debug('PUT impact: %s', json)

        try:
            validate(json, impact_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        impact = models.Impact.get(id)

        #Fetch all the objects (except line_section) of impact in the database and insert code(uri) in the dictionary "pt_object_db".
        #For each object (except line_section) present in json but absent in pt_object_db, we add in database.
        #For each object (except line_section) present in the database but absent in json we delete in database.
        pt_object_db = dict()
        for ptobject in impact.objects:
            if ptobject.type != 'line_section':
                pt_object_db[ptobject.uri] = ptobject
        pt_object_dict = dict()
        if 'objects' in json:
            for pt_object_json in json['objects']:
                if pt_object_json["type"] != 'line_section':
                    try:
                        ptobject = self.fill_and_get_pt_object(pt_object_dict, pt_object_json, False)
                    except exceptions.ObjectUnknown:
                        return marshal({'error': {'message': '{} {} doesn\'t exist'.format(pt_object_json["type"], pt_object_json['id'])}},
                        error_fields), 404

                    if ptobject.uri not in pt_object_db:
                        impact.objects.append(ptobject)

            for ptobject_uri in pt_object_db:
                if ptobject_uri not in pt_object_dict:
                    impact.delete(pt_object_db[ptobject_uri])

            #For each object of type line_section we delete line_section, routes and via
            #Create a new line_section add add routes and via
            impact.delete_line_section()
            pt_object_dict = dict()
            for pt_object_json in json['objects']:
                if pt_object_json["type"] == 'line_section':
                    try:
                        ptobject = self.fill_and_add_line_section(impact.id, pt_object_dict, pt_object_json)
                    except exceptions.ObjectUnknown, e:
                        return marshal({'error': {'message': '{}'.format(e.message)}}, error_fields), 404

                    impact.objects.append(ptobject)
        # Severity
        severity_json = json['severity']
        if severity_json['id'] != impact.severity_id:
            impact.severity_id = severity_json['id']
            impact.severity = models.Severity.get(impact.severity_id)

        self.manage_application_periods(impact, json)
        self.manage_message(impact, json)
        db.session.commit()
        chaos.utils.send_disruption_to_navitia(models.Disruption.get(disruption_id))
        return marshal({'impact': impact}, one_impact_fields), 200

    def delete(self, disruption_id, id):
        if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                               error_fields), 400
        impact = models.Impact.get(id)
        impact.archive()
        db.session.commit()
        chaos.utils.send_disruption_to_navitia(models.Disruption.get(disruption_id))
        return None, 204

class Channel(flask_restful.Resource):

    def get(self, id=None):
        if id:
            if not id_format.match(id):
                return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
            response = {'channel': models.Channel.get(id)}
            return marshal(response, one_channel_fields)
        else:
            response = {'channels': models.Channel.all(), 'meta': {}}
            return marshal(response, channels_fields)

    def post(self):
        json = request.get_json()
        logging.getLogger(__name__).debug('Post channel: %s', json)
        try:
            validate(json, channel_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        channel = models.Channel()
        mapper.fill_from_json(channel, json, channel_mapping)
        db.session.add(channel)
        db.session.commit()
        return marshal({'channel': channel}, one_channel_fields), 201

    def put(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                    error_fields), 400
        channel = models.Channel.get(id)
        json = request.get_json()
        logging.getLogger(__name__).debug('PUT channel: %s', json)

        try:
            validate(json, channel_input_format)
        except ValidationError, e:
            logging.debug(str(e))
            #TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(channel, json, channel_mapping)
        db.session.commit()
        return marshal({'channel': channel}, one_channel_fields), 200

    def delete(self, id):
        if not id_format.match(id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400
        channel = models.Channel.get(id)
        channel.is_visible = False
        db.session.commit()
        return None, 204


class Status(flask_restful.Resource):
    def get(self):
        return {'version': chaos.VERSION,
                'db_pool_status': db.engine.pool.status(),
                'db_version': db.engine.scalar('select version_num from alembic_version;'),
                'navitia_url': current_app.config['NAVITIA_URL'],
                'rabbitmq_info': publisher.info()}
