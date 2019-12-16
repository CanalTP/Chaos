# Copyright (c) since 2001, Kisio Digital and/or its affiliates. All rights reserved.

__all__ = ['disruptions_input_format', 'publication_status_values',
           'severity_input_format', 'id_format', 'cause_input_format',
           'disruption_status_values']
import re
import pytz
# see http://json-schema.org/

datetime_pattern = '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
date_pattern = '^\d{4}-\d{2}-\d{2}$'
id_format_text = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
id_format = re.compile(id_format_text)
pt_object_type_values = [
    "network",
    "stop_area",
    "line",
    "line_section",
    "route",
    "stop_point"
]
# Here Order of values is strict and is used to create query filters.
application_status_values = ["past", "ongoing", "coming"]
publication_status_values = ["past", "ongoing", "coming"]
time_pattern = '^\d{2}:\d{2}$'
week_pattern = '^[0-1]{7,7}$'
channel_type_values = [
    "web",
    "sms",
    "email",
    "mobile",
    "notification",
    "twitter",
    "facebook",
    "title",
    "beacon"
]
disruption_status_values = ["published", "draft"]


def get_object_format(object_type):
    return {
        'type': 'object',
        'properties': {
            'id': {'type': 'string', 'maxLength': 250},
            'type': {'enum': [object_type]}
        },
        'required': ['id', 'type']
    }


key_value_input_format = {
    'type': 'object',
    'properties': {
        'key': {'type': 'string', 'maxLength': 250, 'minLength': 1},
        'value': {'type': 'string', 'maxLength': 250}
    },
    'required': ['key', 'value']
}

date_period_format = {
    'type': 'object',
    'properties': {
        'begin': {'type': ['string'], 'pattern': datetime_pattern},
        'end': {'type': ['string', 'null'], 'pattern': datetime_pattern},
    },
    'required': ['begin', 'end']
}

one_object_type_format = {
    'type': 'object',
    'properties': {
        'id': {'type': 'string', 'maxLength': 250},
        'type': {'enum': pt_object_type_values}
    },
    'required': ['id', 'type']
}

line_section_format = {
    'type': 'object',
    'properties': {
        'line': get_object_format('line'),
        'start_point': get_object_format('stop_area'),
        'end_point': get_object_format('stop_area'),
        'sens': {'type': ['integer', 'null']},
        'routes': {
            'type': 'array',
            'items': get_object_format('route'),
            'uniqueItems': True
        },
        'via': {
            'type': 'array',
            'items': get_object_format('stop_area'),
            'uniqueItems': True
        },
        'metas': {
            'type': 'array',
            'items': key_value_input_format,
            'uniqueItems': True,
            'minItems': 1
        }
    },
    'required': ['line', 'start_point', 'end_point']
}

object_input_format = {
    'type': 'object',
    'properties': {
        'id': {'type': 'string', 'maxLength': 250},
        'type': {'enum': pt_object_type_values},
        'line_section': line_section_format
    },
    'required': ['id', 'type']
}

localization_object_input_format = {
    'type': 'object',
    'properties': {
        'id': {'type': 'string', 'maxLength': 250},
        'type': {'enum': ["stop_area"]}
    },
    'required': ['id', 'type']
}

tag_input_format = {
    'type': 'object',
    'properties': {
        'name': {'type': 'string', 'maxLength': 250},
    },
    'required': ['name']
}

property_input_format = {
    'type': 'object',
    'properties': {
        'key': {'type': 'string', 'minLength': 1, 'maxLength': 250},
        'type': {'type': 'string', 'minLength': 1, 'maxLength': 250}
    },
    'required': ['key', 'type']
}

associate_disruption_property_input_format = {
    'type': 'object',
    'properties': {
        'property_id': {'type': 'string', 'pattern': id_format_text},
        'value': {'type': 'string', 'minLength': 1, 'maxLength': 250}
    },
    'required': ['property_id', 'value']
}

category_input_format = {
    'type': 'object',
    'properties': {
        'name': {'type': 'string', 'maxLength': 250},
    },
    'required': ['name']
}

severity_input_format = {
    'type': 'object',
    'properties': {
        'wordings': {
            'type': 'array',
            'items': key_value_input_format,
            'uniqueItems': True,
            'minItems': 1
        },
        'color': {'type': ['string', 'null'], 'maxLength': 20},
        'priority': {'type': ['integer', 'null']},
        'effect': {
            'enum': [
                'no_service',
                'reduced_service',
                'significant_delays',
                'detour',
                'additional_service',
                'modified_service',
                'other_effect',
                'unknown_effect',
                'stop_moved',
                None
            ]
        },
    },
    'required': ['wordings']
}

cause_input_format = {
    'type': 'object',
    'properties': {
        'category': {
            'type': 'object',
            'properties': {
                'id': {
                    'type': 'string', 'pattern': id_format_text
                }
            },
            'required': ['id']
        },
        'wordings': {
            'type': 'array',
            'items': key_value_input_format,
            'uniqueItems': True,
            'minItems': 1
        }
    },
    'required': ['wordings']
}

channel_type_input_format = {'enum': channel_type_values}

channel_input_format = {
    'type': 'object',
    'properties': {
        'name': {'type': 'string', 'maxLength': 250},
        'max_size': {'type': ['integer', 'null']},
        'content_type': {'type': 'string', 'maxLength': 250},
        'required': {'type': 'boolean'},
        'types': {
            'type': 'array',
            'items': channel_type_input_format,
            'uniqueItems': True,
            'minItems': 1
        }
    },
    'required': ['name', 'max_size', 'content_type', 'types']
}

message_input_format = {
    'type': 'object',
    'properties': {
        'text': {'type': 'string'},
        'channel': {
            'type': 'object',
            'properties': {
                'id': {
                    'type': 'string', 'pattern': id_format_text
                }
            },
            'required': ['id']
        },
        'meta': {
            'type': 'array',
            'items': key_value_input_format
        }
    },
    'required': ['text', 'channel']
}

time_slot_input_format = {
    'type': 'object',
    'properties': {
        'begin': {'type': ['string'], 'pattern': time_pattern},
        'end': {'type': ['string'], 'pattern': time_pattern},
    },
    'required': ['begin', 'end']
}

pattern_input_format = {
    'type': 'object',
    'properties': {
        'start_date': {'type': ['string'], 'pattern': date_pattern},
        'end_date': {'type': ['string'], 'pattern': date_pattern},
        'weekly_pattern': {'type': ['string'], 'pattern': week_pattern},
        'time_slots': {
            'type': 'array',
            'items': time_slot_input_format,
            'uniqueItems': True,
            'minItems': 1
        },
        'time_zone': {'type': ['string'], 'enum': pytz.all_timezones}
    },
    'required': [
        'start_date',
        'end_date',
        'weekly_pattern',
        'time_slots',
        'time_zone'
    ]
}

impact_input_format = {
    'type': 'object',
    'properties': {
        'id': {'type': 'string', 'pattern': id_format_text},
        'severity': {
            'type': 'object',
            'properties': {
                'id': {
                    'type': 'string', 'pattern': id_format_text
                }
            },
            'required': ['id']
        },
        'application_periods': {
            'type': 'array',
            'items': date_period_format,
            'uniqueItems': True,
            'minItems': 1
        },
        'objects': {
            'type': 'array',
            'items': object_input_format,
            'uniqueItems': True,
            'minItems': 1
        },
        'messages': {
            'type': 'array',
            'items': message_input_format,
            'uniqueItems': True
        },
        'application_period_patterns': {
            'type': 'array',
            'items': pattern_input_format,
            'uniqueItems': True,
            'minItems': 1
        },
        'send_notifications': {'type': 'boolean'},
        'notification_date': {'type': ['string', 'null'], 'pattern': datetime_pattern}
    },
    'required': ['severity', 'objects'],
    'oneOf': [
        {'required': ['application_periods']},
        {'required': ['application_period_patterns']}
    ]
}

disruptions_input_format = {
    'type': 'object',
    'properties': {
        'reference': {'type': 'string', 'maxLength': 250},
        'note': {'type': ['string', 'null']},
        'status': {'enum': disruption_status_values},
        'publication_period': date_period_format,
        'contributor': {'type': 'string'},
        'cause': {
            'type': 'object',
            'properties': {
                'id': {'type': 'string', 'pattern': id_format_text}
            },
            'required': ['id']
        },
        'localization': {
            'type': 'array',
            'items': localization_object_input_format,
            'uniqueItems': True
        },
        'tags': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'id': {'type': 'string', 'pattern': id_format_text}
                },
                'required': ['id']
            },
            'uniqueItems': True
        },
        'impacts': {
            'type': 'array',
            'items': impact_input_format,
            'uniqueItems': True,
            'minItems': 1
        },
        'properties': {
            'type': 'array',
            'items': associate_disruption_property_input_format
        },
        'author': {'type': ['string', 'null']},
    },
    'required': ['reference', 'cause', 'contributor', 'impacts', 'publication_period']
}

disruptions_search_input_format = {
    'type': 'object',
    'properties': {
        'status': {
            'type': 'array',
            'items': {'enum': disruption_status_values},
            'uniqueItems': True,
            'minItems': 1
        },
        'tags': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'id': {'type': 'string', 'pattern': id_format_text}
                },
                'required': ['id']
            },
            'uniqueItems': True
        },
        'application_status': {
            'type': 'array',
            'items': {'enum': application_status_values},
            'uniqueItems': True
        },
        'publication_status': {
            'type': 'array',
            'items': {'enum': publication_status_values},
            'uniqueItems': True,
            'minItems': 1
        },
        'ptObjectFilter': {
            'anyOf': [
                {"required": ['networks']},
                {"required": ['lines']},
                {"required": ['stop_points']},
                {"required": ['stop_areas']}
            ],
            'type': 'object',
            'properties': {
                'networks': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                },
                'lines': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                },
                'stop_points': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                },
                'stop_areas': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                }
            }
        },
        'application_period': {
            'type': 'object',
            'properties': {
                'begin': {'type': ['string'], 'pattern': datetime_pattern},
                'end': {'type': ['string'], 'pattern': datetime_pattern}
            },
            'required': ['begin', 'end']
        }
    }
}
impacts_search_input_format = {
    'type': 'object',
    'properties': {
        'application_status': {
            'type': 'array',
            'items': {'enum': application_status_values},
            'uniqueItems': True
        },
        'ptObjectFilter': {
            'anyOf': [
                {"required": ['networks']},
                {"required": ['lines']},
                {"required": ['stop_points']},
                {"required": ['stop_areas']}
            ],
            'type': 'object',
            'properties': {
                'networks': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                },
                'lines': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                },
                'stop_points': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                },
                'stop_areas': {
                    'type': 'array',
                    'items': {'type': ['string']},
                    'uniqueItems': True
                }
            }
        },
        'application_period': {
            'type': 'object',
            'properties': {
                'begin': {'type': ['string'], 'pattern': datetime_pattern},
                'end': {'type': ['string'], 'pattern': datetime_pattern}
            },
            'required': ['begin', 'end']
        }
    }
}
export_input_format = {
    'type': 'object',
    'properties': {
        'start_date': {'type': ['string'], 'pattern': datetime_pattern},
        'end_date': {'type': ['string'], 'pattern': datetime_pattern}
    },
    'required': ['start_date', 'end_date']
}
contributor_input_format = {
    'type': 'object',
    'properties': {
        'code': {'type': 'string', 'maxLength': 250, 'minLength': 1},
    },
    'required': ['code']
}
