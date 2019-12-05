# Copyright (c) since 2001, Kisio Digital and/or its affiliates. All rights reserved.

import math
from flask import g, request, jsonify, make_response, send_file
from flask_sqlalchemy import Pagination
import flask_restful
from flask_restful import marshal, reqparse, types
from chaos import models, db, publisher
from jsonschema import validate, ValidationError
from flask.ext.restful import abort
from fields import *
from formats import *
from formats import impact_input_format, channel_input_format, pt_object_type_values,\
    tag_input_format, category_input_format, channel_type_values,\
    property_input_format, disruptions_search_input_format, application_status_values, \
    impacts_search_input_format, export_input_format
from chaos import mapper, exceptions
from chaos import utils, db_helper
import chaos
import json
from sqlalchemy.exc import IntegrityError
import logging
from utils import make_pager, option_value, get_current_time, add_notification_date_on_impacts
from chaos.validate_params import validate_client, validate_contributor, validate_navitia, \
    manage_navitia_error, validate_id, validate_client_token, \
    validate_send_notifications_and_notification_date, validate_pagination, \
    validate_cause
from collections import OrderedDict
from aniso8601 import parse_datetime
from history import save_disruption_in_history, create_disruption_from_json
from chaos.db_mapper import disruption as db_disruption_mapper

__all__ = ['Disruptions', 'Index', 'Severity', 'Cause']


class Index(flask_restful.Resource):

    def get(self):
        response = {
            "disruptions": {"href": url_for('disruption', _external=True)},
            "disruption": {"href": url_for('disruption', _external=True) + '/{id}', "templated": True},
            "severities": {"href": url_for('severity', _external=True)},
            "severity": {"href": url_for('severity', _external=True) + '/{id}', "templated": True},
            "causes": {"href": url_for('cause', _external=True)},
            "cause": {"href": url_for('cause', _external=True) + '/{id}', "templated": True},
            "channels": {"href": url_for('channel', _external=True)},
            "channel": {"href": url_for('channel', _external=True) + '/{id}', "templated": True},
            "impactsbyobject": {"href": url_for('impactsbyobject', _external=True)},
            "tags": {"href": url_for('tag', _external=True)},
            "tag": {"href": url_for('tag', _external=True) + '/{id}', "templated": True},
            "categories": {"href": url_for('category', _external=True)},
            "category": {"href": url_for('category', _external=True) + '/{id}', "templated": True},
            "channeltypes": {"href": url_for('channeltype', _external=True)},
            "traffic_reports": {"href": url_for('trafficreport', _external=True)},
            "properties": {"href": url_for('property', _external=True)},
            "property": {"href": url_for('property', _external=True) + '/{id}', "templated": True},
            "impacts_exports": {"href": url_for('impacts_exports', _external=True)},
            "impacts_export": {"href": url_for('impacts_exports', _external=True) + '/{id}', "templated": True},
            "impacts_export_download": {"href": url_for('impacts_exports', _external=True) + '/{id}/download', "templated": True},
            "impacts": {"href": url_for('disruption', _external=True) + '/{disruption_id}/impacts', "templated": True},
            "impact": {"href": url_for('disruption', _external=True) + '/{disruption_id}/impacts/{id}', "templated": True}
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
    @validate_pagination()
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
        results = models.Disruption.get_native(id, contributor_id)

        if not results:
            abort(404)

        disruptions = db_disruption_mapper.map_disruption(results)

        return marshal({'disruption': disruptions[id]}, one_disruption_fields)

    def _get_disruptions(self, contributor_id, args):

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

    def get_post_error_response_and_log(self, exception, status_code):
        return self.get_error_response_and_log('POST', exception, status_code)

    def get_put_error_response_and_log(self, exception, status_code):
        return self.get_error_response_and_log('PUT', exception, status_code)

    def get_error_response_and_log(self, method, exception, status_code):
        response_content = marshal({'error': {'message': utils.parse_error(exception)}}, error_fields)
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
    @validate_cause()
    @validate_send_notifications_and_notification_date()
    def post(self, client, navitia):
        self.navitia = navitia
        json = request.get_json(silent=True)

        try:
            validate(json, disruptions_input_format)
        except ValidationError as e:
            response = self.get_post_error_response_and_log(e, 400)
            return response, 400
        add_notification_date_on_impacts(json)
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

            save_disruption_in_history(disruption)

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
    @validate_cause()
    @validate_send_notifications_and_notification_date()
    def put(self, client, contributor, navitia, id):
        self.navitia = navitia
        disruption = models.Disruption.get(id, contributor.id)
        json = request.get_json(silent=True)

        try:
            validate(json, disruptions_input_format)
        except ValidationError as e:
            response = self.get_put_error_response_and_log(e, 400)
            return response, 400
        add_notification_date_on_impacts(json)
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

            save_disruption_in_history(disruption)

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
                save_disruption_in_history(disruption)
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


class ImpactsSearch(flask_restful.Resource):
    def __init__(self):
        self.navitia = None
        self.parsers = {}
        self.parsers["post"] = reqparse.RequestParser()
        parser_post = self.parsers["post"]

        parser_post.add_argument("start_page", type=int, default=1, location='json')
        parser_post.add_argument("items_per_page", type=int, default=20, location='json')
        parser_post.add_argument("current_time", type=utils.get_datetime, location='json')

    @validate_navitia()
    @validate_contributor()
    @manage_navitia_error()
    @validate_client_token()
    @validate_pagination()
    def post(self, contributor, navitia):
        self.navitia = navitia
        args = self.parsers['post'].parse_args()

        try:
            json = request.get_json(silent=True)
            validate(json, impacts_search_input_format)
        except ValidationError as e:
            logging.debug(str(e))
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400

        g.current_time = args['current_time']
        current_time = get_current_time()
        application_status = json.get('application_status', application_status_values)
        ptObjectFilter = json.get('ptObjectFilter', None)
        application_period = json.get('application_period', None)

        total_results_count = models.Impact.count_all_with_post_filter(
            contributor_id=contributor.id,
            application_status=application_status,
            ptObjectFilter=ptObjectFilter,
            cause_category_id=json.get('cause_category_id', None),
            application_period=application_period,
            current_time=current_time
        )

        results = models.Impact.all_with_post_filter_native(
            page_index=args['start_page'],
            items_per_page=args['items_per_page'],
            contributor_id=contributor.id,
            application_status=application_status,
            ptObjectFilter=ptObjectFilter,
            cause_category_id=json.get('cause_category_id', None),
            application_period=application_period,
            current_time=current_time
        )

        impacts= OrderedDict()
        disruptions = {}
        cause_wordings = {}
        severity_wordings = {}
        impact_pt_objects = {}
        application_periods = {}
        messages = {}
        channels = {}
        channel_types = {}
        message_metas = {}
        application_period_patterns = {}
        time_slots = {}
        line_section_metas = {}
        line_section_via = {}
        line_section_routes = {}

        for r in results:
            disruptionId = r.id
            wordingId = r.cause_wording_id
            impact_id = r.impact_id
            severity_id = r.severity_id
            severity_wording_id = r.severity_wording_id
            impact_pt_object_id = r.pt_object_id
            application_period_id = r.application_period_id
            message_id = r.message_id
            channel_id = r.channel_id
            channel_type_id = r.channel_type_id
            message_meta_id = r.meta_id
            application_period_patterns_id = r.pattern_id
            time_slot_id = r.time_slot_id
            line_section_id = r.line_section_id

            if impact_id is not None:
                impacts[impact_id] = {
                    'id': r.impact_id,
                    'disruption_id': r.id,
                    'disruption': {
                        'id': r.id,
                        'cause': {
                            'id': r.cause_id,
                            'created_at': r.cause_created_at,
                            'updated_at': r.cause_updated_at,
                            'wordings': [],
                            'category': {
                                'id': r.cause_category_id,
                                'name': r.cause_category_name,
                                'created_at': r.cause_category_created_at,
                                'updated_at': r.cause_category_updated_at
                            }
                        }
                    },
                    'created_at': r.impact_created_at,
                    'updated_at': r.impact_updated_at,
                    'send_notifications': r.impact_send_notifications,
                    'notification_date': r.impact_notification_date
                }

                if impact_id not in cause_wordings:
                    cause_wordings[impact_id] = {}
                cause_wordings[impact_id][wordingId] = {
                    'key': r.cause_wording_key,
                    'value': r.cause_wording_value
                }

                impacts[impact_id]['severity'] = {
                    'id': r.severity_id,
                    'client_id': r.severity_client_id,
                    'effect': r.severity_effect,
                    'priority': r.severity_priority,
                    'is_visible': r.severity_is_visible,
                    'color': r.severity_color,
                    'wording': r.severity_wording,
                    'updated_at': r.severity_updated_at,
                    'created_at': r.severity_created_at
                }

            if impact_id not in application_period_patterns:
                application_period_patterns[impact_id] = {}
            if application_period_patterns_id is not None:
                application_period_patterns[impact_id][application_period_patterns_id] = {
                    'id': r.pattern_id,
                    'start_date': r.pattern_start_date,
                    'end_date': r.pattern_end_date,
                    'weekly_pattern': r.pattern_weekly_pattern
                }
            if application_period_patterns_id not in time_slots:
                time_slots[application_period_patterns_id] = {}
            if application_period_patterns_id is not None:
                time_slots[application_period_patterns_id][time_slot_id] = {
                    'begin': r.time_slot_begin,
                    'end': r.time_slot_end
                }

            if impact_id not in application_periods:
                application_periods[impact_id] = {}
            if application_period_id is not None:
                application_periods[impact_id][application_period_id] = {
                    'start_date': r.application_period_start_date,
                    'end_date': r.application_period_end_date
                }

            if impact_id not in messages:
                messages[impact_id] = {}

            if message_id not in channels:
                channels[message_id] = {}

            if message_id is not None:
                messages[impact_id][message_id] = {
                    'id': r.message_id,
                    'created_at': r.message_created_at,
                    'updated_at': r.message_updated_at,
                    'text': r.message_text,
                    'meta': [],
                    'channel': {
                        'id': channel_id,
                        'content_type': r.channel_content_type,
                        'created_at': r.channel_created_at,
                        'updated_at': r.channel_updated_at,
                        'max_size': r.channel_max_size,
                        'name': r.channel_name,
                        'required': r.channel_required
                    }
                }

            if channel_id is not None and channel_id not in channel_types:
                channel_types[channel_id] = {}

            if channel_type_id is not None:
                if channel_type_id not in channel_types[channel_id]:
                    channel_types[channel_id][channel_type_id] = {}
                channel_types[channel_id][channel_type_id].update({
                    'name': r.channel_type_name
                })
            if message_id not in message_metas:
                message_metas[message_id] = {}
            if message_meta_id is not None:
                message_metas[message_id][message_meta_id] = {
                    'key': r.meta_key,
                    'value': r.meta_value
                }

            if severity_id not in severity_wordings:
                severity_wordings[severity_id] = {}
            if  severity_wording_id is not None:
                severity_wordings[severity_id][severity_wording_id] = {
                    'key': r.severity_wording_key,
                    'value': r.severity_wording_value
                }

            if impact_id not in impact_pt_objects:
                impact_pt_objects[impact_id] = {}
            if  impact_pt_object_id is not None:
                impact_pt_objects[impact_id][impact_pt_object_id] = {
                    'id': r.pt_object_id,
                    'uri': r.pt_object_uri,
                    'type': r.pt_object_type,
                }
                if line_section_id is not None:
                    if impact_pt_object_id not in line_section_metas:
                        line_section_metas[impact_pt_object_id] = {}
                    if impact_pt_object_id not in line_section_via:
                        line_section_via[impact_pt_object_id] = {}
                    if impact_pt_object_id not in line_section_routes:
                        line_section_routes[impact_pt_object_id] = {}

                    if r.awlsw_id is not None:
                        line_section_metas[impact_pt_object_id][r.awlsw_id] = {
                            'key': r.awlsw_key,
                            'value': r.awlsw_value
                        }
                    if r.po_via_id is not None:
                        line_section_via[impact_pt_object_id][r.po_via_id] = {
                            'uri': r.po_via_uri,
                            'type': r.po_via_type
                        }
                    if r.po_route_id is not None:
                        line_section_routes[impact_pt_object_id][r.po_route_id] = {
                            'uri': r.po_route_uri,
                            'type': r.po_route_type
                        }
                    impact_pt_objects[impact_id][impact_pt_object_id]['line_section'] = {
                        'line': {
                            'uri': r.line_section_line_uri,
                            'type': r.line_section_line_type
                        },
                        'start_point': {
                            'uri': r.line_section_start_uri,
                            'type': r.line_section_start_type
                        },
                        'end_point': {
                            'uri': r.line_section_end_uri,
                            'type': r.line_section_end_type
                        },
                        'sens': r.line_section_sens,
                        'routes': [],
                        'via': [],
                        'metas': []
                    }

        for impact in impacts.values():
            impact_id = impact['id']
            impact['disruption']['cause']['wordings'] = cause_wordings[impact_id].values()
            impact['severity']['wordings'] = severity_wordings[impact['severity']['id']].values()
            impact['objects'] = impact_pt_objects[impact_id].values()
            impact['application_periods'] = application_periods[impact_id].values()
            impact['messages'] = messages[impact_id].values()
            impact['patterns'] = application_period_patterns[impact_id].values()

            for message in impact['messages']:
                channel_id = message['channel']['id']
                message_id = message['id']
                message['channel']['channel_types'] = channel_types[channel_id].values()
                message['meta'] = message_metas[message_id].values()
            for application_period_pattern in impact['patterns']:
                application_period_pattern_id = application_period_pattern['id']
                application_period_pattern['time_slots'] = time_slots[application_period_pattern_id].values()
            for pt_object in impact['objects']:
                impact_pt_object_id = pt_object['id']
                if impact_pt_object_id in line_section_via:
                    pt_object['line_section']['via'] = line_section_via[impact_pt_object_id].values()
                if impact_pt_object_id in line_section_routes:
                    pt_object['line_section']['routes'] = line_section_routes[impact_pt_object_id].values()
                if impact_pt_object_id in line_section_metas:
                    pt_object['line_section']['wordings'] = line_section_metas[impact_pt_object_id].values()

        rawData = {'impacts': impacts.values(), 'meta': self.createPager(
            resultset = impacts.values(),
            current_page=args['start_page'],
            per_page = args['items_per_page'],
            total_results_count = total_results_count,
            endpoint = '')}

        return marshal(rawData, impacts_search_fields)

    def createPager(self, resultset, current_page, per_page, total_results_count,  endpoint):

        per_page = max(1, per_page)

        pagination = Pagination
        pagination.per_page = per_page
        pagination.total = total_results_count
        pagination.page = current_page
        pagination.items = resultset

        return make_pager(pagination, endpoint)


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
        parser_post.add_argument("line_section", type=types.boolean, default=False, location='json')
        parser_post.add_argument("current_time", type=utils.get_datetime, location='json')
        parser_post.add_argument("depth", type=int, default=1, location='json')

    @validate_navitia()
    @validate_contributor()
    @manage_navitia_error()
    @validate_client_token()
    @validate_pagination()
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
        current_time=get_current_time()
        application_status=json.get('application_status', application_status_values)
        uri=json.get('uri', None)
        ptObjectFilter=json.get('ptObjectFilter', None)
        application_period = json.get('application_period', None)

        total_results_count = models.Disruption.count_all_with_post_filter(
            contributor_id=contributor.id,
            application_status=application_status,
            publication_status=json.get('publication_status', publication_status_values),
            ends_after_date=args['ends_after_date'],
            ends_before_date=args['ends_before_date'],
            tags=json.get('tag', None),
            uri=uri,
            line_section=args['line_section'],
            statuses=json.get('status', disruption_status_values),
            ptObjectFilter=ptObjectFilter,
            cause_category_id=json.get('cause_category_id', None),
            application_period=application_period,
            current_time=current_time
        )

        results = models.Disruption.all_with_post_filter_native(
            page_index=args['start_page'],
            items_per_page=args['items_per_page'],
            contributor_id=contributor.id,
            application_status=application_status,
            publication_status=json.get('publication_status', publication_status_values),
            ends_after_date=args['ends_after_date'],
            ends_before_date=args['ends_before_date'],
            tags=json.get('tag', None),
            uri=uri,
            line_section=args['line_section'],
            statuses=json.get('status', disruption_status_values),
            ptObjectFilter=ptObjectFilter,
            cause_category_id=json.get('cause_category_id', None),
            application_period=application_period,
            current_time=current_time
        )

        disruptions = db_disruption_mapper.map_disruption(results)

        rawData = {'disruptions': disruptions.values(), 'meta': self.createPager(
            resultset = disruptions.values(),
            current_page=args['start_page'],
            per_page = args['items_per_page'],
            total_results_count = total_results_count,
            endpoint = 'disruption')}

        result = marshal(rawData, disruptions_fields)
        return result

        # return make_response(ujson.dumps(rawData))
        #return response

        # return jsonify(rawData)


    def createPager(self, resultset, current_page, per_page, total_results_count,  endpoint):

        per_page = max(1, per_page)

        pagination = Pagination
        pagination.per_page = per_page
        pagination.total = total_results_count
        pagination.page = current_page
        pagination.items = resultset

        pagination.pages = int(math.ceil(pagination.total / float(pagination.per_page)))
        pagination.next_num = min(pagination.pages, pagination.page + 1)
        pagination.prev_num = max(1, pagination.page - 1)

        pagination.has_next = pagination.page < pagination.next_num
        pagination.has_prev = pagination.page > pagination.prev_num

        return make_pager(pagination, endpoint)


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
        if (cause.is_used_in_disruption()):
            error_msg = 'The current \'{}\' is linked to at least one disruption and cannot be deleted'.format(cause.wording)
            logging.getLogger(__name__).warning(error_msg)
            return marshal({'error': {'message': error_msg}}, error_fields), 409
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
    @validate_pagination()
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

            result = models.Impact.all(page_index=args['start_page'],
                                       items_per_page=args['items_per_page'],
                                       disruption_id=disruption_id,
                                       contributor_id=contributor.id)
            response = {'impacts': result.items, 'meta': make_pager(result, 'impact', disruption_id=disruption_id)}
            return marshal(response, impacts_fields)

    @validate_client()
    @validate_contributor()
    @validate_navitia()
    @manage_navitia_error()
    @validate_send_notifications_and_notification_date()
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
        add_notification_date_on_impacts(json)
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
            save_disruption_in_history(disruption)
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
    @validate_send_notifications_and_notification_date()
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
        add_notification_date_on_impacts(json)
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
        save_disruption_in_history(disruption)
        return marshal({'impact': impact}, one_impact_fields), 200

    @validate_contributor()
    @validate_id(True)
    def delete(self, contributor, disruption_id, id):
        disruption = models.Disruption.get(disruption_id, contributor.id)
        disruption.upgrade_version()
        if (disruption.is_last_impact(id)):
            disruption.archive()
        else:
            impact = models.Impact.get(id, contributor.id)
            impact.archive()
        try:
            if chaos.utils.send_disruption_to_navitia(disruption):
                db.session.commit()
                db.session.refresh(disruption)
                save_disruption_in_history(disruption)
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

class ImpactsExports(flask_restful.Resource):
    def __init__(self):
        self.parsers = {'get': reqparse.RequestParser()}
        self.navitia = None


    def validate_dates_boundary(self, json):
        start_date = parse_datetime(json.get('start_date')).replace(tzinfo=None)
        end_date = parse_datetime(json.get('end_date')).replace(tzinfo=None)
        if start_date > end_date:
            raise ValidationError(message='\'start_date\' should be inferior to \'end_date\'')
        duration_date = end_date - start_date
        if duration_date.days > 366 :
            raise ValidationError(message='Export should be less than 366 days')

    def run_export(self, export):

        from subprocess import Popen, PIPE
        from os import path, environ
        from sys import executable

        root_dir = path.abspath(path.join(__file__, "../.."))
        exporter_path = path.join(root_dir, 'impactsExporter.py')
        python_exec = executable
        if current_app.config['IMPACT_EXPORT_PYTHON'] != '':
            python_exec = current_app.config['IMPACT_EXPORT_PYTHON']

        Popen([
            python_exec, exporter_path,
            '--client_id', export.client_id,
            '--navitia_url', self.navitia.url,
            '--coverage', self.navitia.coverage,
            '--token', self.navitia.token,
            '--folder', current_app.config['IMPACT_EXPORT_DIR'],
            '--tz', export.time_zone],
            stdout=PIPE, env=environ.copy())


    @validate_client()
    @validate_id()
    @validate_client_token()
    def get(self, client, id=None):
        if id:
            return marshal({'export': models.Export.get(client.id, id)}, one_export_fields)
        else:
            return marshal({'exports':models.Export.all(client.id)}, exports_fields)

    @validate_client()
    @validate_navitia()
    @validate_client_token()
    def post(self, client, navitia):
        self.navitia = navitia
        json = request.get_json(silent=True)
        logging.getLogger(__name__).debug('POST export: %s', json)

        try:
            validate(json, export_input_format)
            self.validate_dates_boundary(json)
        except ValidationError as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 400
        export = models.Export.exist_without_error(client.id, json.get('start_date'), json.get('end_date'))
        if export is not None:
            logging.getLogger(__name__).warning('There is an existing export task for this client marked as "%s"' % export.status)
            return marshal({'export': export}, one_export_fields), 200

        export = models.Export(client.id)
        mapper.fill_from_json(export, json, mapper.export_mapping)
        db.session.add(export)

        try:
            db.session.commit()
            db.session.refresh(export)
        except IntegrityError as e:
            return marshal({'error': {'message': utils.parse_error(e)}},
                           error_fields), 409
        else:
            self.run_export(export)

        return marshal({'export': export}, one_export_fields), 201


class ImpactsExportDownload(flask_restful.Resource):
    def __init__(self):
        self.parsers = {'get': reqparse.RequestParser()}

    @validate_client()
    @validate_client_token()
    def get(self, client, id):
        export = models.Export.find_finished_export(id)
        if export is None:
            return marshal({
                'error': {'message': 'There is any available export for id {} '.format(id)}
            }, error_fields), 404

        export_file_path= export.file_path
        import os.path
        if not os.path.isfile(export_file_path):
            return marshal({
                'error': {'message': 'export file does not exist'}
            }, error_fields), 404


        return send_file(export_file_path,
                         mimetype="text/csv",
                         as_attachment=True
                         )

class DisruptionsHistory(flask_restful.Resource):
    def __init__(self):
        self.navitia = None
        self.parsers = {}
        self.parsers["get"] = reqparse.RequestParser()

    @validate_navitia()
    @validate_contributor()
    @manage_navitia_error()
    @validate_client_token()
    def get(self, contributor, navitia, disruption_id):

        if not id_format.match(disruption_id):
            return marshal({'error': {'message': "id invalid"}},
                           error_fields), 400

        g.display_impacts = True
        disruptions = OrderedDict()
        history_disruption_model = models.HistoryDisruption()
        history_disruptions = history_disruption_model.get_by_disruption_id(disruption_id)
        for history_disruption in history_disruptions:
            disruption = create_disruption_from_json(json.loads(history_disruption.data))
            disruptions[disruption.version] = disruption

        return marshal({'disruptions': disruptions.values()}, disruptions_fields)
