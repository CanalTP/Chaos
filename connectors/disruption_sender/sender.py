
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


class Sender(object):
    """
    Class to consume disruption element from rabbitMQ and to send it to Adjustit.
    """
    def __init__(self, config, adjustit):
        self.config = config
        self.urls = []
        self.adjustit = adjustit

    def fill_urls(self, disruption):
        if disruption and disruption.entity:
            for entity in disruption.entity:
                # Delete disruption
                url = None
                if entity.is_deleted:
                    url = self.adjustit.url_by_action("deleteevent")
                    if url:
                        url = url.format(eventextcode=entity.id)
                else:
                    disruption_pb = entity.Extensions[chaos_pb2.disruption]
                    url = self.adjustit.url_by_action("addevent")
                    if url:
                        url = url.format(eventextcode=disruption_pb.id, reference=disruption_pb.reference)
                if url:
                    self.urls.append(url)

    def send_disruption(self, disruption):
        self.fill_urls(disruption)
        self.send()

    def send(self):
        for url in self.urls:
            self.adjustit.call_adjustit(url)
