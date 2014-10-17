
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
from connectors import connector_config
import logging
from datetime import datetime
import re

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
        self.format_date = "%Y|%m|%d|%H|%M|%S"
        self.format_time = "%H|%M|%S"

    # formatting URLs
    def format_url_impacts_event(self, event, local_event):
        impacts = ''
        if event.impacts:
            enum_impacts = list(enumerate(event.impacts, start=1))
            impact_list = []
            for enum_impact in enum_impacts:
                str_one_url = ''
                local_impact = local_event.get_impact_by_new_id(enum_impact[1].pt_object.external_code +
                                                                enum_impact[1].id)
                if len(event.impacts) == 1:
                    str_one_url = "impact="
                else:
                    str_one_url = "impact" + str(enum_impact[0]) + "="
                if local_impact:
                    str_one_url = str_one_url + "ImpactID=" + str(local_impact.adjustit_impact_id) + impact_separator
                impact_list.append(str_one_url + self.format_url_impact(enum_impact[1]))

            impacts = separator.join(impact_list)
        return impacts

    def format_url_impact(self, impact):
        impact_url = Impact_format["impact"].\
            format(impact=impact,
                   start=self.datetime_to_string(impact.application_start_date),
                   end=self.datetime_to_string(impact.application_end_date),
                   daily_start_time=self.time_to_string(impact.daily_start_time),
                   daily_end_time=self.time_to_string(impact.daily_end_time))
        messages = ''
        if impact.impact_broad_casts:
            message_list = []
            enum_messages = list(enumerate(impact.impact_broad_casts, start=1))
            for enum_message in enum_messages:
                str_one_url = ''
                if len(impact.impact_broad_casts) == 1:
                    str_one_url = "broadcast="
                else:
                    str_one_url = "broadcast" + str(enum_message[0]) + "="
                message_list.append(str_one_url + self.format_url_message(enum_message[1]))

            messages = messages_separator.join(message_list)
        if messages:
            return impact_separator.join([impact_url, messages])
        return impact_url

    def format_url_message(self, message):
        return Impact_format["message"].format(
            message=message,
            push_date=self.datetime_to_string(message.push_date))

    # Utils AdjustIt
    def time_to_string(self, value):
        str = None
        try:
            str = value.strftime(self.format_time)
        except TypeError:
            raise TypeError("The argument value is not valid, you gave: {}".format(value))
        return str

    def datetime_to_string(self, value):
        str = None
        try:
            date = datetime.fromtimestamp(value)
            str = date.strftime(self.format_date)
        except TypeError:
            raise TypeError("The argument value is not valid, you gave: {}".format(value))
        return str

    def is_valid_response(self, resp):

        if resp and ("event_status" in resp) and re.search("ok", resp["event_status"], re.IGNORECASE):
            return True
        return False

    # Actions AdjustIt
    def delete_event(self, event):
        url = actions["deleteevent"].format(url=self.url,
                                            interface=self.interface,
                                            event=event)
        return self.call_adjustit(url)

    def add_event(self, event):
        url = actions["addevent"].format(url=self.url,
                                         interface=self.interface,
                                         event=event,
                                         start=self.datetime_to_string(event.publication_start_date),
                                         end=self.datetime_to_string(event.publication_end_date))
        return self.call_adjustit(url)

    def update_event(self, event_pb, local_event):
        url = actions["updateevent"].format(url=self.url,
                                            interface=self.interface,
                                            event=event_pb,
                                            start=self.datetime_to_string(event_pb.publication_start_date),
                                            end=self.datetime_to_string(event_pb.publication_end_date))
        impacts = self.url_formatting.format_url_impacts_event(event_pb, local_event)
        if impacts:
            url = separator.join([url, impacts])
        return self.call_adjustit(url)

    def delete_impact(self, adjustit_impact_id):
        url = actions["deleteimpact"].format(url=self.url,
                                             provider=self.provider,
                                             interface=self.interface,
                                             impactid=adjustit_impact_id)
        return self.call_adjustit(url)

    def delete_broad_cast(self, impact_id, media_id):
        url = actions["deletebroadcast"].format(url=self.url,
                                             provider=self.provider,
                                             interface=self.interface,
                                             impactid=impact_id,
                                             mediaid=media_id)
        return self.call_adjustit(url)

    def call_adjustit(self, url):
        try:
            response = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException:
            logging.getLogger(__name__).exception('call_adjustit failed, url :{}'.format(url))
            #currently we reraise the previous exceptions
            raise
        return response