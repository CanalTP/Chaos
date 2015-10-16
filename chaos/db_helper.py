# Copyright (c) 2001-2014, Canal TP and/or its affiliates. All rights reserved.
#
# This file is part of Navitia,
#     the software to build cool stuff with public transport.
#
# Hope you'll enjoy and contribute to this project,
#     powered by Canal TP (www.canaltp.fr).
# Help us simplify mobility and open public transport:
#     a non ending quest to the responsive locomotion way of traveling!
#
# LICENCE: This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Stay tuned using
# twitter @navitia
# IRC #navitia on freenode
# https://groups.google.com/d/forum/navitia
# www.navitia.io

from chaos import models, exceptions, mapper, db
from utils import get_application_periods

def fill_and_get_pt_object(navitia, all_objects, json, add_to_db=True):
    """
    :param all_objects: dictionary of objects to be added in this session
    :param json: Flux which contains json information of pt_object
    :param add_to_db: ptobject insert into database
    :return: a pt_object and modify all_objects param
    """

    if json["id"] in all_objects:
        return all_objects[json["id"]]

    pt_object = models.PTobject.get_pt_object_by_uri(json["id"])

    if pt_object:
        all_objects[json["id"]] = pt_object
        return pt_object

    if not navitia.get_pt_object(json['id'], json['type']):
        raise exceptions.ObjectUnknown()

    pt_object = models.PTobject()
    mapper.fill_from_json(pt_object, json, mapper.object_mapping)
    if add_to_db:
        db.session.add(pt_object)
    all_objects[json["id"]] = pt_object
    return pt_object


def manage_pt_object_without_line_section(navitia, db_objects, json_attribute, json_data):
    '''
    :param navitia:
    :param db_objects: pt_object in database models : localisations, objects
    :param json_pt_object: attribute in json
    :param json_data: data
    :return:
    '''
    pt_object_db = dict()
    for ptobject in db_objects:
            pt_object_db[ptobject.uri] = ptobject

    pt_object_dict = dict()
    if json_attribute in json_data:
        for pt_object_json in json_data[json_attribute]:
            if pt_object_json["type"] == 'line_section':
                continue
            try:
                ptobject = fill_and_get_pt_object(navitia, pt_object_dict, pt_object_json, False)
            except exceptions.ObjectUnknown:
                raise exceptions.ObjectUnknown('ptobject {} doesn\'t exist'.format(pt_object_json['id']))

            if ptobject.uri not in pt_object_db:
                db_objects.append(ptobject)

    for ptobject_uri in pt_object_db:
        if ptobject_uri not in pt_object_dict:
            db_objects.remove(pt_object_db[ptobject_uri])


def manage_wordings(db_object, json_wordings):
    db_object.delete_wordings()
    for json_wording in json_wordings:
        db_wording = models.Wording()
        key = json_wording["key"].strip()
        if key == '':
            raise exceptions.InvalidJson('Json invalid: key is empty, you give : {}'.format(json_wordings))
        db_wording.key = json_wording["key"]
        db_wording.value = json_wording["value"]
        db_object.wordings.append(db_wording)
    db_object.wording = db_object.wordings[0].value


def manage_tags(disruption, json):
    tags_db = dict((tag.id, tag) for tag in disruption.tags)
    tags_json = {}
    if 'tags' in json:
        tags_json = dict((tag["id"], tag) for tag in json['tags'])
        for tag_json in json['tags']:
            if tag_json["id"] not in tags_db:
                tag = models.Tag.get(tag_json['id'], disruption.client.id)
                disruption.tags.append(tag)
                tags_db[tag_json['id']] = tag
    difference = set(tags_db) - set(tags_json)
    for diff in difference:
        tag = tags_db[diff]
        disruption.tags.remove(tag)


def fill_and_add_line_section(navitia, impact_id, all_objects, pt_object_json):
    """
    :param impact_id: impact_id to construct uri of line_section object
    :param all_objects: dictionary of objects to be added in this session
    :param pt_object_json: Flux which contains json information of pt_object
    :return: pt_object and modify all_objects param
    """
    ptobject = models.PTobject()
    mapper.fill_from_json(ptobject, pt_object_json, mapper.object_mapping)
    ptobject.uri = ":".join(ptobject.uri.split(':')[:-1])
    ptobject.uri = ":".join((ptobject.uri, impact_id))

    #Here we treat all the objects in line_section like line, start_point, end_point
    line_section_json = pt_object_json['line_section']
    line_section = models.LineSection(ptobject.id)

    try:
        line_object = fill_and_get_pt_object(navitia, all_objects, line_section_json['line'])
    except exceptions.ObjectUnknown:
        raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(line_section_json['line']['type'], line_section_json['line']['id']))

    line_section.line = line_object

    try:
        start_object = fill_and_get_pt_object(navitia, all_objects, line_section_json['start_point'])
    except exceptions.ObjectUnknown:
        raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(line_section_json['line']['type'], line_section_json['line']['id']))
    line_section.start_point = start_object

    try:
        end_object = fill_and_get_pt_object(navitia, all_objects, line_section_json['end_point'])
    except exceptions.ObjectUnknown:
        raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(line_section_json['line']['type'], line_section_json['line']['id']))
    line_section.end_point = end_object

    #Here we manage routes in line_section
    #"routes":[{"id":"route:MTD:9", "type": "route"}, {"id":"route:MTD:Nav23", "type": "route"}]
    if 'routes' in line_section_json:
        for route in line_section_json["routes"]:
            try:
                route_object = fill_and_get_pt_object(navitia, all_objects, route, True)
                line_section.routes.append(route_object)
            except exceptions.ObjectUnknown:
                raise exceptions.ObjectUnknown('{} {} doesn\'t exist'.format(route['type'], route['id']))

    ptobject.insert_line_section(line_section)
    return ptobject


def manage_message(impact, json):
    messages_db = dict((msg.channel_id, msg) for msg in impact.messages)
    messages_json = dict()
    if 'messages' in json:
        messages_json = dict((msg["channel"]["id"], msg) for msg in json['messages'])
        for message_json in json['messages']:
            if message_json["channel"]["id"] in messages_db:
                msg = messages_db[message_json["channel"]["id"]]
                mapper.fill_from_json(msg, message_json, mapper.message_mapping)
            else:
                message = models.Message()
                message.impact_id = impact.id
                mapper.fill_from_json(message, message_json, mapper.message_mapping)
                impact.insert_message(message)
                messages_db[message.channel_id] = message

    difference = set(messages_db) - set(messages_json)
    for diff in difference:
        impact.delete_message(messages_db[diff])


def manage_application_periods(impact, application_periods):
    impact.delete_app_periods()
    for app_period in application_periods:
        db_application_period = models.ApplicationPeriods(impact.id)
        db_application_period.start_date = app_period[0]
        db_application_period.end_date = app_period[1]
        impact.insert_app_period(db_application_period)


def manage_patterns(impact, json):
    impact.delete_patterns()
    if 'application_period_patterns' in json:
        for json_pattern in json['application_period_patterns']:
            pattern = models.Pattern(impact.id)
            mapper.fill_from_json(pattern, json_pattern, mapper.pattern_mapping)
            impact.insert_pattern(pattern)
            manage_time_slot(pattern, json_pattern)


def manage_time_slot(pattern, json):
    if 'time_slots' in json:
        for json_time_slot in json['time_slots']:
            time_slot = models.TimeSlot(pattern.id)
            mapper.fill_from_json(time_slot, json_time_slot, mapper.time_slot_mapping)
            pattern.insert_time_slot(time_slot)


def create_or_update_impact(disruption, json_impact, navitia, impact_id=None):
    if impact_id:
        # impact exist in database
        impact_bd = models.Impact.get(impact_id, disruption.contributor.id)
    else:
        impact_bd = models.Impact()
        impact_bd.severity = models.Severity.get(json_impact['severity']['id'], disruption.client.id)
    impact_bd.disruption_id = disruption.id
    if 'send_notifications' in json_impact:
        impact_bd.send_notifications = json_impact['send_notifications']

    db.session.add(impact_bd)
    #The ptobject is not added in the database before commit. If we have duplicate ptobject
    #in the json we have to handle it by using a dictionary. Each time we add a ptobject, we also
    #add it in the dictionary
    try:
        manage_pt_object_without_line_section(navitia, impact_bd.objects, 'objects', json_impact)
    except exceptions.ObjectUnknown:
        raise
    all_objects = dict()
    if 'objects' in json_impact:
        for pt_object_json in json_impact['objects']:
            #For an pt_objects of the type 'line_section' we format uri : uri:impact_id
            # we insert this object in the table pt_object
            if pt_object_json["type"] == 'line_section':
                try:
                    ptobject = fill_and_add_line_section(navitia, impact_bd.id, all_objects, pt_object_json)
                except exceptions.ObjectUnknown:
                    raise
                impact_bd.objects.append(ptobject)
     # Severity
    severity_json = json_impact['severity']
    if (not impact_bd.severity_id) or (impact_bd.severity_id and (severity_json['id'] != impact_bd.severity_id)):
        impact_bd.severity_id = severity_json['id']
        impact_bd.severity = models.Severity.get(impact_bd.severity_id, disruption.client.id)

    #For each object application_period_patterns create and fill a pattern and time_slots
    manage_patterns(impact_bd, json_impact)
    #This method creates a list of application periods either from application_period_patterns
    # or from apllication_periods in the data json
    app_periods_by_pattern = get_application_periods(json_impact)
    manage_application_periods(impact_bd, app_periods_by_pattern)
    manage_message(impact_bd, json_impact)

    return impact_bd


def manage_impacts(disruption, json, navitia):
    if 'impacts' in json:
        impacts_db = dict((impact.id, impact) for impact in disruption.impacts)
        impacts_json = dict()

        for json_impact in json['impacts']:
            if 'id' in json_impact:
                impact_id = json_impact['id']
            else:
                impact_id = None
            impact_bd = create_or_update_impact(disruption, json_impact, navitia, impact_id)
            impacts_json[impact_bd.id] = impact_bd

        difference = set(impacts_db) - set(impacts_json)
        for diff in difference:
            impacts_db[diff].archive()


def manage_channel_types(db_object, json_types):
    db_object.delete_channel_types()
    for json_type in json_types:
        db_channel_type = models.ChannelType()
        db_channel_type.name = json_type
        db_object.insert_channel_type(db_channel_type)
