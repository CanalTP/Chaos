from nose.tools import *
from flask import g
from aniso8601 import parse_datetime
from datetime import datetime
import chaos

#current_time exists
def test_get_utc_datetime_valid():
    with chaos.app.app_context():
        date_format = "%Y-%m-%dT%H:%M:%SZ"
        str_date_time = "2015-04-10T13:15:00Z"
        date_time = parse_datetime(str_date_time).replace(tzinfo=None)
        utc_date_time = chaos.utils.get_utc_datetime_by_zone(date_time, 'Europe/Paris')
        eq_(utc_date_time.strftime(date_format), "2015-04-10T11:15:00Z")

@raises(AssertionError)
def test_get_utc_datetime_invalid():
    with chaos.app.app_context():
        date_format = "%Y-%m-%dT%H:%M:%SZ"
        str_date_time = "2015-04-10T13:15:00Z"
        date_time = parse_datetime(str_date_time).replace(tzinfo=None)
        utc_date_time = chaos.utils.get_utc_datetime_by_zone(date_time, 'Europe/Paris')
        eq_(utc_date_time.strftime(date_format), "2015-04-10T12:15:00Z")

@raises(ValueError)
def test_time_zone_value_invalid():
    with chaos.app.app_context():
        date_format = "%Y-%m-%dT%H:%M:%SZ"
        str_date_time = "2015-04-10T13:15:00Z"
        date_time = parse_datetime(str_date_time).replace(tzinfo=None)
        utc_date_time = chaos.utils.get_utc_datetime_by_zone(date_time, 'europe/unknown')
        eq_(utc_date_time.strftime(date_format), "2015-04-10T12:15:00Z")


def test_get_utc_datetime_with_dst_transition_in_between_valid():
    with chaos.app.app_context():
        date_format = "%Y-%m-%dT%H:%M:%SZ"
        #Before DST of end March difference is one hour
        str_date_time = "2015-03-28T13:15:00Z"
        date_time = parse_datetime(str_date_time).replace(tzinfo=None)
        utc_date_time = chaos.utils.get_utc_datetime_by_zone(date_time, 'Europe/Paris')
        eq_(utc_date_time.strftime(date_format), "2015-03-28T12:15:00Z")
        #DST began on Sun 29-Mar-2015 at 02:00:00 A.M. when local clocks were set forward 1 hour
        #After DST of end March difference is two hours
        str_date_time = "2015-03-29T13:15:00Z"
        date_time = parse_datetime(str_date_time).replace(tzinfo=None)
        utc_date_time = chaos.utils.get_utc_datetime_by_zone(date_time, 'Europe/Paris')
        eq_(utc_date_time.strftime(date_format), "2015-03-29T11:15:00Z")
