
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
import logging
from utils import convert_to_adjusitit_date
from data import get_events

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
                                "publicationEndDate={end}"])
}


class AdjustIt(object):

    def __init__(self, config):
        self.config = config
        self.timeout = config["adjustit"]["timeout"]
        self.url = config["adjustit"]["url"]
        self.provider = config["adjustit"]["provider"]
        self.interface = config["adjustit"]["interface"]

    def delete_event(self, event):
        if event:
            url = actions["deleteevent"].format(url=self.url,
                                                provider=self.provider,
                                                interface=self.interface,
                                                eventextcode=event.external_code)
            self.call_adjustit(url)
        else:
            logging.getLogger(__name__).exception('delete_vent: Event not valid')

    def add_event(self, event):
        if event:
            url = actions["addevent"].format(url=self.url,
                                             provider=self.provider, interface=self.interface,
                                             eventextcode=event.external_code,
                                             title=event.title,
                                             start=convert_to_adjusitit_date(event.publication_start_date),
                                             end=convert_to_adjusitit_date(event.publication_end_date))
            self.call_adjustit(url)
        else:
            logging.getLogger(__name__).exception('add_vent: Event not valid')

    def call_adjustit(self, url):
        try:
            logging.getLogger('call_adjustit').debug("call url :" + url)
            response = requests.get(url, timeout=self.timeout)
        except (requests.exceptions.RequestException):
            logging.getLogger(__name__).exception('call to adjustit failed, url :' + url)
            #currently we reraise the previous exceptions
            raise

    def send_disruptions(self, disruptions):
        events = get_events(disruptions)
        for event in events:
            if event.is_deleted:
                self.delete_event(event)
