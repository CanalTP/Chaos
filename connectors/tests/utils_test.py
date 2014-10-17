from nose.tools import *
import datetime, time
from connectors.disruption_sender import utils


class Obj(object):
    pass

def test_get_max_end_period():
    result = datetime.datetime(year=2014, month=3, day=15, hour=16, minute=52)
    periods = []

    #   01-01-2014      15-02-2014
    #    *-----------------*
    obj = Obj()
    obj.start = datetime.datetime(year=2014, month=1, day=1, hour=16, minute=52)
    obj.end = datetime.datetime(year=2014, month=2, day=15, hour=16, minute=52)
    periods.append(obj)

    #                       25-02-2014      28-02-2014
    #                           *-----------------*
    obj = Obj()
    obj.start = datetime.datetime(year=2014, month=2, day=25, hour=16, minute=52)
    obj.end = datetime.datetime(year=2014, month=2, day=28, hour=16, minute=52)
    periods.append(obj)

    #                                                  10-03-2014      15-03-2014
    #                                                   *-----------------*
    obj = Obj()
    obj.start = datetime.datetime(year=2014, month=3, day=10, hour=16, minute=52)
    obj.end = result
    periods.append(obj)
    eq_(utils.get_max_end_period(periods), result)


def test_get_min_start_period():
    result = datetime.datetime(year=2014, month=1, day=1, hour=16, minute=52)
    periods = []

    #   01-01-2014      15-02-2014
    #    *-----------------*
    obj = Obj()
    obj.start = result
    obj.end = datetime.datetime(year=2014, month=2, day=15, hour=16, minute=52)
    periods.append(obj)

    #                       25-02-2014      28-02-2014
    #                           *-----------------*
    obj = Obj()
    obj.start = datetime.datetime(year=2014, month=2, day=25, hour=16, minute=52)
    obj.end = datetime.datetime(year=2014, month=2, day=28, hour=16, minute=52)
    periods.append(obj)

    #                                                  10-03-2014      15-03-2014
    #                                                   *-----------------*
    obj = Obj()
    obj.start = datetime.datetime(year=2014, month=3, day=10, hour=16, minute=52)
    obj.end = datetime.datetime(year=2014, month=3, day=15, hour=16, minute=52)
    periods.append(obj)


    eq_(utils.get_min_start_period(periods), result)