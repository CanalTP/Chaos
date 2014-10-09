from nose.tools import *
from chaos import gtfs_realtime_pb2, chaos_pb2
from connectors.disruption_sender.data import get_events
import datetime, time


def get_date(_year, _month, _day, _hour, _minute):
    t = datetime.datetime(year=_year,
                          month=_month,
                          day=_day,
                          hour=_hour,
                          minute=_minute)
    return int(time.mktime(t.timetuple()))


def get_data(is_deleted):
    feed_message = gtfs_realtime_pb2.FeedMessage()
    feed_message.header.gtfs_realtime_version = '1.0'
    feed_message.header.incrementality = gtfs_realtime_pb2.FeedHeader.DIFFERENTIAL
    feed_entity = feed_message.entity.add()
    feed_entity.id = '1234'
    feed_entity.is_deleted = is_deleted
    disruption_pb = feed_entity.Extensions[chaos_pb2.disruption]
    disruption_pb.id = '1234'
    disruption_pb.reference = 'reference'
    disruption_pb.note = 'note'

    disruption_pb.publication_period.start = get_date(2014, 4, 12, 16, 52)
    disruption_pb.publication_period.end = get_date(2015, 4, 12, 16, 52)
    impact_pb = disruption_pb.impacts.add()
    impact_pb.created_at = get_date(2014, 3, 12, 16, 52)
    impact_pb.updated_at = get_date(2014, 3, 15, 16, 52)

    # 2 periods
    period = impact_pb.application_periods.add()
    period.start = get_date(2014, 5, 12, 16, 52)
    period.end = get_date(2014, 7, 12, 16, 52)
    period = impact_pb.application_periods.add()
    period.start = get_date(2014, 8, 12, 16, 52)
    period.end = get_date(2014, 9, 12, 16, 52)

    # 2 messages
    message = impact_pb.messages.add()
    message.text = "message1"
    message = impact_pb.messages.add()
    message.text = "message2"

    # 2 PtObjects
    ptobject = impact_pb.informed_entities.add()
    ptobject.uri = "object1"
    ptobject = impact_pb.informed_entities.add()
    ptobject.uri = "object2"

    return get_events(feed_message)


def test_delete_event():
    events = get_data(True)

    eq_(len(events), 1)
    eq_(events[0].is_deleted, True)
    eq_(events[0].external_code, '1234')


def test_data_event():
    events = get_data(False)

    eq_(len(events), 1)
    eq_(events[0].is_deleted, False)
    eq_(events[0].external_code, '1234')
    eq_(events[0].title, 'reference')
    eq_(len(events[0].impacts), 4)
    for impact in events[0].impacts:
        eq_(len(impact.impact_broad_casts), 2)
