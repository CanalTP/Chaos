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

from flask import current_app
import flask_restful
import requests
import logging

class PTobjectHelper(object):
    def __init__(self):
        self.jormungandr_url = current_app.config.get('JORMUNGANDR_URL')
        self.jormungandr_token = current_app.config.get('JORMUNGANDR_TOKEN')
        self.coverage = current_app.config.get('COVERAGE')
        self._collections = {"stop_point": "stop_points",
                             "VehicleJourney": "vehicle_journeys",
                             "line": "lines",
                             "network": "networks",
                             "stop_area": "stop_areas"}

    def get_collection(self, object_type):
        if object_type in self._collections.keys():
            return self._collections[object_type]
        return None

    def format_url(self,uri, object_type):
        collection = self.get_collection(object_type)
        if collection:
            return "%s/v1/coverage/%s/%s/%s" % (self.jormungandr_url, self.coverage, collection, uri)
        return None

    def get_response(self, url):
        if self.jormungandr_token:
            auth = (self.jormungandr_token, None)
        else:
            auth = None
        return requests.get(url, auth=auth)

    def is_object_valide(self, uri, object_type):
        url = self.format_url(uri, object_type)
        if url:
            response = self.get_response(url)
        logging.getLogger(__name__).debug("call %s" % url)
        if response:
            json = response.json()
            collection = self.get_collection(object_type)
            if collection in json and len(json[collection]) > 0:
                return True
            return False
        logging.getLogger(__name__).debug("url %s is not accessible" % url)
        return False
