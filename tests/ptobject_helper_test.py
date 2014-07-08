from nose.tools import *
import chaos
from chaos import ptobject_helper

class Obj(object):
    pass

def format_url():
    pass

def get_response():
'''{
    "stop_areas": [
        {
            "comment": "",
            "name": "Château de Vincennes",
            "coord": {
                "lat": "48.844536",
                "lon": "2.43951"
            },
            "administrative_regions": [
                {
                    "id": "108346",
                    "level": 8,
                    "name": "Vincennes",
                    "coord": {
                        "lat": "48.84745",
                        "lon": "2.439671"
                    },
                    "zip_code": "94300"
                },
                {
                    "id": "2975222",
                    "level": 10,
                    "name": "Centre Ville",
                    "coord": {
                        "lat": "48.8469801199371",
                        "lon": "2.43941678023654"
                    },
                    "zip_code": ""
                }
            ],
            "id": "stop_area:JDR:SA:CHVIN"
        }
    ]

}'''
    pass

#First page, 2 elements per page, 10 elements in total, without previous page link.
def test_is_valid_object():
    chaos.app.config['SERVER_NAME'] = 'http://localhost'
    with chaos.app.app_context():
        ptobject_hlepr = ptobject_helper.PTobjectHelper()
        ptobject_hlepr.format_url = format_url
        ptobject_hlepr.get_response = get_response