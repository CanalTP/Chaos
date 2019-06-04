import json

from flask_restful import marshal
from flask import g
from fields import disruption_fields
from aniso8601 import parse_datetime, parse_time, parse_date
from chaos import db, models


def save_disruption(disruption, disruption_json):
    history_disruption = models.HistoryDisruption()

    history_disruption.disruption_id = disruption.id
    history_disruption.version = disruption.version
    history_disruption.data = disruption_json
    db.session.add(history_disruption)
    db.session.commit()


def clean_before_save_in_history(disruption):
    if not isinstance(disruption, dict):
        return
    for key in disruption.keys():
        if key in ['self', 'href', 'pagination']:
            disruption.pop(key)
        elif isinstance(disruption[key], dict):
            clean_before_save_in_history(disruption[key])
        elif isinstance(disruption[key], list):
            for item in disruption[key]:
                clean_before_save_in_history(item)


def save_disruption_in_history(data):
    old_display_impacts = g.get('display_impacts')
    g.display_impacts = True
    disruption = marshal(data, disruption_fields)
    g.display_impacts = old_display_impacts

    clean_before_save_in_history(disruption)
    disruption['impacts'] = disruption['impacts']['impacts']
    save_disruption(data, json.dumps(disruption))


def get_datetime_from_json_attr(json, attr):
    return parse_datetime(json[attr]).replace(tzinfo=None) if attr in json and json[attr] else None


def get_date_from_json_attr(json, attr):
    return parse_date(json[attr])


def get_time_from_json_attr(json, attr):
    return parse_time(json[attr])


def generate_ptobject_from_json(json):
    ptobject = models.PTobject()
    ptobject.type = json['type']
    ptobject.uri = json['id']
    ptobject.name = json['name']
    return ptobject


def create_contributor_from_json(contributor_code):
    contributor = models.Contributor()
    contributor.contributor_code = contributor_code
    return contributor


def create_cause_wordings_from_json(cause_wording_json):
    cause_wordings = []

    for wording in cause_wording_json:
        wording_model = models.Wording()
        wording_model.key = wording['key']
        wording_model.value = wording['value']
        cause_wordings.append(wording_model)

    return cause_wordings


def create_cause_category_from_json(json_data):
    if not json_data['category']:
        return None

    category = models.Category()
    cause_json_data = json_data['category']
    category.id = cause_json_data['id']
    category.created_at = get_datetime_from_json_attr(cause_json_data, 'created_at')
    category.updated_at = get_datetime_from_json_attr(cause_json_data, 'updated_at')
    category.name = cause_json_data['name']

    return category


def create_cause_from_json(cause_json):
    cause = models.Cause()
    cause.id = cause_json['id']
    cause.created_at = get_datetime_from_json_attr(cause_json, 'created_at')
    cause.updated_at = get_datetime_from_json_attr(cause_json, 'updated_at')
    cause.wordings = create_cause_wordings_from_json(cause_json['wordings'])
    cause.category = create_cause_category_from_json(cause_json)

    return cause


def create_tags_from_json(tags_json):
    tags = []

    for item in tags_json:
        tag = models.Tag()
        tag.id = item['id']
        tag.created_at = get_datetime_from_json_attr(item, 'created_at')
        tag.updated_at = get_datetime_from_json_attr(item, 'updated_at')
        tag.name = item['name']
        tags.append(tag)

    return tags


def create_properties_from_json(properties_json, disruption_id):
    disruption_properties = []
    for key, property in properties_json.items():
        for sub_property in property:
            adp_model = models.AssociateDisruptionProperty()
            adp_model.disruption_id = disruption_id
            adp_model.property_id = sub_property['property']['id']
            adp_model.value = sub_property['value']
            property_model = models.Property()
            property_model.id = sub_property['property']['id']
            property_model.type = sub_property['property']['type']
            property_model.key = sub_property['property']['key']
            property_model.created_at = get_datetime_from_json_attr(sub_property['property'], 'created_at')
            property_model.updated_at = get_datetime_from_json_attr(sub_property['property'], 'updated_at')
            adp_model.property = property_model
            disruption_properties.append(adp_model)

    return disruption_properties


def create_impacts_from_json(impacts_json, disruption_id):
    impacts = []
    for impact in impacts_json:
        impact_model = models.Impact()
        impact_model.updated_at = get_datetime_from_json_attr(impact, 'updated_at')
        impact_model.created_at = get_datetime_from_json_attr(impact, 'created_at')
        impact_model.disruption_id = disruption_id
        impact_model.id = impact['id']
        impact_model.send_notifications = impact['send_notifications']
        impact_model.notification_date = get_datetime_from_json_attr(impact, 'notification_date')

        impact_model.severity_id = impact['severity']['id']
        severity_model = models.Severity()
        severity_model.id = impact['severity']['id']
        severity_model.wording = impact['severity']['wording']
        severity_model.color = impact['severity']['color']
        severity_model.effect = impact['severity']['effect']
        severity_model.priority = impact['severity']['priority']
        severity_model.created_at = get_datetime_from_json_attr(impact['severity'], 'created_at')
        severity_model.updated_at = get_datetime_from_json_attr(impact['severity'], 'updated_at')

        severity_wordings = []
        for wording in impact['severity']['wordings']:
            wording_model = models.Wording()
            wording_model.value = wording['value']
            wording_model.key = wording['key']
            severity_wordings.append(wording_model)

        severity_model.wordings = severity_wordings
        impact_model.severity = severity_model

        application_periods = []
        for application_period in impact['application_periods']:
            application_period_model = models.ApplicationPeriods()
            application_period_model.start_date = get_datetime_from_json_attr(application_period, 'begin')
            application_period_model.end_date = get_datetime_from_json_attr(application_period, 'end')
            application_period_model.impact_id = impact['id']
            application_periods.append(application_period_model)

        impact_model.application_periods = application_periods

        application_period_patterns = []
        for application_period_pattern in impact['application_period_patterns']:
            application_period_pattern_model = models.Pattern()
            application_period_pattern_model.weekly_pattern = application_period_pattern['weekly_pattern']
            application_period_pattern_model.start_date = get_date_from_json_attr(application_period_pattern,
                                                                                  'start_date')
            application_period_pattern_model.end_date = get_date_from_json_attr(application_period_pattern, 'end_date')

            time_slots = []
            for time_slot in application_period_pattern['time_slots']:
                time_slot_model = models.TimeSlot()
                time_slot_model.begin = get_time_from_json_attr(time_slot, 'begin')
                time_slot_model.end = get_time_from_json_attr(time_slot, 'end')
                time_slots.append(time_slot_model)

            application_period_pattern_model.time_slots = time_slots
            application_period_patterns.append(application_period_pattern_model)

        impact_model.patterns = application_period_patterns

        messages = []
        for message in impact['messages']:
            message_model = models.Message()
            message_model.created_at = get_datetime_from_json_attr(message, 'created_at')
            message_model.updated_at = get_datetime_from_json_attr(message, 'updated_at')
            message_model.text = message['text']

            channel_model = models.Channel()
            channel_model.name = message['channel']['name']
            channel_model.created_at = get_datetime_from_json_attr(message['channel'], 'created_at')
            channel_model.updated_at = get_datetime_from_json_attr(message['channel'], 'updated_at')
            channel_model.required = message['channel']['required']
            channel_model.max_size = message['channel']['max_size']
            channel_model.content_type = message['channel']['content_type']
            channel_model.id = message['channel']['id']

            channel_types = []
            for channel_type in message['channel']['types']:
                channel_type_model = models.ChannelType()
                channel_type_model.name = channel_type
                channel_types.append(channel_type_model)

            channel_model.channel_types = channel_types

            message_model.channel_id = message['channel']['id']
            message_model.channel = channel_model

            metas = []
            for meta in message['meta']:
                meta_model = models.Meta()
                meta_model.key = meta['key']
                meta_model.value = meta['value']
                metas.append(meta_model)

            message_model.meta = metas

            messages.append(message_model)

        impact_model.messages = messages

        ptobjects = []
        for ptobject in impact['objects']:
            ptobject_model = models.PTobject()
            ptobject_model.type = ptobject['type']
            ptobject_model.uri = ptobject['id']

            if 'line_section' in ptobject:
                line_section_model = models.LineSection()
                line_section_model.line = generate_ptobject_from_json(ptobject['line_section']['line'])
                line_section_model.start_point = generate_ptobject_from_json(ptobject['line_section']['start_point'])
                line_section_model.end_point = generate_ptobject_from_json(ptobject['line_section']['end_point'])
                ptobject_model.line_section = line_section_model
            elif 'name' in ptobject:
                ptobject_model.name = ptobject['name']
            ptobjects.append(ptobject_model)

        impact_model.status = 'published'
        impact_model.objects = ptobjects
        impacts.append(impact_model)

    return impacts


def create_disruption_from_json(json):
    disruption = models.Disruption()
    disruption.id = json['id']
    disruption.reference = json['reference']
    disruption.note = json['note']
    disruption.status = json['status']
    disruption.version = json['version']
    disruption.created_at = get_datetime_from_json_attr(json, 'created_at')
    disruption.updated_at = get_datetime_from_json_attr(json, 'updated_at')
    disruption.reference = json['reference']
    disruption.start_publication_date = get_datetime_from_json_attr(json['publication_period'], 'begin')
    disruption.end_publication_date = get_datetime_from_json_attr(json['publication_period'], 'end')
    disruption.publicationStatus = json['publication_status']
    disruption.history_localization = json['localization']
    disruption.contributor = create_contributor_from_json(json['contributor'])
    disruption.cause = create_cause_from_json(json['cause'])
    disruption.tags = create_tags_from_json(json['tags'])
    disruption.properties = create_properties_from_json(json['properties'], json['id'])
    disruption.impacts = create_impacts_from_json(json['impacts'], json['id'])

    return disruption
