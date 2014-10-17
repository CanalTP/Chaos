from nose.tools import *
from connectors.xml.xml_parser import parse_response
from connectors.disruption_sender import utils


class Obj(object):
    pass

def get_resp_create_event_valid():
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
    return response

def get_resp_create_event_invalid():
    response = Obj()
    response.content = '<ActionEvent><EventAA EventID="193"><EventLevel EventLevelID="1">' \
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
               '</ImpactList></EventAA></ActionEvent>'
    return response

def get_resp_update_event_with_Impact():
    response = Obj()
    response.content = '<?xml version="1.0" encoding="ISO-8859-1"?>' \
                       '<ActionEvent><Event EventID="195"><EventLevel EventLevelID="1">' \
                       '<EventLevelTitle>Travaux</EventLevelTitle>' \
                       '<EventLevelStatusAction></EventLevelStatusAction>' \
                       '</EventLevel>' \
                       '<EventTitle>foo</EventTitle>' \
                       '<EventExternalCode>886a36ca-5085-11e4-9ff2-e82aeab22765</EventExternalCode>' \
                       '<EventCreationDate>1899-12-30T00:00:00</EventCreationDate>' \
                       '<EventPublicationStartDate>2014-06-24T10:35:00</EventPublicationStartDate>' \
                       '<EventPublicationEndDate>2014-06-24T23:59:59</EventPublicationEndDate>' \
                       '<EventNextPushDate>1899-12-30T00:00:00</EventNextPushDate>' \
                       '<EventCloseDate>1899-12-30T00:00:00</EventCloseDate>' \
                       '<ProviderExtCode>CANALTP</ProviderExtCode>' \
                       '<EventStatusAction>Ok_SQL_Update_Event</EventStatusAction>' \
                       '<ImpactList Count="4" ImpactScenario="">' \
                       '<Impact ImpactID="-1" EventID="195" Mon="1" Tue="1" Wed="1" Thu="1" Fri="1" Sat="1" Sun="1">' \
                       '<TCObjectRef TCObjectRefID="-1">' \
                       '<TCObjectRefExternalCode>network&#58;Agglobus</TCObjectRefExternalCode>' \
                       '<TCObjectRefType>Network</TCObjectRefType>' \
                       '</TCObjectRef>' \
                       '<ImpactObjectState>information</ImpactObjectState>' \
                       '<ImpactExternalCode></ImpactExternalCode>' \
                       '<ImpactModificationDate>1899-12-30T00:00:00</ImpactModificationDate>' \
                       '<ImpactStartDate>2014-06-01T16:52:00</ImpactStartDate>' \
                       '<ImpactEndDate>2014-11-22T02:15:00</ImpactEndDate>' \
                       '<ImpactDailyStartTime>00:00:00</ImpactDailyStartTime>' \
                       '<ImpactDailyEndTime>23:59:59</ImpactDailyEndTime>' \
                       '<ImpactModificationDate>1899-12-30T00:00:00</ImpactModificationDate>' \
                       '<ImpactCloseDate>1899-12-30T00:00:00</ImpactCloseDate>' \
                       '<ImpactDuration>0</ImpactDuration>' \
                       '<ImpactScenarioType></ImpactScenarioType>' \
                       '<ImpactScenarioCode></ImpactScenarioCode>' \
                       '<ImpactScenarioApp></ImpactScenarioApp>' \
                       '<ImpactStatusAction>Error: Invalid State.</ImpactStatusAction>' \
                       '<BroadcastList Count="0">' \
                       '</BroadcastList>' \
                       '</Impact>' \
                       '<Impact ImpactID="-1" EventID="195" Mon="1" Tue="1" Wed="1" Thu="1" Fri="1" Sat="1" Sun="1">' \
                       '<TCObjectRef TCObjectRefID="-1">' \
                       '<TCObjectRefExternalCode>network&#58;Tub</TCObjectRefExternalCode>' \
                       '<TCObjectRefType>Network</TCObjectRefType>' \
                       '</TCObjectRef>' \
                       '<ImpactObjectState>information</ImpactObjectState>' \
                       '<ImpactExternalCode></ImpactExternalCode>' \
                       '<ImpactModificationDate>1899-12-30T00:00:00</ImpactModificationDate>' \
                       '<ImpactStartDate>2014-06-01T16:52:00</ImpactStartDate>' \
                       '<ImpactEndDate>2014-11-22T02:15:00</ImpactEndDate>' \
                       '<ImpactDailyStartTime>00:00:00</ImpactDailyStartTime>' \
                       '<ImpactDailyEndTime>23:59:59</ImpactDailyEndTime>' \
                       '<ImpactModificationDate>1899-12-30T00:00:00</ImpactModificationDate>' \
                       '<ImpactCloseDate>1899-12-30T00:00:00</ImpactCloseDate>' \
                       '<ImpactDuration>0</ImpactDuration>' \
                       '<ImpactScenarioType></ImpactScenarioType>' \
                       '<ImpactScenarioCode></ImpactScenarioCode>' \
                       '<ImpactScenarioApp></ImpactScenarioApp>' \
                       '<ImpactStatusAction>Error: Invalid State.</ImpactStatusAction>' \
                       '<BroadcastList Count="0">' \
                       '</BroadcastList>' \
                       '</Impact>' \
                       '</ImpactList>' \
                       '<PagerInfo PagerIndex="0" TotalPages="0" RecordsPerPage="0" TotalCount="0"/>' \
                       '</Event>' \
                       '</ActionEvent>'
    return response

def get_resp_get_event_with_Impact():
    response = Obj()
    response.content = '<ActionEvent>' \
                       '<Event EventID="157">' \
                       '<EventLevel EventLevelID="2">' \
                       '<EventLevelStatusAction>OK</EventLevelStatusAction>' \
                       '</EventLevel>' \
                       '<EventExternalCode>ifremery-2140304083721-198</EventExternalCode>' \
                       '<ProviderExtCode>ifremery</ProviderExtCode>' \
                       '<EventStatusAction>Ok</EventStatusAction>' \
                       '<ImpactList Count="1" ImpactScenario=";82dc5d5fa61feb587dea094cbf26b23f">' \
                       '<Impact ImpactID="494" EventID="157" Mon="1" Tue="1" Wed="1" Thu="1" Fri="1" Sat="1" Sun="1">' \
                       '<TCObjectRef TCObjectRefID="228">' \
                       '<TCObjectRefExternalCode>NAZ81</TCObjectRefExternalCode>' \
                       '<TCObjectRefType>Line</TCObjectRefType>' \
                       '</TCObjectRef>' \
                       '<ImpactObjectState>Information</ImpactObjectState>' \
                       '<ImpactExternalCode>ifremery-2140304083721-1981</ImpactExternalCode>' \
                       '<ImpactModificationDate>1899-12-30T00:00:00</ImpactModificationDate>' \
                       '<ImpactStartDate>2014-03-04T08:30:00</ImpactStartDate>' \
                       '<ImpactEndDate>2014-03-15T12:20:00</ImpactEndDate>' \
                       '<ImpactDailyStartTime>00:00:00</ImpactDailyStartTime>' \
                       '<ImpactDailyEndTime>23:59:59</ImpactDailyEndTime>' \
                       '<ImpactModificationDate>1899-12-30T00:00:00</ImpactModificationDate>' \
                       '<ImpactCloseDate>1899-12-30T00:00:00</ImpactCloseDate>' \
                       '<ImpactDuration>0</ImpactDuration>' \
                       '<ImpactScenarioType>RoutePointByModeAndLine</ImpactScenarioType>' \
                       '<ImpactScenarioCode>82dc5d5fa61feb587dea094cbf26b23f</ImpactScenarioCode>' \
                       '<ImpactScenarioApp>ATV2DESTINEO3PROD</ImpactScenarioApp>' \
                       '<ImpactStatusAction>Ok</ImpactStatusAction>' \
                       '</Impact>' \
                       '</ImpactList>' \
                       '<PagerInfo PagerIndex="1" TotalPages="1" RecordsPerPage="1000" TotalCount="1"/>' \
                       '</Event>' \
                       '</ActionEvent>'
    return response

def test_get_event_with_Impact():
    response = get_resp_get_event_with_Impact()
    resp = parse_response(response)
    eq_(resp["event_status"], 'Ok')
    eq_(resp["event_id"], '157')
    eq_(resp["event_external_code"], 'ifremery-2140304083721-198')
    eq_(len(resp["impacts"]), 1)

def test_create_event_valid():
    response = get_resp_create_event_valid()
    resp = parse_response(response)

    eq_(resp["event_status"], 'Ok_SQL_Add_Event')
    eq_(resp["event_id"], '193')
    eq_(resp["event_external_code"], '886a36ca-5085-11e4-9ff2-e82aeab22765')


@raises(AttributeError)
def test_create_event_invalid():
    response = get_resp_create_event_invalid()
    parse_response(response)


def test_update_event_valid():
    response = get_resp_update_event_with_Impact()
    resp = parse_response(response)
    eq_(resp["event_status"], 'Ok_SQL_Update_Event')
    eq_(resp["event_id"], '195')
    eq_(resp["event_external_code"], '886a36ca-5085-11e4-9ff2-e82aeab22765')