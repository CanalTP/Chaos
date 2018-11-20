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

from flask import g, request
import flask_restful
from flask_restful import marshal, reqparse, types
from chaos import models, db, publisher
from jsonschema import validate, ValidationError
from flask.ext.restful import abort
from fields import *
from formats import *
from formats import impact_input_format, channel_input_format, pt_object_type_values,\
    tag_input_format, category_input_format, channel_type_values,\
    property_input_format, disruptions_search_input_format, application_status_values
from chaos import mapper, exceptions
from chaos import utils, db_helper
import chaos
import json
from sqlalchemy.exc import IntegrityError
import logging
from utils import make_pager, option_value
from chaos.validate_params import validate_client, validate_contributor, validate_navitia, \
    manage_navitia_error, validate_id, validate_client_token

__all__ = ['Disruptions', 'Index', 'Severity', 'Cause']


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
            "categories": {"href": url_for('category', _external=True)},
            "channeltypes": {"href": url_for('channeltype', _external=True)},
            "status": {"href": url_for('status', _external=True)},
            "traffic_reports": {"href": url_for('trafficreport', _external=True)},
            "properties": {"href": url_for('property', _external=True)}
        }
        return response, 200


class Severity(flask_restful.Resource):

    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        if id:
            try:
                severity = models.Severity.get(id, client.id)
            except exceptions.ObjectUnknown as e:
                return marshal({'error': {'message': utils.parse_error(e)}},
                               error_fields), 404
            return marshal({'severity': severity}, one_severity_fields)
        else:
            response = {'severities': models.Severity.all(client.id), 'meta': {}}
            return marshal(response, severities_fields)

    @validate_client(True)
    @validate_client_token()
    def post(self, client):
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('Post severity: %s', json)
        try:
            validate(json, severity_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        severity = models.Severity()
        mapper.fill_from_json(severity, json, mapper.severity_mapping)
        severity.client = client
        try:
            db_helper.manage_wordings(severity, json)
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        db.session.add(severity)
        db.session.commit()
        db.session.refresh(severity)
        return marshal({'severity': severity}, one_severity_fields), 201

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, id):

        try:
            severity = models.Severity.get(id, client.id)
        except exceptions.ObjectUnknown as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 404
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT severity: %s', json)

        try:
            validate(json, severity_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(severity, json, mapper.severity_mapping)
        try:
            db_helper.manage_wordings(severity, json)
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        db.session.commit()
        db.session.refresh(severity)
        return marshal({'severity': severity}, one_severity_fields), 200

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, id):

        try:
            severity = models.Severity.get(id, client.id)
        except exceptions.ObjectUnknown as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 404
        severity.is_visible = False
        db.session.commit()
        return None, 204


class Disruptions(flask_restful.Resource):
    def __init__(self):
        self.navitia = None
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]

        parser_get.add_argument("start_page", type=int, default=1)
        parser_get.add_argument("items_per_page", type=int, default=20)
        parser_get.add_argument("publication_status[]",
                                type=option_value(publication_status_values),
                                action="append",
                                default=publication_status_values)
        parser_get.add_argument("ends_after_date", type=utils.get_datetime),
        parser_get.add_argument("ends_before_date", type=utils.get_datetime),
        parser_get.add_argument("tag[]",
                                type=utils.get_uuid,
                                action="append")
        parser_get.add_argument("current_time", type=utils.get_datetime)
        parser_get.add_argument("uri", type=str)
        parser_get.add_argument("line_section", type=types.boolean, default=False)
        parser_get.add_argument(
            "status[]",
            type=option_value(disruption_status_values),
            action="append",
            default=disruption_status_values
        )
        parser_get.add_argument("depth", type=int, default=1)

    @validate_navitia()
    @validate_contributor()
    @manage_navitia_error()
    @validate_id()
    @validate_client_token()
    def get(self, contributor, navitia, id=None):
        self.navitia = navitia
        args = self.parsers['get'].parse_args()
        depth = args['depth']
        g.display_impacts = depth > 1

        if id:
            return self._get_disruption_by_id(id, contributor.id)
        else:
            return self._get_disruptions(contributor.id, args)

    def _get_disruption_by_id(self, id, contributor_id):
        return marshal(
            {'disruption': models.Disruption.get(id, contributor_id)},
            one_disruption_fields
        )

    def _get_disruptions(self, contributor_id, args):

        self._validate_arguments_for_disruption_list(args)
        g.current_time = args['current_time']
        page_index = args['start_page']
        items_per_page = args['items_per_page']
        publication_status = args['publication_status[]']
        ends_after_date = args['ends_after_date']
        ends_before_date = args['ends_before_date']
        tags = args['tag[]']
        uri = args['uri']
        line_section = args['line_section']
        statuses = args['status[]']

        result = models.Disruption.all_with_filter(
            page_index=page_index,
            items_per_page=items_per_page,
            contributor_id=contributor_id,
            publication_status=publication_status,
            ends_after_date=ends_after_date,
            ends_before_date=ends_before_date,
            tags=tags,
            uri=uri,
            line_section=line_section,
            statuses=statuses
        )

        response = {'disruptions': result.items, 'meta': make_pager(result, 'disruption')}

        '''
        The purpose is to remove any database-loaded state from all current objects so that the next access of
        any attribute, or any query execution, will retrieve new state, freshening those objects which are still
        referenced outside of the session with the most recent available state.
        '''
        for o in result.items:
            models.db.session.expunge(o)
        return marshal(response, disruptions_fields)

    def _validate_arguments_for_disruption_list(self, args):
        if args['start_page'] == 0:
            abort(400, message="page_index argument value is not valid")

        if args['items_per_page'] == 0:
            abort(400, message="items_per_page argument value is not valid")

    def get_post_error_response_and_log(self, exception, status_code):
        return self.get_error_response_and_log('POST', exception, status_code)

    def get_put_error_response_and_log(self, exception, status_code):
        return self.get_error_response_and_log('PUT', exception, status_code)

    def get_error_response_and_log(self, method, exception, status_code):
        response_content = marshal({'error': {'message': '{}'.format(exception.message)}}, error_fields)
        logging.getLogger(__name__).debug(
            "\nError REQUEST %s disruption: [X-Customer-Id:%s;X-Coverage:%s;X-Contributors:%s;Authorization:%s] with payload \n%s" +
            "\ngot RESPONSE with status %d:\n%s",
            method,
            request.headers.get('X-Customer-Id'),
            request.headers.get('X-Coverage'),
            request.headers.get('X-Contributors'),
            request.headers.get('Authorization'),
            json.dumps(
                request.get_json(
                    silent=True)),
            status_code,
            json.dumps(response_content))
        return response_content

    @validate_navitia()
    @validate_client(True)
    @manage_navitia_error()
    @validate_client_token()
    def post(self, client, navitia):
        self.navitia = navitia
        json = request.get_json(silent=True)

        try:
            validate(json, disruptions_input_format)
        except ValidationError as e:
            response = self.get_post_error_response_and_log(e, 400)
            return response, 400
        disruption = models.Disruption()
        mapper.fill_from_json(disruption, json, mapper.disruption_mapping)

        # Use contributor_code present in the json to get contributor_id
        if 'contributor' in json:
            disruption.contributor = models.Contributor.get_or_create(json['contributor'])
        disruption.client = client

        # Add localization present in Json
        try:
            db_helper.manage_pt_object_without_line_section(
                self.navitia, disruption.localizations, 'localization', json)
        except exceptions.ObjectUnknown as e:
            response = self.get_post_error_response_and_log(e, 404)
            return response, 404

        # Add all tags present in Json
        db_helper.manage_tags(disruption, json)
        # Add all impacts present in Json
        try:
            db_helper.manage_impacts(disruption, json, self.navitia)
        except exceptions.ObjectUnknown as e:
            response = self.get_post_error_response_and_log(e, 404)
            return response, 404

        except exceptions.InvalidJson as e:
            response = self.get_post_error_response_and_log(e, 400)
            return response, 400

        # Add all properties present in Json
        try:
            db_helper.manage_properties(disruption, json)
        except exceptions.ObjectUnknown as e:
            response = self.get_post_error_response_and_log(e, 404)
            return response, 404

        except exceptions.InvalidJson as e:
            response = self.get_post_error_response_and_log(e, 400)
            return response, 400

        try:
            db.session.add(disruption)
            db.session.commit()
            db.session.refresh(disruption)

            if not chaos.utils.send_disruption_to_navitia(disruption):
                ex_msg = 'An error occurred during transferring this disruption to Navitia. Please try again'
                raise exceptions.NavitiaError(ex_msg)

            return marshal({'disruption': disruption}, one_disruption_fields), 201
        except exceptions.NavitiaError as e:
            db.session.delete(disruption)
            db.session.commit()
            return marshal({'error': {'message': '{}'.format(e.message)}}, error_fields), 503
        except Exception as e:
            db.session.rollback()
            return marshal({'error': {'message': '{}'.format(e.message)}}, error_fields), 500

    @validate_navitia()
    @validate_client()
    @validate_contributor()
    @manage_navitia_error()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, contributor, navitia, id):
        self.navitia = navitia
        disruption = models.Disruption.get(id, contributor.id)
        json = request.get_json(silent=True)

        try:
            validate(json, disruptions_input_format)
        except ValidationError as e:
            response = self.get_put_error_response_and_log(e, 400)
            return response, 400

        if disruption.is_published() and 'status' in json\
           and json['status'] == 'draft':
            return marshal(
                {'error': {'message': 'The current disruption is already\
 published and cannot get back to the \'draft\' status.'}}, error_fields), 409

        mapper.fill_from_json(disruption, json, mapper.disruption_mapping)

        # Use contributor_code present in the json to get contributor_id
        if 'contributor' in json:
            disruption.contributor = models.Contributor.get_or_create(json['contributor'])

        # Add localization present in Json
        try:
            db_helper.manage_pt_object_without_line_section(
                self.navitia, disruption.localizations, 'localization', json)
        except exceptions.ObjectUnknown as e:
            response = self.get_put_error_response_and_log(e, 404)
            return response, 404

        # Add/delete tags present/ not present in Json
        db_helper.manage_tags(disruption, json)

        # Add all impacts present in Json
        try:
            db_helper.manage_impacts(disruption, json, self.navitia)
        except exceptions.ObjectUnknown as e:
            response = self.get_put_error_response_and_log(e, 404)
            return response, 404

        except exceptions.InvalidJson as e:
            response = self.get_put_error_response_and_log(e, 400)
            return response, 400

        # Add all properties present in Json
        try:
            db_helper.manage_properties(disruption, json)
        except exceptions.ObjectUnknown as e:
            db.session.rollback()
            response = self.get_put_error_response_and_log(e, 404)
            return response, 404

        disruption.upgrade_version()
        try:
            db.session.commit()
            db.session.refresh(disruption)
            if not chaos.utils.send_disruption_to_navitia(disruption):
                return marshal(
                    {'error': {'message': 'An error occurred during transferring\
this disruption to Navitia. Please try again.'}}, error_fields), 503
        except Exception as e:
            db.session.rollback()
            return marshal(
                {'error': {'message': '{}'.format(e.message)}},
                error_fields
            ), 500
        return marshal({'disruption': disruption}, one_disruption_fields), 200

    @validate_contributor()
    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, contributor, id):
        disruption = models.Disruption.get(id, contributor.id)
        disruption.upgrade_version()
        disruption.archive()
        try:
            if chaos.utils.send_disruption_to_navitia(disruption):
                db.session.commit()
                db.session.refresh(disruption)
                return None, 204
            else:
                db.session.rollback()
                return marshal(
                    {'error': {'message': 'An error occurred during transferring\
this disruption to Navitia. Please try again.'}}, error_fields), 503
        except BaseException:
            db.session.rollback()
        return marshal(
            {'error': {'message': 'An error occurred during deletion\
. Please try again.'}}, error_fields), 500

class DisruptionsSearch(flask_restful.Resource):
    def __init__(self):
        self.navitia = None
        self.parsers = {}
        self.parsers["post"] = reqparse.RequestParser()
        parser_post = self.parsers["post"]

        parser_post.add_argument("start_page", type=int, default=1, location='json')
        parser_post.add_argument("items_per_page", type=int, default=20, location='json')
        parser_post.add_argument("ends_after_date", type=utils.get_datetime, location='json')
        parser_post.add_argument("ends_before_date", type=utils.get_datetime, location='json')
        parser_post.add_argument("uri", type=str, location='json')
        parser_post.add_argument("line_section", type=types.boolean, default=False, location='json')
        parser_post.add_argument("current_time", type=utils.get_datetime, location='json')
        parser_post.add_argument("depth", type=int, default=1, location='json')

    @validate_navitia()
    @validate_contributor()
    @manage_navitia_error()
    @validate_client_token()
    def post(self, contributor, navitia):
        self.navitia = navitia
        args = self.parsers['post'].parse_args()

        try:
            json = request.get_json(silent=True)
            validate(json, disruptions_search_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        g.current_time = args['current_time']
        g.display_impacts = args['depth'] > 1
        result = models.Disruption.all_with_post_filter(
            page_index=args['start_page'],
            items_per_page=args['items_per_page'],
            contributor_id=contributor.id,
            application_status=json.get('application_status', application_status_values),
            publication_status=json.get('publication_status', publication_status_values),
            ends_after_date=args['ends_after_date'],
            ends_before_date=args['ends_before_date'],
            tags=json.get('tag', None),
            uri=args['uri'],
            line_section=args['line_section'],
            statuses=json.get('status', disruption_status_values),
            ptObjectFilter=json.get('ptObjectFilter', None),
            cause_category_id=json.get('cause_category_id', None)
        )
        utils.filter_disruptions_impacts_by_application_status(result.items, json.get('application_status', application_status_values))
        response = {'disruptions': result.items, 'meta': make_pager(result, 'disruption')}

        '''
        The purpose is to remove any database-loaded state from all current objects so that the next access of
        any attribute, or any query execution, will retrieve new state, freshening those objects which are still
        referenced outside of the session with the most recent available state.
        '''
        for o in result.items:
            models.db.session.expunge(o)
        return marshal(response, disruptions_fields)

class Cause(flask_restful.Resource):

    def __init__(self):
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]
        parser_get.add_argument(
            "category",
            type=utils.get_uuid
        )

    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        args = self.parsers['get'].parse_args()
        category_id = args['category']
        if id:
            response = {'cause': models.Cause.get(id, client.id, category_id)}
            return marshal(response, one_cause_fields)
        else:
            response = {'causes': models.Cause.all(client.id, category_id), 'meta': {}}
            return marshal(response, causes_fields)

    @validate_client(True)
    @validate_client_token()
    def post(self, client):
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('Post cause: %s', json)
        try:
            validate(json, cause_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        cause = models.Cause()
        mapper.fill_from_json(cause, json, mapper.cause_mapping)
        cause.client = client
        try:
            db_helper.manage_wordings(cause, json)
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        db.session.add(cause)
        db.session.commit()
        db.session.refresh(cause)
        return marshal({'cause': cause}, one_cause_fields), 201

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, id):
        cause = models.Cause.get(id, client.id)
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT cause: %s', json)

        try:
            validate(json, cause_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(cause, json, mapper.cause_mapping)
        try:
            db_helper.manage_wordings(cause, json)
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        db.session.commit()
        db.session.refresh(cause)
        return marshal({'cause': cause}, one_cause_fields), 200

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, id):
        cause = models.Cause.get(id, client.id)
        cause.is_visible = False
        db.session.commit()
        return None, 204


class Tag(flask_restful.Resource):

    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        if id:
            response = {'tag': models.Tag.get(id, client.id)}
            return marshal(response, one_tag_fields)
        else:
            response = {'tags': models.Tag.all(client.id), 'meta': {}}
            return marshal(response, tags_fields)

    @validate_client(True)
    @validate_client_token()
    def post(self, client):
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('Post tag: %s', json)
        try:
            validate(json, tag_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        # if an archived tag exists with same name use the same instead of creating a new one.
        archived_tag = models.Tag.get_archived_by_name(json['name'], client.id)
        if archived_tag:
            tag = archived_tag
            tag.client = client
            tag.is_visible = True
        else:
            tag = models.Tag()
            mapper.fill_from_json(tag, json, mapper.tag_mapping)
            tag.client = client
            db.session.add(tag)

        try:
            db.session.commit()
            db.session.refresh(tag)
        except IntegrityError as e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        return marshal({'tag': tag}, one_tag_fields), 201

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, id):
        tag = models.Tag.get(id, client.id)
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT tag: %s', json)

        try:
            validate(json, tag_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(tag, json, mapper.tag_mapping)
        try:
            db.session.commit()
            db.session.refresh(tag)
        except IntegrityError as e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        return marshal({'tag': tag}, one_tag_fields), 200

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, id):
        tag = models.Tag.get(id, client.id)
        tag.is_visible = False
        db.session.commit()
        return None, 204


class Category(flask_restful.Resource):

    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        if id:
            response = {'category': models.Category.get(id, client.id)}
            return marshal(response, one_category_fields)
        else:
            response = {'categories': models.Category.all(client.id), 'meta': {}}
            return marshal(response, categories_fields)

    @validate_client(True)
    @validate_client_token()
    def post(self, client):
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('Post category: %s', json)
        try:
            validate(json, category_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        # if an archived category exists with same name use the same instead of creating a new one.
        archived_category = models.Category.get_archived_by_name(json['name'], client.id)
        if archived_category:
            category = archived_category
            category.is_visible = True
        else:
            category = models.Category()
            mapper.fill_from_json(category, json, mapper.category_mapping)
            category.client = client
            db.session.add(category)

        try:
            db.session.commit()
            db.session.refresh(category)
        except IntegrityError as e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        return marshal({'category': category}, one_category_fields), 201

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, id):
        category = models.Category.get(id, client.id)
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT category: %s', json)

        try:
            validate(json, category_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(category, json, mapper.category_mapping)
        try:
            db.session.commit()
            db.session.refresh(category)
        except IntegrityError as e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        return marshal({'category': category}, one_category_fields), 200

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, id):
        category = models.Category.get(id, client.id)
        category.is_visible = False
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
        self.navitia = None

    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    @validate_client_token()
    def get(self, contributor, navitia):
        self.navitia = navitia
        args = self.parsers['get'].parse_args()
        pt_object_type = args['pt_object_type']
        start_date = args['start_date']
        end_date = args['end_date']
        uris = args['uri[]']

        if not pt_object_type and not uris:
            return marshal({'error': {'message': "object type or uri object invalid"}},
                           error_fields), 400
        impacts = models.Impact.all_with_filter(
            start_date,
            end_date,
            pt_object_type,
            uris,
            contributor.id)
        result = utils.group_impacts_by_pt_object(impacts, pt_object_type, uris, self.navitia.get_pt_object)
        return marshal({'objects': result}, impacts_by_object_fields)


class Impacts(flask_restful.Resource):
    def __init__(self):
        self.navitia = None
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]

        parser_get.add_argument("start_page", type=int, default=1)
        parser_get.add_argument("items_per_page", type=int, default=20)

    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    @validate_id()
    def get(self, contributor, disruption_id, navitia, id=None):
        self.navitia = navitia
        if id:
            response = models.Impact.get(id, contributor.id)
            return marshal({'impact': response}, one_impact_fields)
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
                                       disruption_id=disruption_id,
                                       contributor_id=contributor.id)
            response = {'impacts': result.items, 'meta': make_pager(result, 'impact', disruption_id=disruption_id)}
            return marshal(response, impacts_fields)

    @validate_client()
    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    def post(self, client, contributor, navitia, disruption_id):
        self.navitia = navitia
        if not id_format.match(disruption_id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400

        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('POST impact: %s', json)

        try:
            validate(json, impact_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        disruption = models.Disruption.get(disruption_id, contributor.id)
        try:
            impact = db_helper.create_or_update_impact(disruption, json, self.navitia)
        except exceptions.ObjectUnknown as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 404
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': '{}'.format(e.message)}}, error_fields), 400

        disruption.upgrade_version()
        try:
            db.session.commit()
            db.session.refresh(disruption)
            if not chaos.utils.send_disruption_to_navitia(disruption):
                ex_msg = 'An error occurred during transferring this impact to Navitia. Please try again'
                raise exceptions.NavitiaError(ex_msg)
            return marshal({'impact': impact}, one_impact_fields), 201
        except exceptions.NavitiaError as e:
            db.session.delete(impact)
            db.session.commit()
            return marshal({'error': {'message': '{}'.format(e.message)}}, fields.error_fields), 503
        except Exception as e:
            db.session.rollback()
            return marshal(
                {'error': {'message': '{}'.format(e.message)}},
                error_fields
            ), 500

    @validate_client()
    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    @validate_id(True)
    def put(self, client, contributor, navitia, disruption_id, id):
        self.navitia = navitia
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT impact: %s', json)

        try:
            validate(json, impact_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        disruption = models.Disruption.get(disruption_id, contributor.id)
        try:
            impact = db_helper.create_or_update_impact(disruption, json, self.navitia, id)
        except exceptions.ObjectUnknown as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 404
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': '{}'.format(e.message)}}, error_fields), 400
        disruption = models.Disruption.get(disruption_id, contributor.id)
        disruption.upgrade_version()
        try:
            db.session.commit()
            db.session.refresh(disruption)
            if not chaos.utils.send_disruption_to_navitia(disruption):
                return marshal(
                    {'error': {'message': 'An error occurred during transferring\
this impact to Navitia. Please try again.'}}, error_fields), 503
        except Exception as e:
            db.session.rollback()
            return marshal(
                {'error': {'message': '{}'.format(e.message)}},
                error_fields
            ), 500
        return marshal({'impact': impact}, one_impact_fields), 200

    @validate_contributor()
    @validate_id(True)
    def delete(self, contributor, disruption_id, id):
        impact = models.Impact.get(id, contributor.id)
        impact.archive()
        disruption = models.Disruption.get(disruption_id, contributor.id)
        disruption.upgrade_version()
        try:
            if chaos.utils.send_disruption_to_navitia(disruption):
                db.session.commit()
                db.session.refresh(disruption)
                return None, 204
            else:
                db.session.rollback()
                return marshal(
                    {'error': {'message': 'An error occurred during transferring\
this impact to Navitia. Please try again.'}}, error_fields), 503
        except BaseException:
            db.session.rollback()
        return marshal(
            {'error': {'message': 'An error occurred during deletion\
. Please try again.'}}, error_fields), 500


class Channel(flask_restful.Resource):
    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        if id:
            response = {'channel': models.Channel.get(id, client.id)}
            return marshal(response, one_channel_fields)
        else:
            response = {'channels': models.Channel.all(client.id), 'meta': {}}
            return marshal(response, channels_fields)

    @validate_client(True)
    @validate_client_token()
    def post(self, client):
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('Post channel: %s', json)
        try:
            validate(json, channel_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        channel = models.Channel()
        mapper.fill_from_json(channel, json, mapper.channel_mapping)
        channel.client = client
        try:
            db_helper.manage_channel_types(channel, json["types"])
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        db.session.add(channel)
        db.session.commit()
        db.session.refresh(channel)
        return marshal({'channel': channel}, one_channel_fields), 201

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, id):
        channel = models.Channel.get(id, client.id)
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT channel: %s', json)

        try:
            validate(json, channel_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            # TODO: generate good error messages
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(channel, json, mapper.channel_mapping)
        try:
            db_helper.manage_channel_types(channel, json["types"])
        except exceptions.InvalidJson as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        db.session.commit()
        db.session.refresh(channel)
        return marshal({'channel': channel}, one_channel_fields), 200

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, id):
        channel = models.Channel.get(id, client.id)
        channel.is_visible = False
        db.session.commit()
        return None, 204


class ChannelType(flask_restful.Resource):

    @validate_client_token()
    def get(self):
        return {'channel_types': [type for type in channel_type_values]}, 200


class Status(flask_restful.Resource):
    def get(self):
        return {
            'version': chaos.VERSION,
            'db_pool_status': db.engine.pool.status(),
            'db_version': db.engine.scalar('select version_num from alembic_version;'),
            'navitia_url': current_app.config['NAVITIA_URL'],
            'rabbitmq_info': publisher.info()
        }, 200


class TrafficReport(flask_restful.Resource):
    def __init__(self):
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()
        parser_get = self.parsers["get"]
        parser_get.add_argument("current_time", type=utils.get_datetime, default=utils.get_current_time())
        self.navitia = None

    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    @validate_client_token()
    def get(self, contributor, navitia):
        return self._get_traffic_report(contributor.id, navitia)

    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    @validate_client_token()
    def post(self, contributor, navitia):
        return self._get_traffic_report(contributor.id, navitia, request.get_json(silent=True))

    def _get_traffic_report(self, contributor_id, navitia, body_json=None):
        self.navitia = navitia
        args = self.parsers['get'].parse_args()
        if body_json is None:
            body_json = {}
        g.current_time = (utils.get_datetime(body_json.get('current_time'), 'current_time')
                          if body_json.get('current_time')
                          else args['current_time'])
        disruptions = models.Disruption.traffic_report_filter(contributor_id)

        networks_filter = []
        # Filter disruptions by PtObject
        if body_json.get('ptObjectFilter', []):
            utils.filter_disruptions_by_ptobjects(disruptions, body_json['ptObjectFilter'])
            networks_filter = body_json['ptObjectFilter'].get('networks', [])

        # Prepare line sections to get them all in once
        pt_object_ids = []
        for disruption in disruptions:
            for impact in (i for i in disruption.impacts if i.status == 'published'):
                for pt_object in impact.objects:
                    pt_object_ids.append(pt_object.id)

        line_sections = models.LineSection.get_by_ids(pt_object_ids)
        line_sections_by_objid = {}
        for line_section in line_sections:
            line_sections_by_objid[line_section.object_id] = line_section

        result = utils.get_traffic_report_objects(disruptions, self.navitia, line_sections_by_objid, networks_filter)
        return marshal(
            {
                'traffic_reports': [value for key, value in result["traffic_report"].items()],
                'disruptions': result["impacts_used"]
            },
            traffic_reports_marshaler
        ), 200

class Property(flask_restful.Resource):
    def __init__(self):
        self.parsers = {'get': reqparse.RequestParser()}
        self.parsers['get'].add_argument('key').add_argument('type')

    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        args = self.parsers['get'].parse_args()
        key = args['key']
        type = args['type']

        if id:
            property = models.Property.get(client.id, id)

            if property is None:
                return marshal({
                    'error': {'message': 'Property {} not found'.format(id)}
                }, error_fields), 404

            return marshal({'property': property}, one_property_fields)
        else:
            response = {
                'properties': models.Property.all(client.id, key, type)
            }
            return marshal(response, properties_fields)

    @validate_client(True)
    @validate_client_token()
    def post(self, client):
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('POST property: %s', json)

        try:
            validate(json, property_input_format)
        except ValidationError as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        property = models.Property()
        mapper.fill_from_json(property, json, mapper.property_mapping)
        property.client = client
        db.session.add(property)

        try:
            db.session.commit()
            db.session.refresh(property)
        except IntegrityError as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 409

        return marshal({'property': property}, one_property_fields), 201

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def put(self, client, id):
        property = models.Property.get(client.id, id)

        if property is None:
            return marshal({
                'error': {'message': 'Property {} not found'.format(id)}
            }, error_fields), 404

        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('PUT property: %s', json)

        try:
            validate(json, property_input_format)
        except ValidationError as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        mapper.fill_from_json(property, json, mapper.property_mapping)

        try:
            db.session.commit()
            db.session.refresh(property)
        except IntegrityError as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 409

        return marshal({'property': property}, one_property_fields), 200

    @validate_client()
    @validate_id(True)
    @validate_client_token()
    def delete(self, client, id):
        property = models.Property.get(client.id, id)

        if property is None:
            return marshal({
                'error': {'message': 'Property {} not found'.format(id)}
            }, error_fields), 404

        can_be_deleted = property.disruptions.filter(
            models.Disruption.status != 'archived',
            models.AssociateDisruptionProperty.disruption_id == models.Disruption.id
        ).count() == 0

        if can_be_deleted:
            db.session.delete(property)
            db.session.commit()
        else:
            return marshal({
                'error': {
                    'message': 'The current {} is linked to at least one disruption\
 and cannot be deleted'.format(property)
                }
            }, error_fields), 409

        return None, 204
