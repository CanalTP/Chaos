from collections import OrderedDict
from chaos.utils import get_publication_status

def map_disruption(results):
    disruptions = OrderedDict()
    impacts = {}
    tags = {}
    cause_wordings = {}
    severity_wordings = {}
    impact_pt_objects = {}
    properties = {}
    localizations = {}
    application_periods = {}
    messages = {}
    channels = {}
    channel_types = {}
    message_metas = {}
    application_period_patterns = {}
    time_slots = {}
    line_section_metas = {}
    line_section_routes = {}
    rail_section_routes = {}

    for r in results:
        disruptionId = r.id
        tagId = r.tag_id
        wordingId = r.cause_wording_id
        property_id = r.property_id
        localization_id = r.localization_id
        impact_id = r.impact_id
        severity_id = r.severity_id
        severity_wording_id = r.severity_wording_id
        impact_pt_object_id = r.pt_object_id
        application_period_id = r.application_period_id
        message_id = r.message_id
        channel_id = r.channel_id
        channel_type_id = r.channel_type_id
        message_meta_id = r.meta_id
        application_period_patterns_id = r.pattern_id
        time_slot_id = r.time_slot_id
        line_section_id = r.line_section_id
        rail_section_id = r.rail_section_id

        if disruptionId not in impacts:
            impacts[disruptionId] = {}
        if impact_id is not None:
            impacts[disruptionId][impact_id] = {
                'id': r.impact_id,
                'disruption_id': r.id,
                'created_at': r.impact_created_at,
                'updated_at': r.impact_updated_at,
                'send_notifications': r.impact_send_notifications,
                'notification_date': r.impact_notification_date
            }
            impacts[disruptionId][impact_id]['severity'] = {
                'id': r.severity_id,
                'client_id': r.severity_client_id,
                'effect': r.severity_effect,
                'priority': r.severity_priority,
                'is_visible': r.severity_is_visible,
                'color': r.severity_color,
                'wording': r.severity_wording,
                'updated_at': r.severity_updated_at,
                'created_at': r.severity_created_at
            }

        if impact_id not in application_period_patterns:
            application_period_patterns[impact_id] = {}
        if application_period_patterns_id is not None:
            application_period_patterns[impact_id][application_period_patterns_id] = {
                'id': r.pattern_id,
                'start_date': r.pattern_start_date,
                'end_date': r.pattern_end_date,
                'weekly_pattern': r.pattern_weekly_pattern,
                'timezone': r.pattern_timezone
            }
        if application_period_patterns_id not in time_slots:
            time_slots[application_period_patterns_id] = {}
        if application_period_patterns_id is not None:
            time_slots[application_period_patterns_id][time_slot_id] = {
                'begin': r.time_slot_begin,
                'end': r.time_slot_end
            }

        if impact_id not in application_periods:
            application_periods[impact_id] = {}
        if application_period_id is not None:
            application_periods[impact_id][application_period_id] = {
                'start_date': r.application_period_start_date,
                'end_date': r.application_period_end_date
            }

        if impact_id not in messages:
            messages[impact_id] = {}

        if message_id not in channels:
            channels[message_id] = {}

        if message_id is not None:
            messages[impact_id][message_id] = {
                'id': r.message_id,
                'created_at': r.message_created_at,
                'updated_at': r.message_updated_at,
                'text': r.message_text,
                'meta': [],
                'channel': {
                    'id': channel_id,
                    'content_type': r.channel_content_type,
                    'created_at': r.channel_created_at,
                    'updated_at': r.channel_updated_at,
                    'max_size': r.channel_max_size,
                    'name': r.channel_name,
                    'required': r.channel_required
                }
            }

        if channel_id is not None and channel_id not in channel_types:
            channel_types[channel_id] = {}

        if channel_type_id is not None:
            if channel_type_id not in channel_types[channel_id]:
                channel_types[channel_id][channel_type_id] = {}
            channel_types[channel_id][channel_type_id].update({
                'name': r.channel_type_name
            })
        if message_id not in message_metas:
            message_metas[message_id] = {}
        if message_meta_id is not None:
            message_metas[message_id][message_meta_id] = {
                'key': r.meta_key,
                'value': r.meta_value
            }

        if severity_id not in severity_wordings:
            severity_wordings[severity_id] = {}
        if severity_wording_id is not None:
            severity_wordings[severity_id][severity_wording_id] = {
                'key': r.severity_wording_key,
                'value': r.severity_wording_value
            }

        if impact_id not in impact_pt_objects:
            impact_pt_objects[impact_id] = {}
        if impact_pt_object_id is not None:
            impact_pt_objects[impact_id][impact_pt_object_id] = {
                'id': r.pt_object_id,
                'uri': r.pt_object_uri,
                'type': r.pt_object_type,
            }
            if line_section_id is not None:
                if impact_pt_object_id not in line_section_metas:
                    line_section_metas[impact_pt_object_id] = {}
                if impact_pt_object_id not in line_section_routes:
                    line_section_routes[impact_pt_object_id] = {}

                if r.awlsw_id is not None:
                    line_section_metas[impact_pt_object_id][r.awlsw_id] = {
                        'key': r.awlsw_key,
                        'value': r.awlsw_value
                    }
                if r.po_route_id is not None:
                    line_section_routes[impact_pt_object_id][r.po_route_id] = {
                        'uri': r.po_route_uri,
                        'type': r.po_route_type
                    }
                impact_pt_objects[impact_id][impact_pt_object_id]['line_section'] = {
                    'line': {
                        'uri': r.line_section_line_uri,
                        'type': r.line_section_line_type
                    },
                    'start_point': {
                        'uri': r.line_section_start_uri,
                        'type': r.line_section_start_type
                    },
                    'end_point': {
                        'uri': r.line_section_end_uri,
                        'type': r.line_section_end_type
                    },
                    'routes': [],
                    'metas': []
                }
            if rail_section_id is not None:
                if impact_pt_object_id not in rail_section_routes:
                    rail_section_routes[impact_pt_object_id] = {}

                if r.por_route_id is not None:
                    rail_section_routes[impact_pt_object_id][r.por_route_id] = {
                        'uri': r.por_route_uri,
                        'type': r.por_route_type
                    }
                impact_pt_objects[impact_id][impact_pt_object_id]['rail_section'] = {
                    'line': {
                        'uri': r.rail_section_line_uri,
                        'type': r.rail_section_line_type
                    },
                    'start_point': {
                        'uri': r.rail_section_start_uri,
                        'type': r.rail_section_start_type
                    },
                    'end_point': {
                        'uri': r.rail_section_end_uri,
                        'type': r.rail_section_end_type
                    },
                    'routes': rail_section_routes[impact_pt_object_id].values(),
                    'metas': []
                }
        if disruptionId not in localizations:
            localizations[disruptionId] = {}
        if localization_id is not None:
            localizations[disruptionId][localization_id] = {
                'uri': r.localization_uri,
                'type': r.localization_type
            }

        if disruptionId not in properties:
            properties[disruptionId] = {}
        if property_id is not None:
            properties[disruptionId][property_id] = {
                'id': r.property_id,
                'key': r.property_key,
                'type': r.property_type,
                'value': r.property_value,
                'created_at': r.property_created_at,
                'updated_at': r.property_updated_at
            }

        if disruptionId not in cause_wordings:
            cause_wordings[disruptionId] = {}
        cause_wordings[disruptionId][wordingId] = {
            'key': r.cause_wording_key,
            'value': r.cause_wording_value
        }

        if disruptionId not in tags:
            tags[disruptionId] = {}
        if tagId is not None:
            tags[disruptionId][tagId] = {
                'id': tagId,
                'name': r.tag_name,
                'created_at': r.tag_created_at,
                'updated_at': r.tag_updated_at
            }

        if disruptionId not in disruptions:
            disruption = {
                "id": disruptionId,
                "reference": r.reference,
                'note': r.note,
                'status': r.status,
                'version': r.version,
                'created_at': r.created_at,
                'updated_at': r.updated_at,
                'start_publication_date': r.start_publication_date,
                'end_publication_date': r.end_publication_date,
                'publication_status': get_publication_status(r.start_publication_date, r.end_publication_date),
                'contributor': {
                    'contributor_code': r.contributor_code
                },
                'cause': {
                    'id': r.cause_id,
                    'created_at': r.cause_created_at,
                    'updated_at': r.cause_updated_at,
                    'wordings': [],
                    'category': {
                        'id': r.cause_category_id,
                        'name': r.cause_category_name,
                        'created_at': r.cause_category_created_at,
                        'updated_at': r.cause_category_updated_at
                    }
                },
                'tags': [],
                'impacts': [],
                'properties': [],
                'localizations': [],
                'author': r.author
            }
            disruptions[disruptionId] = disruption

    for disruption in disruptions.values():
        disruptionId = disruption['id']
        disruption['tags'] = tags[disruptionId].values()
        disruption['cause']['wordings'] = cause_wordings[disruptionId].values()
        disruption['properties'] = properties[disruptionId].values()
        disruption['localizations'] = localizations[disruptionId].values()
        disruption['impacts'] = impacts[disruptionId].values()
        for impact in disruption['impacts']:
            impact_id = impact['id']
            impact['severity']['wordings'] = severity_wordings[impact['severity']['id']].values()
            impact['objects'] = impact_pt_objects[impact_id].values()
            impact['application_periods'] = application_periods[impact_id].values()
            impact['messages'] = messages[impact_id].values()
            impact['patterns'] = application_period_patterns[impact_id].values()

            for message in impact['messages']:
                channel_id = message['channel']['id']
                message_id = message['id']
                message['channel']['channel_types'] = channel_types[channel_id].values()
                message['meta'] = message_metas[message_id].values()
            for application_period_pattern in impact['patterns']:
                application_period_pattern_id = application_period_pattern['id']
                application_period_pattern['time_slots'] = time_slots[application_period_pattern_id].values()
            for pt_object in impact['objects']:
                impact_pt_object_id = pt_object['id']
                if impact_pt_object_id in line_section_routes:
                    pt_object['line_section']['routes'] = line_section_routes[impact_pt_object_id].values()
                if impact_pt_object_id in line_section_metas:
                    pt_object['line_section']['wordings'] = line_section_metas[impact_pt_object_id].values()

    return disruptions
