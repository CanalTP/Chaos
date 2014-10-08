
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

from chaos import chaos_pb2


class MsgMedia(object):
    def __init__(self):
        self.language = None
        self.media = None


class ImpactBroadCast(object):
    def __init__(self):
        self.msg_media = None
        self.title = None
        self.msg = None
        self.push = None


class TObjectRef(object):
    def __init__(self):
        self.external_code = None
        self.type = None


class Provider(object):
    def __init__(self):
        self.name = None


class Impact(object):
    def __init__(self):
        self.object = None
        self.impact_broad_cast = None
        self.external_code = None
        self.creation_date = None
        self.modification_date = None
        self.application_start_date = None
        self.application_end_date = None
        self.daily_start_date = None
        self.daily_end_date = None
        self.status = None


class Event(object):
    def __init__(self):
        self.is_deleted = False
        self.title = None
        self.external_code = None
        self.creation_date = None
        self.modification_date = None
        self.publication_start_date = None
        self.publication_end_date = None
        self.impact = []
        self.provider = None

    def fill_event(self, entity):
        if entity.is_deleted:
            self.is_deleted = True
            self.external_code = entity.id
        else:
            disruption_pb = entity.Extensions[chaos_pb2.disruption]
            self.external_code = disruption_pb.id
            self.creation_date = disruption_pb.created_at
            if disruption_pb.updated_at:
                self.modification_date = disruption_pb.updated_at
            self.publication_start_date = disruption_pb.publication_period.start
            if disruption_pb.publication_period.end:
                self.publication_end_date = disruption_pb.publication_period.end
            self.title = disruption_pb.reference


class Data(object):
    def __init__(self):
        self.events = []

    def fill_Events(self, disruption):
        if disruption and disruption.entity:
            for entity in disruption.entity:
                event = Event()
                event.fill_event(entity)
                self.events.append(event)
