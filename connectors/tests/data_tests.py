from nose.tools import *
from chaos import gtfs_realtime_pb2, chaos_pb2
from connectors.disruption_sender.data import Data


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

    data = Data()
    data.fill_Events(feed_message)
    return data


def test_delete_event():
    data = get_data(True)

    eq_(len(data.events), 1)
    eq_(data.events[0].is_deleted, True)
    eq_(data.events[0].external_code, '1234')


def test_data_event():
    data = get_data(False)

    eq_(len(data.events), 1)
    eq_(data.events[0].is_deleted, False)
    eq_(data.events[0].external_code, '1234')
    eq_(data.events[0].title, 'reference')