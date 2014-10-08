
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


class AdjustIt(object):

    def __init__(self, config):
        self.config = config
        self.sub_url = "{url}/api?action={action}&providerextcode={provider}&interface={interface}"
        adjustit = config["adjustit"]
        self.timeout = adjustit["timeout"]
        self.url = adjustit["url"]
        self.provider = adjustit["provider"]
        self.interface = adjustit["interface"]

    def delete_event(self, event):
        if event:
            url = self.sub_url.format(action="deleteevent", url=self.url, provider=self.provider, interface=self.interface) +\
            "&eventextcode={eventextcode}"
            url = url.format(eventextcode=event.external_code)
            self.call_adjustit(url)
        else:
            logging.getLogger(__name__).exception('Delete_vent: Event not valid')

    def call_adjustit(self, url):
        try:
            logging.getLogger('call_adjustit').debug("call url :"+url)
            response = requests.get(url, timeout=self.timeout)
        except (requests.exceptions.RequestException):
            logging.getLogger(__name__).exception('call to adjustit failed, url :' + url)
            #currently we reraise the previous exceptions
            raise
