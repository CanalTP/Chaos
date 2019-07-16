import json

from flask_restful import marshal
from flask import g
from fields import disruption_fields_for_history
from aniso8601 import parse_datetime, parse_time, parse_date
from chaos import db, models, mapper


def save_in_database(disruption_id, disruption_json):
    history_disruption = models.HistoryDisruption()

    history_disruption.disruption_id = disruption_id
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
    disruption = marshal(data, disruption_fields_for_history)
    g.display_impacts = old_display_impacts

    clean_before_save_in_history(disruption)
    disruption['impacts'] = disruption['impacts']['impacts']
    save_in_database(data.id, json.dumps(disruption))


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


def get_datetime_from_json_attr(json, attr):
    return parse_datetime(json[attr]).replace(tzinfo=None) if attr in json and json[attr] else None


def create_contributor_from_json(contributor_code):
    contributor = models.Contributor()
    contributor.contributor_code = contributor_code
    return contributor


def create_cause_from_json(cause_json):
    cause = models.Cause()
    cause.id = cause_json['id']
    cause.created_at = get_datetime_from_json_attr(cause_json, 'created_at')
    cause.updated_at = get_datetime_from_json_attr(cause_json, 'updated_at')
    cause.wordings = create_cause_wordings_from_json(cause_json['wordings'])
    cause.category = create_cause_category_from_json(cause_json)

    return cause


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


def create_cause_wordings_from_json(cause_wording_json):
    cause_wordings = []

    for wording in cause_wording_json:
        cause_wordings.append(generate_wording_from_json(wording))

    return cause_wordings


def generate_wording_from_json(json):
    wording = models.Wording()
    wording.key = json['key']
    wording.value = json['value']
    return wording


def create_tags_from_json(tags_json):
    tags = []

    for tag_json in tags_json:
        tag = create_tag_from_json(tag_json)
        tags.append(tag)

    return tags


def create_tag_from_json(json):
    tag = models.Tag()
    tag.id = json['id']
    tag.created_at = get_datetime_from_json_attr(json, 'created_at')
    tag.updated_at = get_datetime_from_json_attr(json, 'updated_at')
    tag.name = json['name']

    return tag


def create_properties_from_json(json, disruption_id):
    properties = []
    for key, property in json.items():
        for sub_property in property:
            property_json = sub_property['property']
            value = sub_property['value']
            adp_model = create_associate_disruption_property_from_json(property_json, disruption_id, value)
            properties.append(adp_model)

    return properties


def create_associate_disruption_property_from_json(json, disruption_id, value):
    adp = models.AssociateDisruptionProperty()
    adp.disruption_id = disruption_id
    adp.property_id = json['id']
    adp.value = value
    adp.property = create_property_from_json(json)

    return adp


def create_property_from_json(json):
    property = models.Property()
    property.id = json['id']
    property.type = json['type']
    property.key = json['key']
    property.created_at = get_datetime_from_json_attr(json, 'created_at')
    property.updated_at = get_datetime_from_json_attr(json, 'updated_at')

    return property


def create_impacts_from_json(impacts_json, disruption_id):
    impacts = []
    for impact_json in impacts_json:
        impact = create_impact_from_json(impact_json, disruption_id)
        impacts.append(impact)

    return impacts


def create_impact_from_json(json, disruption_id):
    impact = models.Impact()
    impact.id = json['id']
    impact.status = 'published'
    impact.disruption_id = disruption_id
    impact.updated_at = get_datetime_from_json_attr(json, 'updated_at')
    impact.created_at = get_datetime_from_json_attr(json, 'created_at')
    impact.send_notifications = json['send_notifications']
    impact.notification_date = get_datetime_from_json_attr(json, 'notification_date')

    severity = create_severity_from_json(json['severity'])

    impact.severity_id = severity.id
    impact.severity = severity

    impact.application_periods = create_application_periods_from_json(json)
    impact.patterns = create_application_period_patterns_from_json(json)
    impact.messages = create_messages_from_json(json)
    impact.objects = create_pt_objects_from_json(json)

    return impact


def create_severity_from_json(json):
    severity = models.Severity()
    mapper.fill_from_json(severity, json, mapper.severity_mapping)
    severity.id = json['id']
    severity.wording = json['wording']
    severity.created_at = get_datetime_from_json_attr(json, 'created_at')
    severity.updated_at = get_datetime_from_json_attr(json, 'updated_at')
    severity.wordings = create_severity_wordings_from_json(json['wordings'])
    return severity


def create_severity_wordings_from_json(json):
    wordings = []
    for wording_json in json:
        wording = models.Wording()
        mapper.fill_from_json(wording, wording_json, mapper.meta_mapping)
        wordings.append(wording)
    return wordings


def create_application_periods_from_json(json):
    periods = []
    for app_period_json in json['application_periods']:
        period = create_application_period_from_json(app_period_json, json['id'])
        periods.append(period)

    return periods


def create_application_period_from_json(json, impact_id):
    period = models.ApplicationPeriods()
    period.start_date = get_datetime_from_json_attr(json, 'begin')
    period.end_date = get_datetime_from_json_attr(json, 'end')
    period.impact_id = impact_id

    return period


def create_application_period_patterns_from_json(json):
    patterns = []
    for pattern_json in json['application_period_patterns']:
        pattern = create_application_period_pattern_from_json(pattern_json)
        patterns.append(pattern)

    return patterns


def create_application_period_pattern_from_json(json):
    pattern = models.Pattern()
    mapper.fill_from_json(pattern, json, mapper.pattern_mapping)
    pattern.time_slots = create_pattern_time_slots_from_json(json['time_slots'])

    return pattern


def create_pattern_time_slots_from_json(json):
    time_slots = []
    for time_slot_json in json:
        time_slot = models.TimeSlot()
        mapper.fill_from_json(time_slot, time_slot_json, mapper.time_slot_mapping)
        time_slots.append(time_slot)

    return time_slots


def create_messages_from_json(json):
    messages = []
    for message_json in json['messages']:
        message = create_message_from_json(message_json)
        messages.append(message)

    return messages


def create_message_from_json(json):
    channel = create_channel_from_json(json['channel'])

    message = models.Message()
    message.created_at = get_datetime_from_json_attr(json, 'created_at')
    message.updated_at = get_datetime_from_json_attr(json, 'updated_at')
    message.text = json['text']
    message.meta = create_metas_from_json(json['meta'])
    message.channel_id = channel.id
    message.channel = channel

    return message


def create_pt_objects_from_json(json):
    pt_objects = []
    for pt_object_json in json['objects']:
        pt_object = create_pt_object_from_json(pt_object_json)
        pt_objects.append(pt_object)

    return pt_objects


def create_pt_object_from_json(json):
    pt_object = models.PTobject()
    mapper.fill_from_json(pt_object, json, mapper.object_mapping)

    if 'line_section' in json:
        pt_object.line_section = create_line_section_from_json(json['line_section'])
    elif 'name' in json:
        pt_object.name = json['name']

    return pt_object


def create_line_section_from_json(json):
    line_section = models.LineSection()
    line_section.line = generate_pt_object_from_json(json['line'])
    line_section.start_point = generate_pt_object_from_json(json['start_point'])
    line_section.end_point = generate_pt_object_from_json(json['end_point'])
    if 'routes' in json:
        line_section.routes = generate_routes_pt_object_from_json(json['routes'])

    return line_section


def create_metas_from_json(json):
    metas = []
    for meta_json in json:
        meta = models.Meta()
        mapper.fill_from_json(meta, meta_json, mapper.meta_mapping)
        metas.append(meta)

    return metas


def create_channel_from_json(json):
    channel = models.Channel()
    channel.id = json['id']
    mapper.fill_from_json(channel, json, mapper.channel_mapping)
    channel.created_at = get_datetime_from_json_attr(json, 'created_at')
    channel.updated_at = get_datetime_from_json_attr(json, 'updated_at')
    channel.channel_types = create_channel_types_from_json(json)

    return channel


def create_channel_types_from_json(json):
    channel_types = []
    for channel_type_json in json['types']:
        channel_type = models.ChannelType()
        channel_type.name = channel_type_json
        channel_types.append(channel_type)

    return channel_types


def generate_pt_object_from_json(json):
    pt_object = models.PTobject()
    mapper.fill_from_json(pt_object, json, mapper.object_mapping)
    pt_object.name = json['name']

    return pt_object


def generate_routes_pt_object_from_json(json):
    routes = []
    for route in json:
        routes.append(generate_pt_object_from_json(route))

    return routes


def get_date_from_json_attr(json, attr):
    return parse_date(json[attr])


def get_time_from_json_attr(json, attr):
    return parse_time(json[attr])
