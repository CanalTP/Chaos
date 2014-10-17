from nose.tools import *
from connectors.disruption_sender.adjustit import AdjustIt
import datetime, time
from connectors.tests.testing_settings import CONFIG


class Obj(object):
    pass


def get_date(_year, _month, _day, _hour, _minute):
    t = datetime.datetime(year=_year,
                          month=_month,
                          day=_day,
                          hour=_hour,
                          minute=_minute)
    return int(time.mktime(t.timetuple()))


def get_message():
    message = Obj()
    message.msg_media = Obj()
    message.msg_media.id = 2
    message.title = "sms"
    message.msg = "message sms"
    message.push_date = get_date(2014, 10, 16, 15, 12)
    return message


def get_impact():
    impact = Obj()

    impact.external_code = "1234"
    impact.id = "235"
    impact.creation_date = get_date(2014, 11, 16, 15, 12)
    impact.modification_date = get_date(2014, 10, 16, 15, 12)
    impact.application_start_date = get_date(2014, 1, 16, 15, 12)
    impact.application_end_date = get_date(2014, 3, 16, 15, 12)
    impact.daily_start_time = datetime.time(hour=0, minute=0, second=0)
    impact.daily_end_time = datetime.time(hour=23, minute=59, second=59)
    impact.duration = 0
    impact.status = 'Information'
    impact.pt_object = Obj()
    impact.pt_object.external_code = 'uri1'
    impact.pt_object.type = 'Network'
    impact.impact_broad_casts = []
    return impact


def get_impact_by_new_id(id):
    return None

def test_format_url_message():
    adjust_it = AdjustIt(CONFIG)
    message = get_message()
    url = adjust_it.format_url_message(message)
    eq_(url, 'impacttitle=sms|.|pushdate=2014|10|16|15|12|00|.|mediaid=2|.|freemsg=message sms')


def test_format_url_impact_without_message():
    adjust_it = AdjustIt(CONFIG)
    impact = get_impact()
    url = adjust_it.format_url_impact(impact)
    eq_(url, 'ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|DailyStartTime=00|00|00|-|'
             'DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111')


def test_format_url_impact_with_one_message():
    adjust_it = AdjustIt(CONFIG)
    impact = get_impact()
    message = get_message()
    impact.impact_broad_casts.append(message)
    url = adjust_it.format_url_impact(impact)
    eq_(url, 'ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|DailyStartTime=00|00|00|-|'
             'DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|TCOType=Network|-|State=Information|-|'
             'ImpactActiveDays=1111111|-|broadcast=impacttitle=sms|.|pushdate=2014|10|16|15|12|00|.|mediaid=2|.|'
             'freemsg=message sms')


def test_format_url_impact_with_two_messages():
    adjust_it = AdjustIt(CONFIG)
    impact = get_impact()
    message = get_message()
    impact.impact_broad_casts.append(message)
    message = get_message()
    impact.impact_broad_casts.append(message)

    url = adjust_it.format_url_impact(impact)
    eq_(url, 'ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|DailyStartTime=00|00|00|-|'
             'DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|TCOType=Network|-|State=Information|-|'
             'ImpactActiveDays=1111111|-|broadcast1=impacttitle=sms|.|pushdate=2014|10|16|15|12|00|.|'
             'mediaid=2|.|freemsg=message sms||broadcast2=impacttitle=sms|.|pushdate=2014|10|16|15|12|00|.|'
             'mediaid=2|.|freemsg=message sms')


def test_format_url_event_without_impact():
    adjust_it = AdjustIt(CONFIG)
    local_event = Obj()
    event = Obj()
    event.impacts = []

    url = adjust_it.format_url_impacts_event(event, local_event)
    eq_(url, '')


def test_format_url_event_whit_one_impact():
    adjust_it = AdjustIt(CONFIG)
    local_event = Obj()
    local_event.get_impact_by_new_id = get_impact_by_new_id
    event = Obj()
    event.impacts = []
    impact = get_impact()
    event.impacts.append(impact)

    url = adjust_it.format_url_impacts_event(event, local_event)
    eq_(url, 'impact=ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|'
             'DailyStartTime=00|00|00|-|DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|'
             'TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111')


def test_format_url_event_whit_two_impacts():
    adjust_it = AdjustIt(CONFIG)
    local_event = Obj()
    local_event.get_impact_by_new_id = get_impact_by_new_id
    event = Obj()
    event.impacts = []
    impact = get_impact()
    event.impacts.append(impact)
    impact = get_impact()
    event.impacts.append(impact)

    url = adjust_it.format_url_impacts_event(event, local_event)
    eq_(url, 'impact1=ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|'
             'DailyStartTime=00|00|00|-|DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|'
             'TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111&'
             'impact2=ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|'
             'DailyStartTime=00|00|00|-|DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|'
             'TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111')


def test_format_url_event_whit_one_impact_one_message():
    adjust_it = AdjustIt(CONFIG)
    local_event = Obj()
    local_event.get_impact_by_new_id = get_impact_by_new_id
    event = Obj()
    event.impacts = []
    impact = get_impact()
    event.impacts.append(impact)
    message = get_message()
    impact.impact_broad_casts.append(message)

    url = adjust_it.format_url_impacts_event(event, local_event)
    eq_(url, 'impact=ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|'
             'DailyStartTime=00|00|00|-|DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|'
             'TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111|-|'
             'broadcast=impacttitle=sms|.|pushdate=2014|10|16|15|12|00|.|mediaid=2|.|freemsg=message sms')


def test_format_url_event_whit_two_impact_two_message():
    adjust_it = AdjustIt(CONFIG)
    local_event = Obj()
    local_event.get_impact_by_new_id = get_impact_by_new_id
    event = Obj()
    event.impacts = []
    impact = get_impact()
    event.impacts.append(impact)
    message = get_message()
    impact.impact_broad_casts.append(message)
    impact = get_impact()
    event.impacts.append(impact)
    message = get_message()
    impact.impact_broad_casts.append(message)

    url = adjust_it.format_url_impacts_event(event, local_event)
    eq_(url, 'impact1=ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|'
             'DailyStartTime=00|00|00|-|DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|'
             'TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111|-|'
             'broadcast=impacttitle=sms|.|pushdate=2014|10|16|15|12|00|.|mediaid=2|.|freemsg=message sms&'
             'impact2=ImpactStartDate=2014|01|16|15|12|00|-|ImpactEndDate=2014|03|16|15|12|00|-|'
             'DailyStartTime=00|00|00|-|DailyEndTime=23|59|59|-|Duration=0|-|TCOExtCode=uri1|-|'
             'TCOType=Network|-|State=Information|-|ImpactActiveDays=1111111|-|broadcast=impacttitle=sms|.|'
             'pushdate=2014|10|16|15|12|00|.|mediaid=2|.|freemsg=message sms')


def test_format_date():
    adjust_it = AdjustIt(CONFIG)
    date = datetime.datetime(year=2014, month=4, day=12, hour=16, minute=52)
    eq_(adjust_it.datetime_to_string(int(time.mktime(date.timetuple()))), '2014|04|12|16|52|00')

    date = datetime.datetime(year=2014, month=4, day=2, hour=16, minute=52)
    eq_(adjust_it.datetime_to_string(int(time.mktime(date.timetuple()))), '2014|04|02|16|52|00')


@raises(TypeError)
def test_format_date():
    adjust_it = AdjustIt(CONFIG)
    eq_(adjust_it.datetime_to_string("aaa"), '2014|04|12')
