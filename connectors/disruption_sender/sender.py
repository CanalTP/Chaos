
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
from connectors.disruption_sender.utils import is_valid_response
from sqlalchemy.orm.exc import NoResultFound
import logging
from connectors.disruption_sender.utils import is_impacts_with_pt_object


def delete_event(adjustit, event, local_event):
    request_response = adjustit.delete_event(event)
    if request_response.status_code == 200:
        response = parse_response(request_response)
        if is_valid_response(response):
            local_event.delete_impacts()
            Base.session.delete(local_event)
    else:
        logging.getLogger('send_disruption').\
            debug("The event {external_code} not deleted, Adjustit response_code = {code}.".
                  format(external_code=event.external_code, code=request_response.status_code))


def update_event(adjustit, event_pb, local_event):
    # Call update event in adjustit
    request_response = adjustit.update_event(event_pb, local_event)
    if request_response.status_code == 200:
        # Parse response adjustit
        response = parse_response(request_response)
        if is_valid_response(response):
            temp_impact_list = []
            if "impacts" in response:
                for resp_impact in response["impacts"]:
                    # Get Impact from protocol buffer
                    impact_pb = event_pb.get_impact_by_pt_object(resp_impact["pt_object_uri"])
                    chaos_new_id = "".join([impact_pb.pt_object.external_code, impact_pb.id])
                    temp_impact_list.append(chaos_new_id)
                    #Get local impact
                    local_impact = local_event.get_impact_by_new_id(chaos_new_id)
                    if not local_impact:
                        impact = models.Impact(event_pb.external_code,
                                               chaos_new_id,
                                               resp_impact["impact_id"])
                        local_event.impacts.append(impact)
            Base.session.commit()
            # Delete all impacts not in protocol buffer and exists in local database
            for local_impact in local_event.impacts:
                if local_impact.chaos_new_id not in temp_impact_list:
                    request_response = adjustit.delete_impact(local_impact.adjustit_impact_id)
                    if request_response.status_code == 200:
                        local_event.impacts.remove(local_impact)
                        Base.session.commit()
    else:
        logging.getLogger('send_disruption').\
            debug("The event {external_code} not updated, Adjustit response_code = {code}.".
                  format(external_code=event_pb.external_code, code=request_response.status_code))


def add_event(adjustit, event):
    request_response = adjustit.add_event(event)
    if request_response.status_code == 200:
        response = parse_response(request_response)
        if is_valid_response(response):
            local_event = models.DisruptionEvent(event.external_code)
            if "impacts" in response:
                for resp_impact in response["impacts"]:
                    impact_adjustit = event.get_impact_by_pt_object(resp_impact["pt_object_uri"])
                    impact = models.Impact(event.external_code,
                                               impact_adjustit.pt_object.uri + resp_impact["impact_id"],
                                               resp_impact["impact_id"])
                    local_event.impacts.append(impact)
            Base.session.add(local_event)
            Base.session.commit()
    else:
        logging.getLogger('send_disruption').\
            debug("The event {external_code} not added, Adjustit response_code = {code}.".
                  format(external_code=event.external_code, code=request_response.status_code))


def send_disruption(disruption, adjustit):
    """
    Method to consume disruption element from rabbitMQ and to send it to Adjustit.
    """
    events = get_events(disruption)
    for event_pb in events:
        local_event = None
        try:
            local_event = models.DisruptionEvent.get(event_pb.external_code)
        except NoResultFound:
            logging.getLogger('send_disruption').debug("The event {external_code} not exist in database.".
                                                       format(external_code=event_pb.external_code))
        if event_pb.is_deleted:
            delete_event(adjustit, event_pb, local_event)
        else:
            if not is_impacts_with_pt_object(event_pb.impacts):
                logging.getLogger('send_disruption').\
                    debug("The event {external_code} is not valid, impact without ptobject.".
                          format(external_code=event_pb.external_code))
                continue

            if local_event:
                update_event(adjustit, event_pb, local_event)
            else:
                add_event(adjustit, event_pb)