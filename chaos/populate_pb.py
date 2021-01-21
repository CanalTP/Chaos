# Copyright (c) since 2001, Kisio Digital and/or its affiliates. All rights reserved.

import chaos_pb2
import gtfs_realtime_pb2
import datetime


def get_pos_time(sql_time):
    if sql_time:
        return int((sql_time - datetime.datetime(1970, 1, 1)).total_seconds())
    return 0


def get_pos_date(sql_date):
    if sql_date:
        return int((sql_date - datetime.date(1970, 1, 1)).total_seconds())
    return 0


def get_time_seconds(time):
    if time:
        return int(datetime.timedelta(hours=time.hour, minutes=time.minute, seconds=time.second).total_seconds())
    return 0


def get_pt_object_type(type):
    collection = {
        "network": chaos_pb2.PtObject.network,
        "stop_area": chaos_pb2.PtObject.stop_area,
        "line": chaos_pb2.PtObject.line,
        "line_section": chaos_pb2.PtObject.line_section,
        "route": chaos_pb2.PtObject.route,
        "stop_point": chaos_pb2.PtObject.stop_point
    }
    if type in collection:
        return collection[type]
    return chaos_pb2.PtObject.unkown_type


def get_channel_type(type):
    try:
        return chaos_pb2.Channel.Type.Value(type)
    except ValueError:
        return chaos_pb2.Channel.unkown_type


def created_upated_at(src, dest):
    dest.created_at = get_pos_time(src.created_at)
    if src.updated_at:
        dest.updated_at = get_pos_time(src.updated_at)


def get_severity_effect_value(effect):
    available_effects = {
        'no_service': gtfs_realtime_pb2.Alert.NO_SERVICE,
        'reduced_service': gtfs_realtime_pb2.Alert.REDUCED_SERVICE,
        'significant_delays': gtfs_realtime_pb2.Alert.SIGNIFICANT_DELAYS,
        'detour': gtfs_realtime_pb2.Alert.DETOUR,
        'additional_service': gtfs_realtime_pb2.Alert.ADDITIONAL_SERVICE,
        'modified_service': gtfs_realtime_pb2.Alert.MODIFIED_SERVICE,
        'other_effect': gtfs_realtime_pb2.Alert.OTHER_EFFECT,
        'unknown_effect': gtfs_realtime_pb2.Alert.UNKNOWN_EFFECT,
        'stop_moved': gtfs_realtime_pb2.Alert.STOP_MOVED
    }
    if effect in available_effects.keys():
        return available_effects[effect]

    return available_effects['unknown_effect']


def populate_severity(impact_pb, severity):
    impact_pb.severity.id = severity.id
    impact_pb.severity.wording = severity.wording
    if severity.color:
        impact_pb.severity.color = severity.color

    impact_pb.severity.effect = get_severity_effect_value(severity.effect)
    if severity.priority:
        impact_pb.severity.priority = severity.priority


def populate_application_periods(impact, impact_pb):
    for application_period in impact.application_periods:
        application_period_pb = impact_pb.application_periods.add()
        application_period_pb.start = get_pos_time(application_period.start_date)
        if application_period.end_date:
            application_period_pb.end = get_pos_time(application_period.end_date)


def populate_application_patterns(impact, impact_pb):
    for pattern in impact.patterns:
        pattern_pb = impact_pb.application_patterns.add()
        pattern_pb.start_date = get_pos_date(pattern.start_date)
        pattern_pb.end_date = get_pos_date(pattern.end_date)
        pattern_pb.week_pattern.monday = bool(int(pattern.weekly_pattern[0]))
        pattern_pb.week_pattern.tuesday = bool(int(pattern.weekly_pattern[1]))
        pattern_pb.week_pattern.wednesday = bool(int(pattern.weekly_pattern[2]))
        pattern_pb.week_pattern.thursday = bool(int(pattern.weekly_pattern[3]))
        pattern_pb.week_pattern.friday = bool(int(pattern.weekly_pattern[4]))
        pattern_pb.week_pattern.saturday = bool(int(pattern.weekly_pattern[5]))
        pattern_pb.week_pattern.sunday = bool(int(pattern.weekly_pattern[6]))
        populate_time_slot(pattern, pattern_pb)
        pattern_pb.timezone = pattern.time_zone


def populate_time_slot(pattern, pattern_pb):
    for time_slot in pattern.time_slots:
        time_slot_pb = pattern_pb.time_slots.add()
        time_slot_pb.begin = get_time_seconds(time_slot.begin)
        time_slot_pb.end = get_time_seconds(time_slot.end)


def populate_channel_type(channel, channel_pb):
    if channel.channel_types:
        for type in channel.channel_types:
            channel_pb.types.append(get_channel_type(type.name))


def populate_channel(channel_pb, channel):
    channel_pb.id = channel.id
    channel_pb.name = channel.name
    channel_pb.content_type = channel.content_type
    channel_pb.max_size = long(channel.max_size)
    created_upated_at(channel, channel_pb)
    populate_channel_type(channel, channel_pb)


def populate_messages(impact, impact_pb):
    for message in impact.messages:
        message_pb = impact_pb.messages.add()
        message_pb.text = message.text
        created_upated_at(message, message_pb)
        populate_channel(message_pb.channel, message.channel)
        for meta in message.meta:
            meta_pb = message_pb.meta.add()
            meta_pb.key = meta.key
            meta_pb.value = meta.value


def populate_informed_entitie(pt_object, informed_entitie):
    informed_entitie.pt_object_type = get_pt_object_type(pt_object.type)
    informed_entitie.uri = pt_object.uri
    created_upated_at(pt_object, informed_entitie)


def populate_pt_objects(impact, impact_pb):
    for pt_object in impact.objects:
        informed_entitie = impact_pb.informed_entities.add()
        populate_informed_entitie(pt_object, informed_entitie)
        if pt_object.type == 'line_section':
            populate_informed_entitie(pt_object.line_section.line, informed_entitie.pt_line_section.line)
            populate_informed_entitie(pt_object.line_section.start_point, informed_entitie.pt_line_section.start_point)
            populate_informed_entitie(pt_object.line_section.end_point, informed_entitie.pt_line_section.end_point)
            if hasattr(pt_object.line_section, 'routes'):
                for route in pt_object.line_section.routes:
                    route_pb = informed_entitie.pt_line_section.routes.add()
                    populate_informed_entitie(route, route_pb)


def populate_impact(disruption, disruption_pb):
    for impact in disruption.impacts:
        if impact.status == "published":
            impact_pb = disruption_pb.impacts.add()
            impact_pb.id = impact.id
            if hasattr(impact, 'send_notifications') and impact.send_notifications:
                impact_pb.send_notifications = impact.send_notifications
            if hasattr(impact, 'notification_date') and impact.notification_date:
                impact_pb.notification_date = get_pos_time(impact.notification_date)
            created_upated_at(impact, impact_pb)
            populate_severity(impact_pb, impact.severity)
            populate_application_periods(impact, impact_pb)
            populate_messages(impact, impact_pb)
            populate_pt_objects(impact, impact_pb)
            populate_application_patterns(impact, impact_pb)


def populate_localization(disruption, disruption_pb):
    if hasattr(disruption, 'localizations'):
        if disruption.localizations:
            for localization in disruption.localizations:
                populate_informed_entitie(localization, disruption_pb.localization.add())


def populate_tag(disruption, disruption_pb):
    if disruption.tags:
        for tag in disruption.tags:
            tag_pb = disruption_pb.tags.add()
            tag_pb.id = tag.id
            tag_pb.name = tag.name
            created_upated_at(tag, tag_pb)


def populate_category(category, category_pb):
    category_pb.id = category.id
    category_pb.name = category.name


def populate_cause(cause, cause_pb):
    cause_pb.id = cause.id
    cause_pb.wording = cause.wording
    for wording in cause.wordings:
        wording_pb = cause_pb.wordings.add()
        wording_pb.key = wording.key
        wording_pb.value = wording.value
    if cause.category:
        populate_category(cause.category, cause_pb.category)


def populate_property(disruption, disruption_pb):
    if disruption.properties:
        for prop in disruption.properties:
            d_property = disruption_pb.properties.add()
            d_property.key = prop.property.key
            d_property.type = prop.property.type
            d_property.value = prop.value


def populate_disruption(disruption, disruption_pb):
    disruption_pb.id = disruption.id
    disruption_pb.reference = disruption.reference
    if disruption.contributor and disruption.contributor.contributor_code:
        disruption_pb.contributor = disruption.contributor.contributor_code

    if disruption.note:
        disruption_pb.note = disruption.note
    created_upated_at(disruption, disruption_pb)
    if disruption.start_publication_date:
        disruption_pb.publication_period.start = get_pos_time(disruption.start_publication_date)
    if disruption.end_publication_date:
        disruption_pb.publication_period.end = get_pos_time(disruption.end_publication_date)

    populate_cause(disruption.cause, disruption_pb.cause)
    populate_localization(disruption, disruption_pb)
    populate_tag(disruption, disruption_pb)
    populate_impact(disruption, disruption_pb)
    populate_property(disruption, disruption_pb)


def populate_pb(disruption):
    feed_message = gtfs_realtime_pb2.FeedMessage()
    feed_message.header.gtfs_realtime_version = '1.0'
    feed_message.header.incrementality = gtfs_realtime_pb2.FeedHeader.DIFFERENTIAL
    feed_message.header.timestamp = get_pos_time(datetime.datetime.utcnow())

    feed_entity = feed_message.entity.add()
    feed_entity.id = disruption.id
    feed_entity.is_deleted = (disruption.status == "archived")

    if not feed_entity.is_deleted:
        disruption_pb = feed_entity.Extensions[chaos_pb2.disruption]
        populate_disruption(disruption, disruption_pb)
    return feed_message
