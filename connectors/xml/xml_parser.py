
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

import xml.etree.ElementTree as et
import logging


def parse_response(response):

    root = et.fromstring(response.content)
    try:
        event = root.find("Event")
        event_id = event.get("EventID")
        event_external_code = (root.find("./Event/EventExternalCode")).text
        status_action = (root.find("./Event/EventStatusAction")).text
    except AttributeError, e:
        logging.getLogger('parse_response').debug("response invalid, raison={raison} :".format(raison=str(e)))
        raise

    return {"event_id": event_id,
            "event_external_code": event_external_code,
            "status": status_action}
