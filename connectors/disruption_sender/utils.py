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


from connectors.disruption_sender import chaos_pb2


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


def get_max_end_period(periods):
    return max([dt.end for dt in periods])


def get_min_start_period(periods):
    return min([dt.start for dt in periods])
