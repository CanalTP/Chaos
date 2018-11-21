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

from os import path
from functools import wraps
from datetime import datetime, timedelta
import uuid
import json
import logging
from math import ceil
from flask import url_for, g
import flask
from aniso8601 import parse_datetime, parse_time, parse_date

import pytz
from jsonschema import ValidationError

from chaos.formats import id_format
from chaos.populate_pb import populate_pb
from chaos.exceptions import HeaderAbsent, Unauthorized
import chaos


def make_pager(resultset, endpoint, **kwargs):
    prev_link = None
    next_link = None
    last_link = None
    first_link = None

    if resultset.has_prev:
        prev_link = url_for(endpoint,
                            start_page=resultset.prev_num,
                            items_per_page=resultset.per_page,
                            _external=True, **kwargs)

    if resultset.has_next:
        next_link = url_for(endpoint,
                            start_page=resultset.next_num,
                            items_per_page=resultset.per_page,
                            _external=True, **kwargs)

    if resultset.total > 0:
        last_link = url_for(endpoint,
                            start_page=resultset.pages,
                            items_per_page=resultset.per_page,
                            _external=True, **kwargs)
        first_link = url_for(endpoint,
                             start_page=1,
                             items_per_page=resultset.per_page,
                             _external=True, **kwargs)

    result = {}
    result["pagination"] = {
        "start_page": resultset.page,
        "items_on_page": len(resultset.items),
        "items_per_page": resultset.per_page,
        "total_result": resultset.total,
        "prev": {"href": prev_link},
        "next": {"href": next_link},
        "first": {"href": first_link},
        "last": {"href": last_link}
    }
    return result


def make_fake_pager(resultcount, per_page, endpoint, **kwargs):
    """
        Generate a fake pager object only based on the object count
        for the first page
    """
    prev_link = None
    next_link = None
    last_link = None
    first_link = None

    if resultcount > per_page:
        next_link = url_for(endpoint,
                            start_page=2,
                            items_per_page=per_page,
                            _external=True, **kwargs)

    if resultcount > 0:
        last_link = url_for(endpoint,
                            start_page=int(ceil(float(resultcount) / per_page)),
                            items_per_page=per_page,
                            _external=True, **kwargs)
        first_link = url_for(endpoint,
                             start_page=1,
                             items_per_page=per_page,
                             _external=True, **kwargs)

    result = {
        "pagination": {
            "start_page": 1,
            "items_on_page": min(resultcount, per_page),
            "items_per_page": per_page,
            "total_result": resultcount,
            "prev": {"href": prev_link},
            "next": {"href": next_link},
            "first": {"href": first_link},
            "last": {"href": last_link}
        }
    }
    return result


class paginate(object):
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            page_index = kwargs['page_index']
            items_per_page = kwargs['items_per_page']
            del kwargs['page_index']
            del kwargs['items_per_page']
            objects = func(*args, **kwargs)
            result = objects.paginate(page_index, items_per_page)
            return result
        return wrapper


def get_datetime(value, name):
    """
        Convert string to datetime

        :param value: string to convert
        :param name: attribute name
        :return: DateTime format '2014-04-31T16:52:00'
        tzinfo=None : information about the offset from UTC time
    """
    try:
        return parse_datetime(value).replace(tzinfo=None)
    except BaseException:
        raise ValueError("The {} argument value is not valid, you gave: {}"
                         .format(name, value))


def get_utc_datetime_by_zone(value, time_zone):
    """
        Convert datetime naive to UTC for a time zone. for example 'Europe/Paris'
        :param value: DateTime
        :param time_zone: time zone, exmple 'Europe/Paris'
        :return: DateTime in UTC
    """
    try:
        current_tz = pytz.timezone(time_zone)

        return current_tz.localize(value).astimezone(pytz.utc).replace(tzinfo=None)
    except BaseException:
        raise ValueError("The {} argument value is not valid, you gave: {}"
                         .format(value, time_zone))


def get_current_time():
    """
        Get current time global variable
        :return: DateTime format '2014-04-31T16:52:00'
    """
    if g and 'current_time' in g and g.current_time:
        return g.current_time
    return datetime.utcnow().replace(microsecond=0)

def option_value(values):
    def to_return(value, name):
        if value not in values:
            error = "The {} argument must be in list {}, you gave {}".\
                format(name, str(values), value)
            raise ValueError(error)
        return value
    return to_return


class Request(flask.Request):
    """
    override the request of flask to add an id on all request
    """

    def __init__(self, *args, **kwargs):
        super(Request, self).__init__(*args, **kwargs)
        self.id = str(uuid.uuid4())


def is_pt_object_valid(pt_object, object_type, uris):
    """
    verification object by its type and uri
    :param pt_object: public transport object
    :param object_type: public transport object type
    :param uris: public transport object uri
    :return: bool
    """
    if object_type:
        if uris:
            return ((pt_object.type == object_type) and
                    (pt_object.uri in uris))
        return pt_object.type == object_type
    elif uris:
        return pt_object.uri in uris
    return False


def get_object_in_line_section_by_uri(pt_object, uris):
    """
    verify if object exists in line_section
    :param pt_object: public transport object
    :param uris: public transport object uri
    :return: object found
    """
    if pt_object.uri in uris:
        return pt_object

    if pt_object.line_section:
        object = pt_object.line_section
        # Search object.uri in line_section : line, start_point and end_point
        if object.line.uri in uris:
            return object.line
        if object.start_point.uri in uris:
            return object.start_point
        if object.end_point.uri in uris:
            return object.end_point
        # Search object.uri in line_section.routes
        for route in object.routes:
            if route.uri in uris:
                return route

        # Search object.uri in line_section.via
        for via in object.via:
            if via.uri in uris:
                return via
    return None


def get_object_in_line_section_by_type(pt_object, object_type):
    """
    verify if object exists in line_section
    :param pt_object: public transport object
    :param object_type: public transport object type
    :return: object found
    """
    if pt_object.type == object_type:
        return pt_object

    if pt_object.line_section:
        object = pt_object.line_section
        # Search object.uri in line_section : line, start_point and end_point
        if object.line.type == object_type:
            return object.line
        if object.start_point.type == object_type:
            return object.start_point
        if object.end_point.type == object_type:
            return object.end_point
        if object.routes and object.routes[0].type == object_type:
            return object.routes[0]
    return None


def get_object_in_line_section(pt_object, object_type, uris):
    """
    verify if object exists in line_section
    :param pt_object: public transport object
    :param object_type: public transport object type
    :param uris: public transport object uri
    :return: object found
    """
    # Verify object by object uri:
    if uris:
        return get_object_in_line_section_by_uri(pt_object, uris)

    # Verify object by object type:
    if object_type:
        return get_object_in_line_section_by_type(pt_object, object_type)

    return None


def group_impacts_by_pt_object(impacts, object_type, uris, get_pt_object):
    """
    :param impacts: list of impacts
    :param object_type: PTObject type example stop_area
    :return: list of implacts group by PTObject sorted by name
    """
    dictionary = {}
    for impact in impacts:
        for pt_object in impact.objects:
            if pt_object.type != 'line_section':
                result = is_pt_object_valid(pt_object, object_type, uris)
                if not result:
                    pt_object = None
            else:
                pt_object = get_object_in_line_section(pt_object, object_type, uris)
            if pt_object:
                if pt_object.uri in dictionary:
                    resp = dictionary[pt_object.uri]
                else:
                    nav_pt_object = get_pt_object(pt_object.uri, pt_object.type)
                    if nav_pt_object and 'name' in nav_pt_object:
                        name = nav_pt_object['name']
                    else:
                        name = None
                    resp = {
                        'id': pt_object.uri,
                        'type': pt_object.type,
                        'name': name,
                        'impacts': []
                    }
                    dictionary[pt_object.uri] = resp
                resp['impacts'].append(impact)
    result = dictionary.values()
    result.sort(key=lambda x: x['name'])
    return result


def parse_error(error):
    to_return = None
    try:
        to_return = error.message
    except AttributeError:
        to_return = str(error).replace("\n", " ")
    return to_return.decode('utf-8')


def get_uuid(value, name):
    if not id_format.match(value):
        raise ValidationError(
            "The {} argument value is not valid, you gave: {}".
            format(name, value)
        )
    return value


def send_disruption_to_navitia(disruption):
    if disruption.is_draft():
        return True

    feed_entity = populate_pb(disruption)
    return chaos.publisher.publish(
        feed_entity.SerializeToString(),
        disruption.contributor.contributor_code
    )


def get_client_code(request):
    if 'X-Customer-Id' in request.headers:
        return request.headers['X-Customer-Id']
    raise HeaderAbsent("The parameter X-Customer-Id does not exist in the header")


def get_contributor_code(request):
    if 'X-Contributors' in request.headers:
        return request.headers['X-Contributors']
    raise HeaderAbsent("The parameter X-Contributors does not exist in the header")


def get_token(request):
    if 'Authorization' in request.headers:
        return request.headers['Authorization']
    raise HeaderAbsent("The parameter Authorization does not exist in the header")


def get_coverage(request):
    if 'X-Coverage' in request.headers:
        return request.headers['X-Coverage']
    raise HeaderAbsent("The parameter X-Coverage does not exist in the header")


def get_one_period(date, weekly_pattern, begin_time, end_time, time_zone):
    week_day = datetime.weekday(date)
    if (len(weekly_pattern) > week_day) and (weekly_pattern[week_day] == '1'):
        begin_datetime = get_utc_datetime_by_zone(datetime.combine(date, begin_time), time_zone)
        if end_time < begin_time:
            date += timedelta(days=1)
        end_datetime = get_utc_datetime_by_zone(datetime.combine(date, end_time), time_zone)
        period = (begin_datetime, end_datetime)
        return period
    return None


def get_application_periods_by_pattern(start_date, end_date, weekly_pattern, time_slots, time_zone):
    result = []
    for time_slot in time_slots:
        begin_time = parse_time(time_slot['begin']).replace(tzinfo=None)
        end_time = parse_time(time_slot['end']).replace(tzinfo=None)
        temp_date = start_date
        while temp_date <= end_date:
            period = get_one_period(temp_date, weekly_pattern, begin_time, end_time, time_zone)
            if period:
                result.append(period)
            temp_date += timedelta(days=1)
    return result


def get_application_periods_by_periods(json_application_periods):
    result = []
    for app_periods in json_application_periods:
        period = (
            parse_datetime(app_periods['begin']).replace(tzinfo=None),
            parse_datetime(app_periods['end']).replace(tzinfo=None)
        )
        result.append(period)
    return result


def get_application_periods(json):
    result = []
    if 'application_period_patterns' in json and json['application_period_patterns']:
        for json_one_pattern in json['application_period_patterns']:
            start_date = parse_date(json_one_pattern['start_date'])
            end_date = parse_date(json_one_pattern['end_date'])
            weekly_pattern = json_one_pattern['weekly_pattern']
            time_slots = json_one_pattern['time_slots']
            time_zone = json_one_pattern['time_zone']
            result += get_application_periods_by_pattern(start_date, end_date, weekly_pattern, time_slots, time_zone)
    else:
        if 'application_periods' in json:
            result = get_application_periods_by_periods(json['application_periods'])
    return result


def get_pt_object_from_list(pt_object, list_objects):
    for object in list_objects:
        if pt_object.uri == object['id']:
            return object
    return None


def fill_impacts_used(result, impact):
    if impact not in result["impacts_used"]:
        result["impacts_used"].append(impact)


def add_network(result, nav_network, with_impacts=True):
    result["traffic_report"][nav_network['id']] = dict()
    result["traffic_report"][nav_network['id']]['network'] = nav_network
    if with_impacts:
        nav_network["impacts"] = []


def manage_network(result, impact, pt_object, navitia):
    if pt_object.uri in result["traffic_report"]:
        navitia_network = result["traffic_report"][pt_object.uri]["network"]
    else:
        navitia_network = navitia.get_pt_object(pt_object.uri, pt_object.type)
        if navitia_network:
            add_network(result, navitia_network)
        else:
            logging.getLogger(__name__).debug(
                'PtObject ignored : %s [%s].', pt_object.type, pt_object.uri
            )
    if navitia_network:
        navitia_network["impacts"].append(impact)
        fill_impacts_used(result, impact)


def get_navitia_networks(result, pt_object, navitia, types):
    networks = []
    for network_id, objects in result['traffic_report'].items():
        for key, value in objects.items():
            if key == types:
                for navitia_object in value:
                    if navitia_object['id'] == pt_object.uri and objects['network'] not in networks:
                        networks.append(objects['network'])
    if not networks:
        networks = navitia.get_pt_object(pt_object.uri, pt_object.type, 'networks')
    return networks


def manage_other_object(result, impact, pt_object, navitia, types, line_sections_by_objid, networks_filter):

    navitia_type = types
    pt_object_for_navitia_research = pt_object

    if types == 'line_sections':
        navitia_type = 'lines'
        pt_object_for_navitia_research = line_sections_by_objid[pt_object.id].line

    navitia_networks = get_navitia_networks(result, pt_object_for_navitia_research, navitia, navitia_type)
    if navitia_networks:
        for network in navitia_networks:
            if 'id' in network and network['id'] not in result["traffic_report"]:
                if networks_filter and network['id'] not in networks_filter:
                    continue
                add_network(result, network, False)
                result["traffic_report"][network['id']][types] = []

            if types in result["traffic_report"][network['id']]:
                list_objects = result["traffic_report"][network['id']][types]
            else:
                list_objects = []
            navitia_object = get_pt_object_from_list(pt_object, list_objects)
            if not navitia_object:
                navitia_object = navitia.get_pt_object(pt_object_for_navitia_research.uri,
                                                       pt_object_for_navitia_research.type)
                if navitia_object:
                    if types == 'line_sections':
                        navitia_object = create_line_section(navitia_object, line_sections_by_objid[pt_object.id])

                    navitia_object["impacts"] = []
                    navitia_object["impacts"].append(impact)
                    fill_impacts_used(result, impact)
                    if types not in result["traffic_report"][network['id']]:
                        result["traffic_report"][network['id']][types] = []
                    result["traffic_report"][network['id']][types].\
                        append(navitia_object)
                else:
                    logging.getLogger(__name__).debug(
                        'PtObject ignored : %s [%s], '
                        'not found in navitia.', pt_object.type, pt_object.uri
                    )
            else:
                navitia_object["impacts"].append(impact)
                fill_impacts_used(result, impact)
    else:
        logging.getLogger(__name__).debug(
            'PtObject ignored : %s [%s], '
            'not found network in navitia.', pt_object.type, pt_object.uri
        )


def create_line_section(navitia_object, line_section_obj):
    line_section = {
        "id": line_section_obj.id,
        "type": "line_section",
        "line_section":
            {
                "line": {
                    "id": navitia_object["id"],
                    "name": navitia_object["name"],
                    "type": 'line',
                    "code": navitia_object["code"]
                },
                "start_point": {
                    "id": line_section_obj.start_point.uri,
                    "type": line_section_obj.start_point.type
                },
                "end_point": {
                    "id": line_section_obj.end_point.uri,
                    "type": line_section_obj.end_point.type
                },
                "routes": line_section_obj.routes,
                "via": line_section_obj.via,
                "metas": line_section_obj.wordings
            }
    }
    return line_section


def get_traffic_report_objects(disruptions, navitia, line_sections_by_objid, networks_filter):
    """
    :param impacts: Sequence of impact (Database object)
    :return: dict
        {
            "network1": {
                "network": {
                    "id": "network1", "name": "Network 1", "impacts": []
                },
                "lines": [
                    {"id": "id1", "name": "line 1", "impacts": []},
                    {"id": "id2", "name": "line 2", "impacts": []}
                ],
                "stop_areas": [
                    {"id": "id1", "name": "stop area 1", "impacts": []},
                    {"id": "id2", "name": "stop area 2", "impacts": []}
                ],
                "stop_points": [
                    {"id": "id1", "name": "stop point 1", "impacts": []},
                    {"id": "id2", "name": "stop point 2, "impacts": []"}
                ]
            },
            ...
        }

    """
    collections = {
        "stop_area": "stop_areas",
        "line": "lines",
        "stop_point": "stop_points",
        "line_section": "line_sections",
    }

    result = {'traffic_report': {}, 'impacts_used': []}

    for disruption in disruptions:
        for impact in disruption.impacts:
            if impact.status == 'published':
                for pt_object in impact.objects:
                    if pt_object.type == 'network':
                        manage_network(result, impact, pt_object, navitia)
                    else:
                        if pt_object.type not in collections:
                            logging.getLogger(__name__).debug(
                                'PtObject ignored: %s [%s], not in collections %s',
                                pt_object.type, pt_object.uri, collections
                            )
                            continue
                        manage_other_object(result, impact, pt_object, navitia, collections[pt_object.type],
                                            line_sections_by_objid, networks_filter)

    return result


def get_clients_tokens(file_path):
    """
        Load clients and tokens from configuration file

        :param file_path: Client token file path
        :type file_path: str

        :return None if the configuration file doesn't exist (backward compatibility)
                or Object with all tokens for each client
        :rtype: object
    """

    # If the configuration doesn't exist, allow the action (backward compatibility)
    if not path.exists(file_path):
        return None

    with open(file_path, 'r') as tokens_file:
        clients_tokens = json.load(tokens_file)

    return clients_tokens


def client_token_is_allowed(clients_tokens, client_code, token):
    """
        Validates that the pair of client / token is allowed in configuration file

        :param clients_tokens: All information of tokens for each client
        :type file_name: object
        :param client_code: client code
        :type client_code: str
        :param token: Navitia token
        :type token: str

        :return True if the configuration file doesn't exist (backward compatibility)
                or the pair of client / token is allowed
        :rtype: bool

        :raise Unauthorized: When the pair of client / token isn't allowed
    """

    # If the configuration doesn't exist, allow the action (backward compatibility)
    if clients_tokens is None or (clients_tokens.has_key('master') is True and token in clients_tokens.get('master')):
        return True

    client_tokens = clients_tokens.get(client_code)

    # check if client configuration exists
    if client_tokens is None:
        error = "There is no configuration for this client. Provided client code : {}". format(client_code)
        raise_client_token_error(error)

    # check if token for this client exists
    if token not in client_tokens:
        error = "The client is not permited for this operation with this token. Provided client code : {}, token : {}".\
            format(client_code, token)
        raise_client_token_error(error)

    return True


def raise_client_token_error(message):
    """
        Logs message and raises an exception with this message

        :param message: An error message
        :type message: str
        :return: Nothing
        :rtype: Void
    """

    logging.getLogger(__name__).info(message)
    raise Unauthorized(message)

def filter_disruptions_by_ptobjects(disruptions, filter):
    """
        Do filter in disruptions.

        :param disruptions: Sequence of disruption (Database object)
        :param filter: json
        :return: Nothing
        :rtype: Void
    """
    for disruption in disruptions[:]:
        disruption_is_deleted = False
        for impact in (i for i in disruption.impacts if i.status == 'published'):
            for pt_object in impact.objects:
                if filter.get(pt_object.type + 's', []):
                    if pt_object.uri not in filter[pt_object.type + 's']:
                        disruption_is_deleted = True
                        break
                elif pt_object.type == 'line_section' and filter.get('lines', []):
                    if pt_object.uri[:-37] not in filter['lines']:
                        disruption_is_deleted = True
                        break
                else:
                    disruption_is_deleted = True
                    break
            if disruption_is_deleted:
                disruptions.remove(disruption)
                break

def uri_is_not_in_pt_object_filter(uri=None, pt_object_filter=None):
    result = not bool(uri and pt_object_filter)
    if not result:
        for key in pt_object_filter:
            if uri in pt_object_filter[key]:
                result = True
                break
    return not result


def has_impact_deleted_by_application_status(application_status, application_periods, current_time=get_current_time()):
    """
        Return if an impact should be deleted by his application_period.

        :param application_status: array
        :param application_periods: Sequence of application_period (Database object)
        :param current_time: DateTime
        :return: True if the impact does not activate in a certain time status ['past', 'ongoing', 'coming']
        :rtype: bool
    """
    impact_is_deleted = True
    for application_period in application_periods:
        if 'past' in application_status:
            if application_period.end_date < current_time:
                impact_is_deleted = False
                break
        if 'ongoing' in application_status:
            if application_period.start_date <= current_time and application_period.end_date >= current_time:
                impact_is_deleted = False
                break
        if 'coming' in application_status:
            if application_period.start_date > current_time:
                impact_is_deleted = False
                break
    return impact_is_deleted

def has_impact_deleted_by_pt_objects(pt_objects, uri=None, pt_object_filter=None):
    """
        Return if an impact should be deleted by his pt_objects.

        :param pt_objects: Sequence of pt_object (Database object)
        :param uri: string
        :param pt_object_filter: json
        :return: True if the impact does not contain a specific pt_object
        :rtype: bool
    """
    impact_is_deleted = bool(uri or pt_object_filter)
    if impact_is_deleted:
        for pt_object in pt_objects:
            pt_object_type = pt_object.type
            pt_object_uri = pt_object.uri
            if pt_object_type == 'line_section':
                pt_object_type = 'line'
                pt_object_uri = pt_object.uri[:-37]
            if (uri and pt_object_uri == uri and (not pt_object_filter or pt_object_filter.get(pt_object_type + 's', []) and uri in pt_object_filter[pt_object_type + 's'])) or \
                (not uri and pt_object_filter and pt_object_filter.get(pt_object_type + 's', []) and pt_object_uri in pt_object_filter[pt_object_type + 's']):
                impact_is_deleted = False
                break
    return impact_is_deleted

def filter_disruptions_on_impacts(
    disruptions,
    pt_object_filter=None,
    uri=None,
    current_time=get_current_time(),
    application_status = ['past', 'ongoing', 'coming']
    ):
    """
        Do filter in disruptions impacts.

        :param disruptions: Sequence of disruption (Database object)
        :param pt_object_filter: json
        :param uri: string
        :param current_time: DateTime
        :param application_status: array
        :return: Nothing
        :rtype: Void
    """
    if len(application_status) != 3:
        for disruption in disruptions[:]:
            deleted_impacts = []
            for impact in (i for i in disruption.impacts if i.status == 'published'):
                if has_impact_deleted_by_application_status(
                    application_status=application_status,
                    application_periods=impact.application_periods,
                    current_time=current_time) or \
                    has_impact_deleted_by_pt_objects(
                        pt_objects=impact.objects,
                        uri=uri,
                        pt_object_filter=pt_object_filter):
                    deleted_impacts.append(impact)
            for deleted_impact in deleted_impacts:
                disruption.impacts.remove(deleted_impact)
            if len(disruption.impacts) == 0:
                disruptions.remove(disruption)
