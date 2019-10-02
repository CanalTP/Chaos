from nose.tools import *
from chaos.utils import get_traffic_report_objects, get_pt_object_from_list, filter_disruptions_by_ptobjects
import chaos
from mock import MagicMock


class Obj(object):
    pass


def test_get_traffic_report_objects():
    dd = get_traffic_report_objects([], Obj(), {}, [])
    eq_(len(dd["traffic_report"].items()), 0)


def test_get_traffic_report_without_objects():
    disruption = chaos.models.Disruption()
    dd = get_traffic_report_objects([disruption], Obj(), {}, [])
    eq_(len(dd["traffic_report"].items()), 0)


def test_get_pt_object_from_list_None():
    stop_area = chaos.models.PTobject()
    stop_area.type = 'stop_area'
    stop_area.uri = 'uri1'
    eq_(get_pt_object_from_list(stop_area, []), None)


def test_get_pt_object_from_list_True():
    stop_area = chaos.models.PTobject()
    stop_area.type = 'stop_area'
    stop_area.uri = 'uri1'
    eq_(get_pt_object_from_list(stop_area, [{'id': 'uri1', 'name': 'stop area name'}]),
        {'id': 'uri1', 'name': 'stop area name'})


def test_get_pt_object_from_list_True_2_objects():
    stop_area = chaos.models.PTobject()
    stop_area.type = 'stop_area'
    stop_area.uri = 'uri1'
    eq_(get_pt_object_from_list(stop_area, [{'id': 'uri2', 'name': 'stop area name'},
                                            {'id': 'uri1', 'name': 'stop area name'}]),
        {'id': 'uri1', 'name': 'stop area name'})


def test_get_traffic_report_with_network():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = MagicMock(return_value={"id": "uri1", "name": "network name"})
    network = chaos.models.PTobject()
    network.type = 'network'
    network.uri = 'uri1'
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'
    impact.objects.append(network)
    disruption.impacts.append(impact)
    result = {
        "uri1": {
            "network": {
                "id": "uri1",
                "name": "network name",
                "impacts": [impact]
            }
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, {}, [])
    eq_(dd["traffic_report"], result)


def get_pt_object(uri, object_type, pt_objects=None):

    if uri == 'network:uri1' and not pt_objects:
        return {'id': 'network:uri1', 'name': 'network 1 name'}

    if uri == 'network:uri2' and not pt_objects:
        return {'id': 'network:uri2', 'name': 'network 2 name'}

    if uri == 'line:uri1' and pt_objects:
        return [{'id': 'network:uri1', 'name': 'network 1 name'}]

    if uri == 'line:uri3' and pt_objects:
        return [{'id': 'network:uri1', 'name': 'network 1 name'}]

    if uri == 'line:uri2' and not pt_objects:
        return {'id': 'line:uri2', 'name': 'line 2 name'}

    if uri == 'stop_area:uri1' and not pt_objects:
        return {'id': 'stop_area:uri1', 'name': 'stop area 1 name'}

    if uri == 'stop_area:uri1' and pt_objects:
        return [{'id': 'network:uri3', 'name': 'network 3 name'}]

    if uri == 'line:uri1' and not pt_objects:
        return {'id': 'line:uri1', 'name': 'line 1 name'}

    if uri == 'line:uri2' and pt_objects:
        return [{'id': 'network:uri2', 'name': 'network 2 name'}]

    if uri == 'line:uri3' and not pt_objects:
        return {'id': 'line:uri3', 'name': 'line 3 name', 'code': 'line 3 code'}

    if uri == 'stop_area:uri2' and not pt_objects:
        return {'id': 'stop_area:uri2', 'name': 'stop area 2 name'}

    if uri == 'stop_area:uri2' and pt_objects:
        return [{'id': 'network:uri4', 'name': 'network 4 name'}, {'id': 'network:uri5', 'name': 'network 5 name'}]


def test_get_traffic_report_with_impact_on_lines():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'

    line = chaos.models.PTobject()
    line.type = 'line'
    line.uri = 'line:uri1'
    impact.objects.append(line)

    line = chaos.models.PTobject()
    line.type = 'line'
    line.uri = 'line:uri2'
    impact.objects.append(line)
    disruption.impacts.append(impact)

    result = {
        "network:uri1": {
            "network": {
                "id": "network:uri1",
                "name": "network 1 name"
            },
            "lines": [{'id': 'line:uri1', 'name': 'line 1 name', "impacts": [impact]}]
        },
        "network:uri2": {
            "network": {
                "id": "network:uri2",
                "name": "network 2 name"
            },
            "lines": [{'id': 'line:uri2', 'name': 'line 2 name', "impacts": [impact]}]
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, {}, [])
    eq_(dd["traffic_report"], result)


def test_get_traffic_report_with_impact_on_networks():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'

    line = chaos.models.PTobject()
    line.type = 'network'
    line.uri = 'network:uri1'
    impact.objects.append(line)

    line = chaos.models.PTobject()
    line.type = 'network'
    line.uri = 'network:uri2'
    impact.objects.append(line)
    disruption.impacts.append(impact)

    result = {
        "network:uri1": {
            "network": {
                "id": "network:uri1",
                "name": "network 1 name",
                "impacts": [impact]
            }
        },
        "network:uri2": {
            "network": {
                "id": "network:uri2",
                "name": "network 2 name",
                "impacts": [impact]
            }
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, {}, [])

    eq_(dd["traffic_report"], result)


def test_get_traffic_report_with_impact_on_stop_areas_one_network():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'

    line = chaos.models.PTobject()
    line.type = 'stop_area'
    line.uri = 'stop_area:uri1'
    impact.objects.append(line)
    disruption.impacts.append(impact)

    result = {
        "network:uri3": {
            "network": {
                "id": "network:uri3",
                "name": "network 3 name"
            },
            "stop_areas": [{'id': 'stop_area:uri1', 'name': 'stop area 1 name', "impacts": [impact]}]
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, {}, [])
    eq_(dd["traffic_report"], result)


def test_get_traffic_report_with_impact_on_stop_areas_2_networks_and_filter_activated():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'

    line = chaos.models.PTobject()
    line.type = 'stop_area'
    line.uri = 'stop_area:uri2'
    impact.objects.append(line)
    disruption.impacts.append(impact)

    result = {
        "network:uri5": {
            "network": {
                "id": "network:uri5",
                "name": "network 5 name"
            },
            "stop_areas": [{'id': 'stop_area:uri2', 'name': 'stop area 2 name', "impacts": [impact]}]
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, {}, ["network:uri5"])
    eq_(dd["traffic_report"], result)


def test_get_traffic_report_with_impact_on_stop_areas_2_networks():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'

    line = chaos.models.PTobject()
    line.type = 'stop_area'
    line.uri = 'stop_area:uri2'
    impact.objects.append(line)
    disruption.impacts.append(impact)

    result = {
        "network:uri4": {
            "network": {
                "id": "network:uri4",
                "name": "network 4 name"
            },
            "stop_areas": [{'id': 'stop_area:uri2', 'name': 'stop area 2 name', "impacts": [impact]}]
        },
        "network:uri5": {
            "network": {
                "id": "network:uri5",
                "name": "network 5 name"
            },
            "stop_areas": [{'id': 'stop_area:uri2', 'name': 'stop area 2 name', "impacts": [impact]}]
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, {}, [])
    eq_(dd["traffic_report"], result)


def test_get_traffic_report_with_2_impact_on_stop_area():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruptions = []
    impacts = []

    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'
    stop_area = chaos.models.PTobject()
    stop_area.type = 'stop_area'
    stop_area.uri = 'stop_area:uri1'
    impact.objects.append(stop_area)
    disruption.impacts.append(impact)
    disruptions.append(disruption)
    impacts.append(impact)

    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'
    stop_area = chaos.models.PTobject()
    stop_area.type = 'stop_area'
    stop_area.uri = 'stop_area:uri1'
    impact.objects.append(stop_area)
    disruption.impacts.append(impact)
    disruptions.append(disruption)
    impacts.append(impact)

    result = {
        "network:uri3": {
            "network": {
                "id": "network:uri3",
                "name": "network 3 name"
            },
            "stop_areas": [{'id': 'stop_area:uri1', 'name': 'stop area 1 name', "impacts": impacts}]
        }
    }
    dd = get_traffic_report_objects(disruptions, navitia, {}, [])
    eq_(dd["traffic_report"], result)


def test_get_traffic_report_with_impact_on_line_sections():
    navitia = chaos.navitia.Navitia('http://api.navitia.io', 'jdr')
    navitia.get_pt_object = get_pt_object
    disruption = chaos.models.Disruption()
    impact = chaos.models.Impact()
    impact.status = 'published'

    #LineSection
    ptobject = chaos.models.PTobject()
    ptobject.uri = "line_section:123"
    ptobject.type = "line_section"
    ptobject.line_section = chaos.models.LineSection()
    ptobject.line_section.id = '7ffab234-3d49-4eea-aa2c-22f8680230b6'
    ptobject.line_section.sens = 1
    ptobject.line_section.line = chaos.models.PTobject()
    ptobject.line_section.line.uri = 'line:uri3'
    ptobject.line_section.line.type = 'line'

    ptobject.line_section.start_point = chaos.models.PTobject()
    ptobject.line_section.start_point.uri = 'stop_area:1'
    ptobject.line_section.start_point.type = 'stop_area'

    ptobject.line_section.end_point = chaos.models.PTobject()
    ptobject.line_section.end_point.uri = 'stop_area:2'
    ptobject.line_section.end_point.type = 'stop_area'

    impact.objects.append(ptobject)
    disruption.impacts.append(impact)

    result = {
        "network:uri1": {
            "network": {
                "id": "network:uri1",
                "name": "network 1 name"
            },
            "line_sections": [
                {
                    "id": "7ffab234-3d49-4eea-aa2c-22f8680230b6",
                    "line_section": {
                        "end_point": {
                            "id": "stop_area:2",
                            "type": "stop_area"
                        },
                        "line": {
                            "id": "line:uri3",
                            "name": "line 3 name",
                            "type": "line",
                            "code": "line 3 code"
                        },
                        "start_point": {
                            "id": "stop_area:1",
                            "type": "stop_area"
                        },
                        "routes": [],
                        "via": [],
                        "metas": []
                    },
                    "type": "line_section",
                    "impacts": [impact]
                }
            ]
        }
    }
    dd = get_traffic_report_objects([disruption], navitia, { ptobject.id: ptobject.line_section }, [])
    eq_(dd["traffic_report"], result)

def test_filter_disruptions_by_ptobjects():
    disruption_1 = chaos.models.Disruption()
    impact_1 = chaos.models.Impact()
    impact_1.status = 'published'

    #LineSection
    ptobject_1 = chaos.models.PTobject()
    ptobject_1.uri = "line:uri3:7ffab234-3d49-4eea-aa2c-22f8680230b6"
    ptobject_1.type = "line_section"
    ptobject_1.line_section = chaos.models.LineSection()
    ptobject_1.line_section.id = '7ffab234-3d49-4eea-aa2c-22f8680230b6'
    ptobject_1.line_section.sens = 1
    ptobject_1.line_section.line = chaos.models.PTobject()
    ptobject_1.line_section.line.uri = 'line:uri3'
    ptobject_1.line_section.line.type = 'line'

    ptobject_1.line_section.start_point = chaos.models.PTobject()
    ptobject_1.line_section.start_point.uri = 'stop_area:1'
    ptobject_1.line_section.start_point.type = 'stop_area'

    ptobject_1.line_section.end_point = chaos.models.PTobject()
    ptobject_1.line_section.end_point.uri = 'stop_area:2'
    ptobject_1.line_section.end_point.type = 'stop_area'

    impact_1.objects.append(ptobject_1)
    disruption_1.impacts.append(impact_1)

    filter_pt_object = {
        "networks": ["network:uri1"],
        "lines": ["line:uri3"]
    }
    list_disruption = [disruption_1]
    filter_disruptions_by_ptobjects(list_disruption, filter_pt_object)
    eq_(list_disruption, [disruption_1])
    filter_pt_object = {
        "networks": ["network:uri1"],
        "lines": ["line:uri2"]
    }
    filter_disruptions_by_ptobjects(list_disruption, filter_pt_object)
    eq_(list_disruption, [])
