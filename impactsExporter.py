import os, sys, logging, argparse, pytz, datetime
import unicodecsv as csv
from chaos import db, utils, default_settings
from chaos.models import Export, Client
from chaos.navitia import Navitia

class impactsExporter:

    def __init__(self, client_id, coverage, token, time_zone = 'UTC'):
        self.logger = logging.getLogger('impacts exporter')
        self.set_client_by_id(client_id)
        self.set_coverage(coverage)
        self.set_token(token)
        self.set_time_zone(time_zone)

    def set_client_by_id(self, id):
        if not utils.is_uuid(id):
            raise ValueError("Wrong UUID format for client id")

        client = Client.query.get(id)
        if not client:
            raise ValueError("Wrong client id")

        self.client = client

    def set_coverage(self, coverage):
        self.coverage = coverage

    def set_token(self, token):
        self.token = token

    def set_time_zone(self, time_zone):
        self.time_zone = pytz.timezone(time_zone)

    def get_oldest_waiting_export(self, clientId):
        item = Export.get_oldest_waiting_export(clientId)
        if not item:
            raise UserWarning("No waiting task for this client has been found")

        return item

    def update_export_status(self, item, status):
        item.status = status
        item.process_start_date = utils.get_current_time()
        item.updated_at = utils.get_current_time()
        db.session.commit()
        db.session.refresh(item)

    def check_required_arguments(self):
        if not self.client:
            raise ValueError("Client id should be provided")

        if not self.coverage:
            raise ValueError("Coverage should be provided")

        if not self.token:
            raise ValueError("Token should be provided")

        if not self.time_zone:
            raise ValueError("Invalid timezone")

        return True

    def get_client_impacts_between_application_dates(self, client_id, start_date, end_date):
        return Export.get_client_impacts_between_application_dates(client_id, start_date, end_date)

    def generate_file_path(self, item):
        datePattern = '%Y_%m_%d'

        start_date = utils.utc_to_local(item.start_date, self.time_zone).strftime(datePattern)
        end_date = utils.utc_to_local(item.end_date, self.time_zone).strftime(datePattern)

        fileName = '%s_impacts_export_%s_%s_%s.csv' % (self.client.client_code, start_date, end_date, item.id)
        filePath = os.path.join(default_settings.IMPACT_EXPORT_DIR, fileName)

        return os.path.abspath(filePath)

    def create_csv(self, filePath, columns, rows):
        with open(filePath, 'wb') as f:
            w = csv.writer(f)
            w.writerow(columns)
            w.writerows(rows)
            f.close()

    def mark_export_as_done(self, item, filePath):
        if isinstance(item, Export):
            item.status = 'done'
            item.file_path = filePath
            item.updated_at = utils.get_current_time()
            db.session.commit()
            db.session.refresh(item)

    def mark_export_as_error(self, item):
        if isinstance(item, Export):
            item.status = 'error'
            item.updated_at = utils.get_current_time()
            db.session.commit()
            db.session.refresh(item)

    def run(self):
        try:
            item = None
            self.check_required_arguments()
            item = self.get_oldest_waiting_export(self.client.id)
            self.update_export_status(item, 'handling')
            impacts = self.get_client_impacts_between_application_dates(item.client_id, item.start_date, item.end_date)
            formated_impacts = self.format_impacts(impacts)
            filePath = self.generate_file_path(item)
            self.create_csv(filePath, formated_impacts['columns'], formated_impacts['rows'])
            self.mark_export_as_done(item, filePath)
            self.logger.info('Impacts export for %s is available at %s' % (item.client_id, filePath))
        except UserWarning as w:
            self.mark_export_as_error(item)
            self.logger.info(w)
            sys.exit(0)
        except Exception as e:
            self.mark_export_as_error(item)
            self.logger.debug(e)
            sys.exit(1)

    def format_impacts(self, impacts):

        navitia = Navitia(default_settings.NAVITIA_URL, self.coverage, self.token)

        columns = impacts.keys()

        rows = []
        for sub_dict in impacts.fetchall():
            row = []
            for column in columns:
                val = sub_dict[column]
                if column == 'pt_object_name' :
                    row.append(navitia.find_tc_object_name(sub_dict['pt_object_uri'], sub_dict['pt_object_type']))
                elif isinstance(val, datetime.date):
                    row.append(utils.utc_to_local(val, self.time_zone))
                else:
                    row.append(val)

            rows.append(row)

        return {'columns' : columns, 'rows' : rows}

def get_command_arguments(argv):
    parser = argparse.ArgumentParser()

    parser.add_argument('--client_id', help='Client UUID')
    parser.add_argument('--coverage', help='Navitia coverage')
    parser.add_argument('--token', help='Navitia token')
    parser.add_argument('--tz', help='Time zone')

    return parser.parse_args()


if __name__ == "__main__":
    args = get_command_arguments(sys.argv[1:])

    tz = args.tz
    if not tz:
        tz = 'UTC'

    exporter = impactsExporter(args.client_id, args.coverage, args.token, tz)
    exporter.run()
