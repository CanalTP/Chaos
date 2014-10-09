from nose.tools import *
import datetime, time
from connectors.disruption_sender import utils


def test_format_date():
    date = datetime.datetime(year=2014, month=4, day=12, hour=16, minute=52)
    eq_(utils.int_date_format(int(time.mktime(date.timetuple()))), '2014|04|12')

    date = datetime.datetime(year=2014, month=4, day=2, hour=16, minute=52)
    eq_(utils.int_date_format(int(time.mktime(date.timetuple()))), '2014|04|02')

@raises(TypeError)
def test_format_date():
    eq_(utils.int_date_format("aaa"), '2014|04|12')



