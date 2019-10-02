from nose.tools import *

import chaos

class Obj(object):
    pass

def set_up():
    chaos.app.config['SERVER_NAME'] = 'localhost'

#First page, 2 elements per page, 10 elements in total, without previous page link.
@with_setup(set_up)
def test_not_prev():
    with chaos.app.app_context():
        endpoint = "disruption"
        obj = Obj()
        obj.has_prev = False
        obj.has_next = True
        obj.prev_num = 1
        obj.next_num = 2
        obj.per_page = 2
        obj.pages = 5
        obj.page = 1
        obj.total = 10
        obj.items = [Obj(), Obj()]
        result = chaos.utils.make_pager(obj,endpoint)
        eq_('pagination' in result, True)
        eq_('start_page' in result['pagination'], True)
        eq_(result['pagination']['start_page'], 1)


        eq_('items_on_page' in result['pagination'], True)
        eq_(result['pagination']['items_on_page'], 2)

        eq_('items_per_page' in result['pagination'], True)
        eq_(result['pagination']['items_per_page'], 2)

        eq_('total_result' in result['pagination'], True)
        eq_(result['pagination']['total_result'], 10)

        eq_('first' in result['pagination'], True)
        eq_('href' in result['pagination']['first'], True )
        eq_(result['pagination']['first']['href'], generate_pager_url(1,2))

        eq_('last' in result['pagination'], True)
        eq_('href' in result['pagination']['last'], True )
        eq_(result['pagination']['last']['href'], generate_pager_url(5,2))

        eq_('prev' in result['pagination'], True)
        eq_('href' in result['pagination']['prev'], True )
        eq_(result['pagination']['prev']['href'], None )

        eq_('next' in result['pagination'], True)
        eq_('href' in result['pagination']['next'], True )
        eq_(result['pagination']['next']['href'], generate_pager_url(2, 2))

#Second page, 2 elements per page, 10 elements in total, with previous and next page links.
@with_setup(set_up)
def test_next_and_prev():
    with chaos.app.app_context():

        endpoint = "disruption"
        obj = Obj()
        obj.has_prev = True
        obj.has_next = True
        obj.prev_num = 1
        obj.next_num = 3
        obj.per_page = 3
        obj.pages = 4
        obj.page = 2
        obj.total = 10
        obj.items = [Obj(), Obj(), Obj()]
        result = chaos.utils.make_pager(obj,endpoint)
        eq_('pagination' in result, True)
        eq_('start_page' in result['pagination'], True)
        eq_(result['pagination']['start_page'], 2)


        eq_('items_on_page' in result['pagination'], True)
        eq_(result['pagination']['items_on_page'], 3)

        eq_('items_per_page' in result['pagination'], True)
        eq_(result['pagination']['items_per_page'], 3)

        eq_('total_result' in result['pagination'], True)
        eq_(result['pagination']['total_result'], 10)

        eq_('first' in result['pagination'], True)
        eq_('href' in result['pagination']['first'], True )
        eq_(result['pagination']['first']['href'], generate_pager_url(1, 3))

        eq_('last' in result['pagination'], True)
        eq_('href' in result['pagination']['last'], True )
        eq_(result['pagination']['last']['href'], generate_pager_url(4, 3))

        eq_('prev' in result['pagination'], True)
        eq_('href' in result['pagination']['prev'], True )
        eq_(result['pagination']['prev']['href'], generate_pager_url(1, 3))

        eq_('next' in result['pagination'], True)
        eq_('href' in result['pagination']['next'], True )
        eq_(result['pagination']['next']['href'], generate_pager_url(3, 3))

#Last page with 1 element, 3 elements per page, 10 elements in total, without next page links
@with_setup(set_up)
def test_not_next_and_items_on_page():
    with chaos.app.app_context():

        endpoint = "disruption"
        obj = Obj()
        obj.has_prev = True
        obj.has_next = False
        obj.prev_num = 3
        obj.next_num = None
        obj.per_page = 3
        obj.pages = 4
        obj.page = 4
        obj.total = 10
        obj.items = [Obj()]
        result = chaos.utils.make_pager(obj,endpoint)
        eq_('pagination' in result, True)
        eq_('start_page' in result['pagination'], True)
        eq_(result['pagination']['start_page'], 4)


        eq_('items_on_page' in result['pagination'], True)
        eq_(result['pagination']['items_on_page'], 1)

        eq_('items_per_page' in result['pagination'], True)
        eq_(result['pagination']['items_per_page'], 3)

        eq_('total_result' in result['pagination'], True)
        eq_(result['pagination']['total_result'], 10)

        eq_('first' in result['pagination'], True)
        eq_('href' in result['pagination']['first'], True )
        eq_(result['pagination']['first']['href'], generate_pager_url(1, 3))

        eq_('last' in result['pagination'], True)
        eq_('href' in result['pagination']['last'], True )
        eq_(result['pagination']['last']['href'], generate_pager_url(4, 3))

        eq_('prev' in result['pagination'], True)
        eq_('href' in result['pagination']['prev'], True )
        eq_(result['pagination']['prev']['href'], generate_pager_url(3, 3))

        eq_('next' in result['pagination'], True)
        eq_('href' in result['pagination']['next'], True )
        eq_(result['pagination']['next']['href'], None )


def generate_pager_url(start_page, items_per_page):
    """
    Generates url with given parameters

    :param start_page: int
    :param items_per_page: int
    :return: string
    """
    return "http://localhost/disruptions?items_per_page={}&start_page={}".format(items_per_page, start_page)
