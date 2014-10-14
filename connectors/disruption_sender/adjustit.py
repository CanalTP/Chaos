
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

import requests
from utils import convert_to_adjusitit_date
from exceptions import RequestsException

separator = "&"

actions = {
    "deleteevent": separator.join(["{url}/api?action=deleteevent",
                                   "providerextcode={provider}",
                                   "interface={interface}",
                                   "eventextcode={eventextcode}"]),

    "addevent": separator.join(["{url}/api?action=addevent",
                                "providerextcode={provider}",
                                "interface={interface}",
                                "eventextcode={eventextcode}",
                                "eventtitle={title}",
                                "publicationStartDate={start}",
                                "publicationEndDate={end}",
                                "eventlevelid={eventlevelid}"]),

    "updateevent": separator.join(["{url}/api?action=updateevent",
                            "providerextcode={provider}",
                            "interface={interface}",
                            "eventextcode={eventextcode}",
                            "eventtitle={title}",
                            "publicationStartDate={start}",
                            "publicationEndDate={end}",
                            "eventlevelid={eventlevelid}"]),

    "closeevent": separator.join(["{url}/api?action=closeevent",
                            "providerextcode={provider}",
                            "interface={interface}",
                            "eventextcode={eventextcode}",
                            "forceclose=true"]),

    "deleteimpact": separator.join(["{url}/api?action=deleteimpact",
                                "providerextcode={provider}",
                                "interface={interface}",
                                "impactid={impactid}"])
}


class AdjustIt(object):

    def __init__(self, config):
        self.eventlevel = config["eventlevel"]
        self.timeout = config["adjustit"]["timeout"]
        self.url = config["adjustit"]["url"]
        self.provider = config["adjustit"]["provider"]
        self.interface = config["adjustit"]["interface"]

    def delete_event(self, event):
        url = actions["deleteevent"].format(url=self.url,
                                            provider=self.provider,
                                            interface=self.interface,
                                            eventextcode=event.external_code)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def add_event(self, event):
        url = actions["addevent"].format(url=self.url,
                                         provider=self.provider,
                                         interface=self.interface,
                                         eventextcode=event.external_code,
                                         title=event.title,
                                         start=convert_to_adjusitit_date(event.publication_start_date),
                                         end=convert_to_adjusitit_date(event.publication_end_date),
                                         eventlevelid=self.eventlevel)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def update_event(self, event):
        url = actions["updateevent"].format(url=self.url,
                                            provider=self.provider,
                                            interface=self.interface,
                                            eventextcode=event.external_code,
                                            title=event.title,
                                            start=convert_to_adjusitit_date(event.publication_start_date),
                                            end=convert_to_adjusitit_date(event.publication_end_date),
                                            eventlevelid=self.eventlevel)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def close_event(self, event):
        url = actions["closeevent"].format(url=self.url,
                                            provider=self.provider,
                                            interface=self.interface,
                                            eventextcode=event.external_code)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def delete_impact(self, adjustit_impact_id):
        url = actions["deleteimpact"].format(url=self.url,
                                             provider=self.provider,
                                             interface=self.interface,
                                             impactid=adjustit_impact_id)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response
