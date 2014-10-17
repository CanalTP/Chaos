from nose.tools import *
from connectors.xml.xml_parser import parse_response


class Obj(object):
    pass


def get_resp_update_impact_valid():
    response = Obj()
    response.content = '<ActionEvent>' \
                       '<Event EventID="8">' \
                       '<EventLevel EventLevelID="1">' \
                       '<EventLevelTitle>Travaux</EventLevelTitle>' \
                       '<EventLevelStatusAction>OK</EventLevelStatusAction>' \
                       '</EventLevel>' \
                       '<EventTitle>test</EventTitle>' \
                       '<EventExternalCode>5c694822-5512-11e4-8324-e82aeab22767</EventExternalCode>' \
                       '<EventStatusAction>Ok</EventStatusAction>' \
                       '<ImpactList Count="1" ImpactScenario="">' \
                       '<Impact ImpactID="23" EventID="8" Mon="1" Tue="1" Wed="1" Thu="1" Fri="1" Sat="1" Sun="1">' \
                       '<TCObjectRef TCObjectRefID="474">' \
                       '<TCObjectRefExternalCode>network:Filbleu</TCObjectRefExternalCode>' \
                       '<TCObjectRefType>Network</TCObjectRefType>' \
                       '</TCObjectRef>' \
                       '<ImpactStatusAction>Ok</ImpactStatusAction>' \
                       '<BroadcastList Count="2">' \
                       '<Broadcast ImpactID="23" MediaID="1">' \
                       '<BroadcastStatusAction>Ok</BroadcastStatusAction>' \
                       '</Broadcast>' \
                       '<Broadcast ImpactID="23" MediaID="2">' \
                       '<BroadcastStatusAction>Ok</BroadcastStatusAction>' \
                       '</Broadcast>' \
                       '</BroadcastList>' \
                       '</Impact>' \
                       '</ImpactList>' \
                        '</Event>' \
                        '</ActionEvent>'
    return response


def test_get_event_with_Impact():
    response = get_resp_update_impact_valid()
    resp = parse_response(response)
    eq_(resp["event_status"], 'Ok')
    eq_(resp["event_id"], '8')
    eq_(resp["event_external_code"], '5c694822-5512-11e4-8324-e82aeab22767')
    eq_(len(resp["impacts"]), 1)
    impact = resp["impacts"][0]
    eq_(impact["impact_id"], "23")
    eq_(impact["impact_status"], "Ok")
    eq_(impact["pt_object_uri"], "network:Filbleu")
    eq_(len(impact["messages"]), 2)
    message = impact["messages"][0]
    eq_(message["media_id"], "1")
    eq_(message["message_status"], "Ok")
    message = impact["messages"][1]
    eq_(message["media_id"], "2")
    eq_(message["message_status"], "Ok")