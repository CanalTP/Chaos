
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
from connectors.disruption_sender.utils import get_max_end_period, get_min_start_period


class MsgMedia(object):
    def __init__(self):
        self.language = None
        self.media = None


class ImpactBroadCast(object):
    def __init__(self):
        self.msg_media = None
        self.title = None
        self.msg = None


class TObjectRef(object):
    def __init__(self):
        self.external_code = None
        self.type = None


class Provider(object):
    def __init__(self):
        self.name = None


class Impact(object):
    def __init__(self):
        self.external_code = None
        self.creation_date = None
        self.modification_date = None
        self.application_start_date = None
        self.application_end_date = None
        self.daily_start_date = None
        self.daily_end_date = None
        self.status = None
        self.pt_object = None
        self.impact_broad_casts = []

    def fill_message(self, messages):
        for message in messages:
            msg = ImpactBroadCast()
            msg.title = message.text
            msg.msg_media = MsgMedia()
            msg.msg_media.media = message.channel.name
            self.impact_broad_casts.append(msg)


class Event(object):
    def __init__(self):
        self.is_deleted = False
        self.title = None
        self.external_code = None
        self.creation_date = None
        self.modification_date = None
        self.publication_start_date = None
        self.publication_end_date = None
        self.impacts = []
        self.provider = None

    def fill_event(self, entity):

        self.is_deleted = entity.is_deleted
        self.external_code = entity.id

        if not entity.is_deleted:
            disruption_pb = entity.Extensions[chaos_pb2.disruption]
            self.external_code = disruption_pb.id
            self.creation_date = disruption_pb.created_at
            if disruption_pb.updated_at:
                self.modification_date = disruption_pb.updated_at
            self.publication_start_date = disruption_pb.publication_period.start
            if disruption_pb.publication_period.end:
                self.publication_end_date = disruption_pb.publication_period.end
            self.title = disruption_pb.reference
            for impact_pb in disruption_pb.impacts:
                for pt_object in impact_pb.informed_entities:
                    impact = Impact()
                    impact.creation_date = impact_pb.created_at
                    impact.modification_date = impact_pb.updated_at
                    impact.fill_message(impact_pb.messages)
                    impact.application_start_date = get_min_start_period(impact_pb.application_periods)
                    impact.application_end_date = get_max_end_period(impact_pb.application_periods)
                    impact.pt_object = TObjectRef()
                    impact.pt_object.external_code = pt_object.uri
                    impact.pt_object.type = pt_object.pt_object_type
                    self.impacts.append(impact)


def get_events(disruption):
    events = []
    if disruption and disruption.entity:
        for entity in disruption.entity:
            event = Event()
            event.fill_event(entity)
            events.append(event)
    return events
