
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
from utils import convert_to_adjusitit_date,\
    convert_to_adjusitit_time
from exceptions import RequestsException
from connectors import connector_config
import logging

separator = "&"
impact_separator = "|-|"
message_separator = "|.|"
messages_separator = "||"

actions = {

    "getevent": separator.join(["{url}/api?action=getevent",
                                   "providerextcode={event.provider}",
                                   "interface={interface}",
                                   "eventextcode={event.external_code}"]),

    "deleteevent": separator.join(["{url}/api?action=deleteevent",
                                   "providerextcode={event.provider}",
                                   "interface={interface}",
                                   "eventextcode={event.external_code}",
                                   "forcedelete=true"]),

    "addevent": separator.join(["{url}/api?action=addevent",
                                "providerextcode={event.provider}",
                                "interface={interface}",
                                "eventextcode={event.external_code}",
                                "eventtitle={event.title}",
                                "publicationStartDate={start}",
                                "publicationEndDate={end}",
                                "eventlevelid={event.event_level_id}"]),

    "updateevent": separator.join(["{url}/api?action=updateevent",
                            "providerextcode={event.provider}",
                            "interface={interface}",
                            "eventextcode={event.external_code}",
                            "eventtitle={event.title}",
                            "publicationStartDate={start}",
                            "publicationEndDate={end}",
                            "eventlevelid={event.event_level_id}"]),

    "closeevent": separator.join(["{url}/api?action=closeevent",
                            "providerextcode={event.provider}",
                            "interface={interface}",
                            "eventextcode={event.external_code}",
                            "forceclose=true"]),

    "deleteimpact": separator.join(["{url}/api?action=deleteimpact",
                                "providerextcode={provider}",
                                "interface={interface}",
                                "impactid={impactid}"]),

    "deletebroadcast": separator.join(["{url}/api?action=deletebroadcast",
                                "providerextcode={provider}",
                                "interface={interface}" +
                                "broadcast=impactid={impactid}" +
                                message_separator + "mediaid={mediaid}"])

}


Impact_format = {
    "impact": impact_separator.join(["ImpactStartDate={start}",
                                     "ImpactEndDate={end}",
                                     "DailyStartTime={daily_start_time}",
                                     "DailyEndTime={daily_end_time}",
                                     "Duration={impact.duration}",
                                     "TCOExtCode={impact.pt_object.external_code}",
                                     "TCOType={impact.pt_object.type}",
                                     "State={impact.status}",
                                     "ImpactActiveDays=1111111" #???
                                     ]),
    "message": message_separator.join(["impacttitle={message.title}",
                                       "pushdate={push_date}",
                                       "mediaid={message.msg_media.id}",
                                       "freemsg={message.msg}"])
}


class AdjustIt(object):

    def __init__(self):
        self.timeout = connector_config["adjustit"]["timeout"]
        self.url = connector_config["adjustit"]["url"]
        self.interface = connector_config["adjustit"]["interface"]
        self.provider = connector_config["other"]["provider"]

    def get_event(self, event):
        url = actions["getevent"].format(url=self.url,
                                            interface=self.interface,
                                            event=event)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def delete_event(self, event):
        url = actions["deleteevent"].format(url=self.url,
                                            interface=self.interface,
                                            event=event)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def add_event(self, event):
        url = actions["addevent"].format(url=self.url,
                                         interface=self.interface,
                                         event=event,
                                         start=convert_to_adjusitit_date(event.publication_start_date),
                                         end=convert_to_adjusitit_date(event.publication_end_date))
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response

    def update_event(self, event_pb, local_event):
        url = actions["updateevent"].format(url=self.url,
                                            interface=self.interface,
                                            event=event_pb,
                                            start=convert_to_adjusitit_date(event_pb.publication_start_date),
                                            end=convert_to_adjusitit_date(event_pb.publication_end_date))
        if event_pb.impacts:
            # Impacts
            impact_count = 1
            str_impact = ''
            for impact in event_pb.impacts:
                local_impact = local_event.get_impact_by_new_id(impact.pt_object.external_code + impact.id)
                if len(event_pb.impacts) == 1:
                    str_impact = "impact="
                else:
                    str_impact = str_impact + "impact" + str(impact_count) + "="
                if local_impact:
                    str_impact = str_impact + "ImpactID=" + str(local_impact.adjustit_impact_id) + impact_separator

                str_impact = str_impact + Impact_format["impact"].\
                    format(impact=impact,
                           start=convert_to_adjusitit_date(impact.application_start_date),
                           end=convert_to_adjusitit_date(impact.application_end_date),
                           daily_start_time=convert_to_adjusitit_time(impact.daily_start_time),
                           daily_end_time=convert_to_adjusitit_time(impact.daily_end_time))
                url = separator.join([url, str_impact])
                impact_count = impact_count + 1
                # Messages
                msg_count = 1
                if impact.impact_broad_casts:
                    str_message = ''
                    for message in impact.impact_broad_casts:
                        if len(impact.impact_broad_casts) == 1:
                            str_message = "broadcast="
                        else:
                            str_message = str_message + "broadcast" + str(msg_count) + "="
                        str_message = str_message +\
                                      Impact_format["message"].format(
                                          message=message,
                                          push_date=convert_to_adjusitit_date(message.push_date))
                        if msg_count != len(impact.impact_broad_casts):
                            str_message = str_message + messages_separator
                        msg_count = msg_count + 1

                    url = url + impact_separator + str_message
        try:
            logging.getLogger('update_event').debug(url)
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

    def delete_broad_cast(self,impact_id, media_id):
        url = actions["deletebroadcast"].format(url=self.url,
                                             provider=self.provider,
                                             interface=self.interface,
                                             impactid=impact_id,
                                             mediaid=media_id)
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as e:
            raise RequestsException(str(e))
            response = None
        return response
