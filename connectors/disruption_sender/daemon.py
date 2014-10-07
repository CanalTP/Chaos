
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
from connectors.disruption_sender.config import Config
from connectors.disruption_sender.sender import Sender
from connectors.disruption_sender.adjustit import AdjustIt
from connectors.disruption_sender.utils import FunctionalError, TechnicalError
from chaos import gtfs_realtime_pb2
import time
import kombu
from kombu.mixins import ConsumerMixin
from google.protobuf.message import DecodeError

class DisruptionSender(ConsumerMixin):

    """
    Ce service permet d'envoyer des perturbations a Adjustit a partir de rabbitmq
    """

    def __init__(self, config_data):
        self.connection = None
        self.exchange = None
        self.queues = []
        self.config = config_data
        self.sender = Sender(self.config, AdjustIt(self.config))
        self._init_rabbitmq()

    def _init_rabbitmq(self):
        """
        connect to rabbitmq and init the queues
        """
        self.connection = kombu.Connection(self.config['broker-url'])
        exchange_name = self.config['exchange-name']
        exchange = kombu.Exchange(exchange_name, type="topic")
        logging.getLogger('disruption_sender').info("listen following exchange: %s",
                                                    exchange_name)

        for topic in self.config["rt_topics"]:
            queue = kombu.Queue(self.config['queue-name'] + ':' + topic,
                                exchange=exchange,
                                durable=True,
                                routing_key=topic)
            self.queues.append(queue)

    def get_consumers(self, Consumer, channel):
        return [Consumer(queues=self.queues, callbacks=[self.process_task])]

    def handle_disruption(self, disruption):
        if disruption.IsInitialized():
            try:
                self.sender.send_disruption(disruption)
            except (FunctionalError) as e:
                logging.getLogger('disruption_sender').warn("error while preparing stats to save: {}".format(str(e)))
        else:
            logging.getLogger('disruption_sender').warn("protobuff query not initialized,"
                                                     " no stat logged")

    def process_task(self, body, message):
        logging.getLogger('disruption_sender').debug("Message received")
        feed_message = gtfs_realtime_pb2.FeedMessage()
        try:
            feed_message.ParseFromString(body)
            logging.getLogger('disruption_sender').debug('query received: {}'.format(str(feed_message)))
        except DecodeError as e:
            logging.getLogger('disruption_sender').warn("message is not a valid "
                                             "protobuf task: {}".format(str(e)))
            message.ack()
            return

        try:
            self.handle_disruption(feed_message)
            message.ack()
        except (TechnicalError) as e:
                logging.getLogger('disruption_sender').warn("error while saving stats: {}".format(str(e)))
                # on technical error (like a database KO) we retry this task later
                # and we sleep 10 seconds
                message.requeue()
                time.sleep(10)

    def __del__(self):
        self.close()

    def close(self):
        if self.connection and self.connection.connected:
            self.connection.release()
