#  Copyright (c) 2001-2014, Canal TP and/or its affiliates. All rights reserved.
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

from datetime import datetime
import re
from connectors.disruption_sender import chaos_pb2, gtfs_realtime_pb2

format_date = "%Y|%m|%d|%H|%M|%S"
format_time = "%H|%M|%S"


def pt_object_type_to_string(pt_object_type):
    collection = {
        chaos_pb2.PtObject.network: "Network",
        chaos_pb2.PtObject.stop_area: "StopArea",
        chaos_pb2.PtObject.line: "Line",
        chaos_pb2.PtObject.route: "Route"
    }
    if pt_object_type in collection:
        return collection[pt_object_type]
    return None

def convert_to_adjusitit_time(value):
    str = None
    try:
        str = value.strftime(format_time)
    except TypeError:
        raise TypeError("The argument value is not valid, you gave: {}".format(value))
    return str


def convert_to_adjusitit_date(value):
    str = None
    try:
        date = datetime.fromtimestamp(value)
        str = date.strftime(format_date)
    except TypeError:
        raise TypeError("The argument value is not valid, you gave: {}".format(value))
    return str


def get_max_end_period(periods):
    return max([dt.end for dt in periods])


def get_min_start_period(periods):
    return min([dt.start for dt in periods])


def is_valid_response(resp):

    if resp and ("event_status" in resp) and re.search("ok", resp["event_status"], re.IGNORECASE):
        return True
    return False


def is_impacts_with_pt_object(impacts):
    """
    :param impacts:  list of impact
    :return: True : if all impacts with ptobject
    """
    if not impacts:
        return True
    else:
        for impact in impacts:
            if not impact.pt_object:
                return False
    return True