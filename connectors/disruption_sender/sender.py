
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

from data import get_events
from connectors.xml.xml_parser import parse_response
from connectors.database import models
from connectors.database.database import Base
from sqlalchemy.orm.exc import NoResultFound
import logging
import re


def send_disruption(disruption, adjustit):
    """
    Method to consume disruption element from rabbitMQ and to send it to Adjustit.
    """
    events = get_events(disruption)
    for event in events:
        local_event = None
        try:
            local_event = models.DisruptionEvent.get(event.external_code)
        except NoResultFound:
            logging.getLogger('send_disruption').debug("The event {external_code} not exist in database.".
                                                       format(external_code=event.external_code))
        if event.is_deleted:
            request_response = adjustit.delete_event(event)
            if request_response.status_code == 200:
                response = parse_response(request_response)
                if "status" in response and re.search('ok', response["status"], re.IGNORECASE):
                    local_event.delete_impacts()
                    Base.session.delete(local_event)
        else:
            if local_event:
                request_response = adjustit.update_event(event)
                if request_response.status_code == 200:
                    response = parse_response(request_response)
                    if "status" in response and re.search('ok', response["status"], re.IGNORECASE):
                        local_event.chaos_updated_at = event.modification_date
                        Base.session.commit()
            else:
                request_response = adjustit.add_event(event)
                if request_response.status_code == 200:
                    response = parse_response(request_response)
                    if "status" in response and re.search('ok', response["status"], re.IGNORECASE):
                        local_event = models.DisruptionEvent(event.external_code)
                        Base.session.add(local_event)
                        Base.session.commit()
