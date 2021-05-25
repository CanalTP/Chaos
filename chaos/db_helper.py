# Copyright (c) since 2001, Kisio Digital and/or its affiliates. All rights reserved.

import json
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

    if not navitia.get_pt_object(json['id'], json['type']):
        raise exceptions.ObjectUnknown(
            "{} '{}' doesn't exist".format(
                json['type'],
                json['id']))

    pt_object = models.PTobject.get_pt_object_by_uri(json["id"])

    if pt_object:
        all_objects[json["id"]] = pt_object
        return pt_object

    pt_object = models.PTobject()
    mapper.fill_from_json(pt_object, json, mapper.object_mapping)
    if add_to_db:
        db.session.add(pt_object)
    all_objects[json["id"]] = pt_object
    return pt_object

def is_composed_pt_object(pt_object_json):
    return type(pt_object_json) is dict and \
           pt_object_json.get('type', '') in ['line_section', 'rail_section']

def manage_simple_pt_object(navitia, db_objects, json_attribute, json_data):
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
            if is_composed_pt_object(pt_object_json):
                continue
            ptobject = fill_and_get_pt_object(navitia, pt_object_dict, pt_object_json, False)

            if ptobject.uri not in pt_object_db:
                db_objects.append(ptobject)

    for ptobject_uri in pt_object_db:
        if ptobject_uri not in pt_object_dict:
            db_objects.remove(pt_object_db[ptobject_uri])


def manage_wordings(db_object, json):
    db_object.delete_wordings()

    # handle wordings
    wordings = json['wordings']

    for json_wording in wordings:
        db_wording = models.Wording()
        key = json_wording["key"].strip()
        if key == '':
            raise exceptions.InvalidJson('Json invalid: key is empty, you give : {}'.format(wordings))

        db_wording.key = json_wording["key"]
        db_wording.value = json_wording["value"]
        db_object.wordings.append(db_wording)

    # handle wording
    wording = db_object.wordings[0].value
    if 'wording' in json:
        wording = json['wording']
    db_object.wording = wording


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


def fill_and_add_line_section(navitia, all_objects, pt_object_json):
    """
    :param navitia: Class Navitia
    :param all_objects: dictionary of objects to be added in this session
    :param pt_object_json: Flux which contains json information of pt_object
    :return: pt_object and modify all_objects param
    """
    ptobject = models.PTobject()
    mapper.fill_from_json(ptobject, pt_object_json, mapper.object_mapping)

    # Here we treat all the objects in line_section like line, start_point, end_point
    if 'line_section' not in pt_object_json:
        raise exceptions.InvalidJson('Object of type line_section must have a line_section entry')
    line_section_json = pt_object_json['line_section']

    ptobject.uri = ":".join((line_section_json['line']['id'], ptobject.id))

    line_section = models.LineSection(ptobject.id)

    line_section.line = fill_and_get_pt_object(navitia, all_objects, line_section_json['line'])
    line_section.start_point = fill_and_get_pt_object(navitia, all_objects, line_section_json['start_point'])
    line_section.end_point = fill_and_get_pt_object(navitia, all_objects, line_section_json['end_point'])

    # Here we manage routes in line_section
    #"routes":[{"id":"route:MTD:9", "type": "route"}, {"id":"route:MTD:Nav23", "type": "route"}]
    if 'routes' in line_section_json:
        for route in line_section_json["routes"]:
            route_object = fill_and_get_pt_object(navitia, all_objects, route, True)
            line_section.routes.append(route_object)

    # Fill wordings from json
    #"meta":[{"key":"direction", "value": "1234"}, {"key":"direction", "value": "5678"}]
    if 'metas' in line_section_json:
        try:
            metas = {}
            metas['wordings'] = line_section_json['metas']
            manage_wordings(line_section, metas)
        except exceptions.InvalidJson:
            raise

    ptobject.insert_line_section(line_section)
    return ptobject

def fill_and_add_rail_section(navitia, all_objects, pt_object_json):
    """
    :param navitia: Class Navitia
    :param all_objects: dictionary of objects to be added in this session
    :param pt_object_json: Flux which contains json information of ordered pt_object
    :return: pt_object and modify all_objects param
    """
    ptobject = models.PTobject()
    mapper.fill_from_json(ptobject, pt_object_json, mapper.object_mapping)

    # Here we treat all the objects in rail_section like line, start_point, end_point
    if 'rail_section' not in pt_object_json:
        raise exceptions.InvalidJson('Object of type rail_section must have a rail_section entry')
    rail_section_json = pt_object_json['rail_section']

    ptobject.uri = ":".join((rail_section_json['start_point']['id'], rail_section_json['end_point']['id'], ptobject.id))

    rail_section = models.RailSection(ptobject.id)

    if 'line' in rail_section_json:
        rail_section.line = fill_and_get_pt_object(navitia, all_objects, rail_section_json['line'])

    rail_section.start_point = fill_and_get_pt_object(navitia, all_objects, rail_section_json['start_point'])
    rail_section.end_point = fill_and_get_pt_object(navitia, all_objects, rail_section_json['end_point'])

    # Here we manage blocked_stop_areas in rail_section
    if 'blocked_stop_areas' in rail_section_json:
        rail_section.blocked_stop_areas = json.dumps(rail_section_json["blocked_stop_areas"])

    if 'routes' in rail_section_json:
        for route in rail_section_json["routes"]:
            route_object = fill_and_get_pt_object(navitia, all_objects, route, True)
            rail_section.routes.append(route_object)

    ptobject.insert_rail_section(rail_section)
    return ptobject

def clean_message(msg, type=''):
    if type == 'text/html':
        msg.text = msg.text.replace('\r\n', ' ')

def manage_message(impact, json, client_id):
    # Same management for every cases as 'messages' is not required
    if 'messages' not in json:
        json['messages'] = []
    messages_db = dict((msg.channel_id, msg) for msg in impact.messages)
    messages_json = dict((msg["channel"]["id"], msg) for msg in json['messages'])

    manage_channels_required(messages_json, client_id)
    manage_message_db(impact, json, messages_json, messages_db, client_id)
    manage_delete_message_db(impact, messages_json, messages_db)

def manage_delete_message_db(impact, messages_json, messages_db):
    difference = set(messages_db) - set(messages_json)
    for diff in difference:
        impact.delete_message(messages_db[diff])

def manage_message_db(impact, json, messages_json, messages_db, client_id):
    for message_json in json['messages']:
        if message_json["channel"]["id"] in messages_db:
            msg = messages_db[message_json["channel"]["id"]]
            mapper.fill_from_json(msg, message_json, mapper.message_mapping)
            clean_message(msg, msg.channel.content_type)
            manage_message_meta(msg, message_json)
        else:
            message = models.Message()
            message.impact_id = impact.id
            mapper.fill_from_json(message, message_json, mapper.message_mapping)
            channel = models.Channel.get(message.channel_id, client_id)
            clean_message(message, channel.content_type)
            impact.insert_message(message)
            manage_message_meta(message, message_json)
            messages_db[message.channel_id] = message

def manage_channels_required(messages_json, client_id):
    channels_required = models.Channel.get_channels_required(client_id)
    if channels_required:
        for channel_required in channels_required:
            if channel_required.id not in messages_json or messages_json[channel_required.id] is None:
                raise exceptions.InvalidJson('Channel {} is required.'.format(channel_required.id))
            elif not messages_json[channel_required.id]['text']:
                raise exceptions.InvalidJson('Empty property \'text\' is not allowed for channel {}.'.format(channel_required.id))

def manage_message_meta(message, json):
    meta_db = dict((meta.key, meta) for meta in message.meta)
    metas_json = dict()
    if 'meta' in json:
        metas_json = dict((meta['key'], meta) for meta in json['meta'])
        for meta_json in json['meta']:
            if meta_json['key'] not in meta_db:
                meta = models.Meta()
                mapper.fill_from_json(meta, meta_json, mapper.meta_mapping)
                message.insert_meta(meta)
                meta_db[meta.key] = meta
            else:
                meta = meta_db[meta_json['key']]
                mapper.fill_from_json(meta, meta_json, mapper.meta_mapping)
    difference = set(meta_db) - set(metas_json)
    for diff in difference:
        message.delete_meta(meta_db[diff])


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
        impact_bd.upgrade_version()
    else:
        impact_bd = models.Impact()
        impact_bd.severity = models.Severity.get(json_impact['severity']['id'], disruption.client.id)
    impact_bd.disruption_id = disruption.id
    if 'send_notifications' in json_impact:
        impact_bd.send_notifications = json_impact['send_notifications']
    if 'notification_date' in json_impact:
        impact_bd.notification_date = json_impact['notification_date']

    db.session.add(impact_bd)
    # The ptobject is not added in the database before commit. If we have duplicate ptobject
    # in the json we have to handle it by using a dictionary. Each time we add a ptobject, we also
    # add it in the dictionary
    try:
        manage_simple_pt_object(navitia, impact_bd.objects, 'objects', json_impact)
    except exceptions.ObjectUnknown:
        raise
    all_objects = dict()
    if 'objects' in json_impact:
        for pt_object_json in json_impact['objects']:
            # For an pt_objects of the type 'line_section' we format uri : uri:impact_id
            # we insert this object in the table pt_object
            if pt_object_json["type"] == 'line_section':
                try:
                    ptobject = fill_and_add_line_section(navitia, all_objects, pt_object_json)
                except exceptions.ObjectUnknown as object_unknown_exception:
                    exceptions.InvalidJson = object_unknown_exception
                    raise
                impact_bd.objects.append(ptobject)
            if pt_object_json["type"] == 'rail_section':
                try:
                    ptobject = fill_and_add_rail_section(navitia, all_objects, pt_object_json)
                except exceptions.ObjectUnknown as object_unknown_exception:
                    exceptions.InvalidJson = object_unknown_exception
                    raise
                impact_bd.objects.append(ptobject)
     # Severity
    severity_json = json_impact['severity']
    if (not impact_bd.severity_id) or (impact_bd.severity_id and (severity_json['id'] != impact_bd.severity_id)):
        impact_bd.severity_id = severity_json['id']
        impact_bd.severity = models.Severity.get(impact_bd.severity_id, disruption.client.id)

    # For each object application_period_patterns create and fill a pattern and time_slots
    manage_patterns(impact_bd, json_impact)
    # This method creates a list of application periods either from application_period_patterns
    # or from apllication_periods in the data json
    app_periods_by_pattern = get_application_periods(json_impact)
    manage_application_periods(impact_bd, app_periods_by_pattern)
    manage_message(impact_bd, json_impact, disruption.client.id)

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


def manage_properties(disruption, json):
    """ Add properties linked to a post|put disruption by creating
        associate_disruption_property objects.
        The property has to be present in database or the function
        will end in error.

        Json format expected:
        "properties": [
            {
                "property_id": "",
                "value": ""
            }, ...
        ]
    """
    if 'properties' in json:
        properties_json = list()
        properties_db = list(
            (adp.property_id, adp.disruption_id, adp.value,)
            for adp in disruption.properties
        )
        for json_property in json['properties']:
            property_db = models.Property.get(
                disruption.client.id,
                json_property['property_id']
            )
            if property_db is None:
                raise exceptions.ObjectUnknown(
                    'property {} not found'.format(json_property['property_id'])
                )
            adp_db = create_adp(
                disruption,
                property_db.id,
                json_property['value']
            )
            properties_json.append(
                (adp_db.property_id, adp_db.disruption_id, adp_db.value,)
            )

        difference = set(properties_db) - set(properties_json)
        for diff in difference:
            adp = models.AssociateDisruptionProperty.get(*diff)
            db.session.delete(adp)


def create_adp(disruption, property_id, value):
    """ Create or update an associate_disruption_property object in database
    """
    adp = models.AssociateDisruptionProperty.get(
        property_id,
        disruption.id,
        value
    )

    if adp is None:
        adp = models.AssociateDisruptionProperty()
        adp.value = value
        adp.disruption_id = disruption.id
        adp.property_id = property_id
        db.session.add(adp)

    return adp


def manage_channel_types(db_object, json_types):
    db_object.delete_channel_types()
    for json_type in json_types:
        db_channel_type = models.ChannelType()
        db_channel_type.name = json_type
        db_object.insert_channel_type(db_channel_type)
