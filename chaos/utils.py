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

from flask import url_for, g
from functools import wraps
from datetime import datetime, timedelta
from aniso8601 import parse_datetime, parse_time, parse_date
import uuid
import flask
from chaos.formats import id_format
from jsonschema import ValidationError
from chaos.populate_pb import populate_pb
from chaos.exceptions import HeaderAbsent
import chaos
import pytz
import logging
from math import ceil


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
                            start_page=ceil(resultcount / per_page),
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
    except:
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
        tz = pytz.timezone(time_zone)

        return tz.localize(value).astimezone(pytz.utc).replace(tzinfo=None)
    except:
        raise ValueError("The {} argument value is not valid, you gave: {}"
                         .format(value, time_zone))


def get_current_time():
    """
        Get current time global variable
        :return: DateTime format '2014-04-31T16:52:00'
    """
    if 'current_time' in g and g.current_time:
        return g.current_time
    else:
        return datetime.utcnow()


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
        else:
            return (pt_object.type == object_type)
    elif uris:
        return (pt_object.uri in uris)
    else:
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
                pt_object = get_object_in_line_section(pt_object,  object_type, uris)
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
                'PtObject ignored : {type} [{uri}].'.
                format(type=pt_object.type, uri=pt_object.uri)
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
                    if navitia_object['id'] == pt_object.uri:
                        if objects['network'] not in networks:
                            networks.append(objects['network'])
    if len(networks) == 0:
        networks = navitia.get_pt_object(pt_object.uri, pt_object.type, 'networks')
    return networks


def manage_other_object(result, impact, pt_object, navitia, types):

    navitia_type = types
    pt_object_for_navitia_research = pt_object

    if types == 'line_sections':
        navitia_type = 'lines'
        pt_object_for_navitia_research = pt_object.line_section.line

    navitia_networks = get_navitia_networks(result, pt_object_for_navitia_research, navitia, navitia_type)
    if navitia_networks:
        for network in navitia_networks:
            if 'id' in network and network['id'] not in result["traffic_report"]:
                add_network(result, network, False)
                result["traffic_report"][network['id']][types] = []

            if types in result["traffic_report"][network['id']]:
                list_objects = result["traffic_report"][network['id']][types]
            else:
                list_objects = []
            navitia_object = get_pt_object_from_list(pt_object, list_objects)
            if not navitia_object:
                navitia_object = navitia.get_pt_object(pt_object_for_navitia_research.uri, pt_object_for_navitia_research.type)
                if navitia_object:
                    if types == 'line_sections':
                        navitia_object = create_line_section(navitia_object, pt_object)

                    navitia_object["impacts"] = []
                    navitia_object["impacts"].append(impact)
                    fill_impacts_used(result, impact)
                    if types not in result["traffic_report"][network['id']]:
                        result["traffic_report"][network['id']][types] = []
                    result["traffic_report"][network['id']][types].\
                        append(navitia_object)
                else:
                    logging.getLogger(__name__).debug(
                        'PtObject ignored : {type} [{uri}], '
                        'not found in navitia.'.
                        format(type=pt_object.type, uri=pt_object.uri)
                    )
            else:
                navitia_object["impacts"].append(impact)
                fill_impacts_used(result, impact)
    else:
        logging.getLogger(__name__).debug(
            'PtObject ignored : {type} [{uri}], '
            'not found network in navitia.'.
            format(type=pt_object.type, uri=pt_object.uri)
        )


def create_line_section(navitia_object, pt_object):
    line_section = {
        "id": pt_object.line_section.id,
        "type": "line_section",
        "line_section":
            {
                "line": {
                    "id": navitia_object["id"],
                    "name": navitia_object["name"],
                    "type": 'line',
                    "code": navitia_object["code"]
                },
                "start_point":
                    {
                        "id": pt_object.line_section.start_point.uri,
                        "type": pt_object.line_section.start_point.type
                    },
                "end_point":
                    {
                        "id": pt_object.line_section.end_point.uri,
                        "type": pt_object.line_section.end_point.type
                    },
                "routes": pt_object.line_section.routes,
                "via": pt_object.line_section.via,
                "metas": pt_object.line_section.wordings
            }
    }
    return line_section


def get_traffic_report_objects(impacts, navitia):
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
    for impact in impacts:
        for pt_object in impact.objects:
            if pt_object.type == 'network':
                manage_network(result, impact, pt_object, navitia)
            else:
                if pt_object.type not in collections:
                    logging.getLogger(__name__).debug(
                        'PtObject ignored: {type} [{uri}], not in collections {col}'.
                        format(type=pt_object.type, uri=pt_object.uri, col=collections)
                    )
                    continue
                manage_other_object(result, impact, pt_object, navitia, collections[pt_object.type])
    return result
