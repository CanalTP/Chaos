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

import logging
import logging.config
import json
import sys


class Config(object):
    """
    class de configuration de disruption_sender
    """
    def __init__(self):
        self.navitia_url = None
        self.navitia_coverage = None
        self.navitia_token = None
        self.adjustit_url = None
        self.adjustit_timeout = None
        self.adjustit_provider = None
        self.adjustit_interface = None
        self.exchange_name = None
        self.queue_name = None
        self.log_file = None
        self.rt_topics = []

    def load(self, config_file):
        """
        Initialize from a configuration file.
        If not valid raise an error.
        """
        config_data = json.loads(open(config_file).read())

        if 'logger' in config_data:
            logging.config.dictConfig(config_data['logger'])
        else:  # Default is std out
            handler = logging.StreamHandler(stream=sys.stdout)
            logging.getLogger().addHandler(handler)
            logging.getLogger().setLevel('INFO')

        if 'exchange-name' in config_data:
            self.exchange_name = config_data['exchange-name']
        else:
            raise ValueError("Config is not valid, exchange-name is needed")

        if 'queue-name' in config_data:
            self.queue_name = config_data['queue-name']
        else:
            raise ValueError("Config is not valid, queue-name is needed")

        if 'navitia' in config_data:
            navitia = config_data['navitia']
            if 'url' in navitia and 'coverage' in navitia and 'token' in navitia:
                self.navitia_url = navitia['url']
                self.navitia_coverage = navitia['coverage']
                self.navitia_token = navitia['token']
            else:
                raise ValueError("Config is not valid, (url,coverage,token) is needed")
        else:
            raise ValueError("Config is not valid, navitia is needed")

        if 'adjustit' in config_data:
            adjustit = config_data['adjustit']
            if 'timeout' in adjustit:
                self.adjustit_timeout = adjustit['timeout']
            else:
                self.adjustit_timeout = 1

            if 'interface' in adjustit:
                self.adjustit_interface = adjustit['interface']
            else:
                self.adjustit_interface = 5

            if 'url' in adjustit and 'provider' in adjustit:
                self.adjustit_url = adjustit['url']
                self.adjustit_provider = adjustit['provider']
            else:
                raise ValueError("Config is not valid, (url, provider) is needed")
        else:
            raise ValueError("Config is not valid, adjustit is needed")

        if 'broker-url' in config_data:
            self.broker_url = config_data['broker-url']
        else:
            raise ValueError("Config is not valid, broker-url is needed")

        if 'rt_topics' in config_data:
            self.rt_topics = [topic for topic in config_data["rt_topics"]]
        else:
            raise ValueError("Config is not valid, navitia is needed")
