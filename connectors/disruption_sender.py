
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

import sys

from disruption_sender.daemon import DisruptionSender
from connectors.database.database import init_db
import argparse
import json
import logging
import logging.config


def main():
    """
        main: ce charge d'interpreter les parametres de la ligne de commande
    """
    parser = argparse.ArgumentParser(description="DisruptionSender se charge "
                                     "d'envoyer les perturabations a Adjustit")
    parser.add_argument('config_file', type=str)
    config_file = ""
    try:
        args = parser.parse_args()
        config_file = args.config_file
    except argparse.ArgumentTypeError:
        print("Bad usage, learn how to use me with %s -h" % sys.argv[0])
        sys.exit(1)
    try:
        config_data = json.loads(open(config_file).read())
        if 'logger' in config_data:
            logging.config.dictConfig(config_data['logger'])
        else: # Default is std out
            handler = logging.StreamHandler(stream=sys.stdout)
            logging.getLogger().addHandler(handler)
            logging.getLogger().setLevel('INFO')
    except ValueError as e:
        print("Bad config file, %s" % str(e))
        sys.exit(1)
    except IOError as e:
        print("Bad config file, %s" % str(e))
        sys.exit(1)

    init_db(config_data)

    daemon = DisruptionSender(config_data)
    daemon.run()

    sys.exit(0)


if __name__ == "__main__":
    main()
