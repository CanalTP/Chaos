# Copyright (c) since 2001, Kisio Digital and/or its affiliates. All rights reserved.

import logging
import requests
from retrying import retry
from chaos import exceptions
from chaos import cache, app

__all__ = ['Navitia']


class Navitia(object):
    def __init__(self, url, coverage, token=None, timeout=app.config['NAVITIA_TIMEOUT']):
        self.url = url
        self.coverage = coverage
        self.token = token
        self.timeout = timeout
        self.collections = {
            "network": "networks",
            "stop_area": "stop_areas",
            "line": "lines",
            "route": "routes",
            "stop_point": "stop_points"
        }

    def query_formater(self, uri, object_type, pt_objects=None):
        if object_type == 'line_section':
            return None
        if object_type not in self.collections:
            logging.getLogger(__name__).exception('object type %s unknown', object_type)
            raise exceptions.ObjectTypeUnknown(object_type)

        if pt_objects and pt_objects != 'networks':
            logging.getLogger(__name__).exception('object type %s unknown', object_type)
            raise exceptions.ObjectTypeUnknown(object_type)

        query = '{url}/v1/coverage/{coverage}/{collection}/{uri}'.format(
            url=self.url, coverage=self.coverage, collection=self.collections[object_type], uri=uri)
        if pt_objects:
            query = '{q}/{objects}'.format(q=query, objects=pt_objects)
        return query + '?depth=0&disable_disruption=true'

    def _get_navitia_error_message(self, response, default_message):
        json = response.json()
        if json.get('message'):
            default_message = json.get('message')
        return default_message

    def _manage_unauthorized_response(self, response):
        if response.status_code == 401:
            error_message = self._get_navitia_error_message(response=response, default_message='call to navitia unauthorized')
            raise exceptions.Unauthorized(error_message)

    @retry(retry_on_exception=lambda e: isinstance(e, requests.exceptions.Timeout),
           stop_max_attempt_number=3, wait_fixed=100)
    def _navitia_caller(self, query):
        try:
            response = requests.get(query, headers={"Authorization": self.token}, timeout=self.timeout)
            self._manage_unauthorized_response(response)
            return response
        except requests.exceptions.Timeout:
            logging.getLogger(__name__).error('call to navitia timeout')
            raise requests.exceptions.Timeout('call to navitia timeout, data : {}'.format(query))
        except requests.exceptions.RequestException:
            logging.getLogger(__name__).exception('call to navitia failed')
            # currently we reraise the previous exceptions
            raise exceptions.NavitiaError('call to navitia failed, data : {}'.format(query))

    def get_pt_object(self, uri, object_type, pt_objects=None):
        cache_key = 'Chaos.get_pt_object.{}.{}.{}.{}.{}.{}'.format(self.coverage, self.get_coverage_publication_date(),
                                                                self.token, uri, object_type, pt_objects)
        try:
            cached_pt_object = cache.get(cache_key)
        except:
            logging.getLogger(__name__).exception('Cache Timeout')
            logging.getLogger(__name__).info('Trying to call navitia.')
            cached_pt_object = None

        if cached_pt_object is not None:
            logging.getLogger().debug('Cache hit for coverage/uri: %s/%s', self.coverage, uri)
            return cached_pt_object

        logging.getLogger().debug('Cache miss for coverage/uri: %s/%s', self.coverage, uri)
        logging.getLogger().debug('Publication date: %s', self.get_coverage_publication_date())

        try:
            query = self.query_formater(uri, object_type, pt_objects)
        except exceptions.ObjectTypeUnknown:
            raise

        if not query:
            return None

        try:
            response = self._navitia_caller(query)
        except (exceptions.NavitiaError, requests.exceptions.Timeout):
            raise

        if response:
            json = response.json()
            cache_timeout = app.config['CACHE_CONFIGURATION'].get('NAVITIA_CACHE_TIMEOUT', 3600)

            if pt_objects and json[pt_objects]:
                json_pt_objects = json[pt_objects]
                cache.set(cache_key, json_pt_objects, cache_timeout)
                return json_pt_objects

            if self.collections[object_type] in json and json[self.collections[object_type]]:
                json_pt_object = json[self.collections[object_type]][0]
                try:
                    cache.set(cache_key, json_pt_object, cache_timeout)
                except:
                    logging.getLogger(__name__).exception('Cache Timeout')
                    logging.getLogger(__name__).info('Set value in memory failed.')

                return json_pt_object

        return None

    @cache.memoize(timeout=app.config['CACHE_CONFIGURATION'].get('NAVITIA_PUBDATE_CACHE_TIMEOUT', 600))
    def get_coverage_publication_date(self):
        logging.getLogger().debug('Cache miss for publication date coverage %s', self.coverage)
        uri = '{}/v1/coverage/{}/status'.format(self.url, self.coverage)
        try:
            response = self._navitia_caller(uri)
        except exceptions.NavitiaError:
            raise

        if response:
            json = response.json()
            return json['status']['publication_date']

        return None

    def find_tc_object_name(self, uri, type):
        if not uri or not type:
            return None

        if type in ['line_section', 'rail_section']:
            return None

        response = self.get_pt_object(uri, type)
        if response and 'name' in response:
            return response['name']
        return 'Unable to find object'

    def __repr__(self):
        """
        Overrides __repr__ method in order to separate cached entities by token, coverage and url
        :return: String
        """
        return 'chaos.Navitia(url=%s, coverage=%s, token=%s, timeout=%d)' % (self.url, self.coverage,
                                                                             self.token, self.timeout)
