from nose.tools import *
from connectors.xml.xml_parser import parse_response


class Obj(object):
    pass


def test_create_event_date():
    response = Obj()
    response.content = '<ActionEvent><Event EventID="193"><EventLevel EventLevelID="1">' \
               '<EventLevelTitle>Travaux</EventLevelTitle><EventLevelStatusAction>OK</EventLevelStatusAction>' \
               '</EventLevel><EventTitle>aaaaa</EventTitle><EventExternalCode>886a36ca-5085-11e4-9ff2-e82aeab22765' \
               '</EventExternalCode><EventCreationDate>2014-10-10T16:18:15</EventCreationDate>' \
               '<EventPublicationStartDate>2014-04-01T00:00:00</EventPublicationStartDate>' \
               '<EventPublicationEndDate>2014-05-15T23:59:59</EventPublicationEndDate>' \
               '<EventNextPushDate>1899-12-30T00:00:00</EventNextPushDate>' \
               '<EventCloseDate>1899-12-30T00:00:00</EventCloseDate>' \
               '<ProviderExtCode>CANALTP</ProviderExtCode>' \
               '<EventStatusAction>Ok_SQL_Add_Event</EventStatusAction>' \
               '<ImpactList Count="0" ImpactScenario="">' \
               '</ImpactList></Event></ActionEvent>'

    resp = parse_response(response)

    eq_(resp["status"], 'Ok_SQL_Add_Event')
    eq_(resp["event_id"], '193')
    eq_(resp["event_external_code"], '886a36ca-5085-11e4-9ff2-e82aeab22765')

