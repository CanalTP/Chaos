
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

from connectors.disruption_sender import gtfs_realtime_pb2


CONFIG = {
    "navitia": {
        "url": "http://navitia2-ws.ctp.dev.canaltp.fr",
        "coverage": "fr-cen",
        "token": "f8a9befb-6bd9-4620-b942-b6b69a07487d"
    },
    "adjustit": {
        "url": "http://10.2.0.16/alertetrafic/master/cgi-bin/adjustit.dll",
        "interface": 8,
        "timeout": 1
    },
    "severities": {
        gtfs_realtime_pb2.Alert.NO_SERVICE: "Disrupt",
        gtfs_realtime_pb2.Alert.REDUCED_SERVICE: "Warning",
        gtfs_realtime_pb2.Alert.SIGNIFICANT_DELAYS: "Information",
        gtfs_realtime_pb2.Alert.DETOUR: "Information",
        gtfs_realtime_pb2.Alert.ADDITIONAL_SERVICE: "Information",
        gtfs_realtime_pb2.Alert.MODIFIED_SERVICE: "Information",
        gtfs_realtime_pb2.Alert.OTHER_EFFECT: "Information",
        gtfs_realtime_pb2.Alert.UNKNOWN_EFFECT: "Information",
        gtfs_realtime_pb2.Alert.STOP_MOVED: "Information"
    },
    "channels": {
        "internet": 1,
        "sms": 2,
        "email": 3,
    },
    "rabbitmq": {
        "exchange-name": "navitia",
        "queue-name": "navitia",
        "broker-url": "amqp://guest:guest@localhost:5672//",
        "rt_topics": ["shortterm.tn"]
    },
    "logger": {
        "version": 1,
        "disable_existing_loggers": "False",
        "formatters": {
            "default": {
                "format": "[%(asctime)s] [%(levelname)5s] [%(process)5s] [%(name)10s] %(message)s"
            }
        },
        "handlers": {
            "default": {
                "level": "DEBUG",
                "class": "logging.StreamHandler",
                "formatter": "default"
            }
        },
        "loggers": {
            "": {
                "handlers": ["default"],
                "level": "DEBUG",
                "propagate": "True"
            }
        }
    },
    "database": {
        "filename": "sqlite:///data.db"
    },
    "other": {
        "provider": "canaltp",
        "eventlevel": 1
    }
}