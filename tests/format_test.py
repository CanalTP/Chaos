from nose.tools import *
from chaos import formats

from jsonschema import validate, Draft4Validator, ValidationError


def test_validate_date_period_format():
    Draft4Validator.check_schema(formats.date_period_format)


def test_validate_disruption_format():
    Draft4Validator.check_schema(formats.disruptions_input_format)


def test_validate_severity_format():
    Draft4Validator.check_schema(formats.severity_input_format)


def test_validate_cause_format():
    Draft4Validator.check_schema(formats.cause_input_format)


def test_validate_property_format():
    Draft4Validator.check_schema(formats.property_input_format)


def test_validate_associte_disruption_property_format():
    Draft4Validator.check_schema(
        formats.associate_disruption_property_input_format
    )


def test_severities_validation():
    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'color': 'a'*20}
    validate(json, formats.severity_input_format)

    json['priority'] = 2
    validate(json, formats.severity_input_format)

    json['effect'] = None
    validate(json, formats.severity_input_format)


@raises(ValidationError)
def test_severities_validation_color_has_max_length():
    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'color': 'a'*21}
    validate(json, formats.severity_input_format)


@raises(ValidationError)
def test_severities_validation_wording_has_max_length():
    json = {'wordings': [{'key': 'foo', 'value': 't'*251}]}
    validate(json, formats.severity_input_format)


@raises(ValidationError)
def test_severities_validation_wording_is_required():
    json = {'color': 'aa'}
    validate(json, formats.severity_input_format)


def test_severities_validation_effect_can_be_null_or_blocking():
    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'effect': 'no_service'}
    validate(json, formats.severity_input_format)

    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'effect': 'no_service'}
    validate(json, formats.severity_input_format)


@raises(ValidationError)
def test_severities_validation_value_of_effect_is_limited():
    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'effect': 'nonblocking'}
    validate(json, formats.severity_input_format)


def test_severities_validation_priority_is_int_or_null():
    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'priority': None}
    validate(json, formats.severity_input_format)

    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'priority': 1}
    validate(json, formats.severity_input_format)


@raises(ValidationError)
def test_severities_validation_is_int_or_null_2():
    json = {'wordings': [{'key': 'foo', 'value': 'test'}], 'priority': '1'}
    validate(json, formats.severity_input_format)


def test_causes_validation():
    json = {'wordings': [{"key": "aa", "value": "bb"}], 'category': {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}}
    validate(json, formats.cause_input_format)


@raises(ValidationError)
def test_causes_without_wordings_validation():
    json = {'category': {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}}
    validate(json, formats.cause_input_format)


@raises(ValidationError)
def test_causes_wordings_empty_validation():
    json = {'wordings': [], 'category': {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}}
    validate(json, formats.cause_input_format)


@raises(ValidationError)
def test_causes_validation_wording_is_required():
    json = {}
    validate(json, formats.cause_input_format)


def test_validate_channel_format():
    Draft4Validator.check_schema(formats.channel_input_format)


def test_channels_validation():
    json = {'name': 'short', 'max_size': 200, 'content_type': 'text/plain', 'types': ['web']}
    validate(json, formats.channel_input_format)

    json = {'name': 'short', 'max_size': 200, 'content_type': '', 'types': ['web']}
    validate(json, formats.channel_input_format)

    json = {'name': 'short', 'max_size': 200, 'content_type': '', 'types': ['web'], 'required': True}
    validate(json, formats.channel_input_format)

    json = {'name': 'short', 'max_size': 200, 'content_type': '', 'types': ['web'], 'required': False}
    validate(json, formats.channel_input_format)


@raises(ValidationError)
def test_channel_validation_attributs_mandatory():
    json = {'name': 'short', 'max_size': 200}
    validate(json, formats.channel_input_format)


@raises(ValidationError)
def test_channel_validation_name_has_max_length():
    json = {'name': 's'*251, 'max_size': 200, 'content_type': 'text/plain'}
    validate(json, formats.channel_input_format)


@raises(ValidationError)
def test_channel_types_validation_mandatory():
    json = {'name': 'short', 'max_size': 200, 'content_type': '', 'types': []}
    validate(json, formats.channel_input_format)

@raises(ValidationError)
def test_channel_validation_attributs_mandatory():
    json = {'name': 'short', 'max_size': 200}
    validate(json, formats.channel_input_format)

@raises(ValidationError)
def test_channel_with_required_not_boolean():
    json = {'name': 'short', 'max_size': 200, 'content_type': '', 'types': ['web'], 'required': 1}
    validate(json, formats.channel_input_format)

def test_validate_object_format():
    Draft4Validator.check_schema(formats.object_input_format)


def test_object_validation():
    json = {'id': 'stop_area:...:200', 'type': 'network'}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_object_validation_without_type():
    json = {'id': 'stop_area:...:200'}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_object_validation_id_has_max_length():
    json = {'id': 's'*251, 'type': 'network'}
    validate(json, formats.object_input_format)


def test_validate_impact_format():
    Draft4Validator.check_schema(formats.impact_input_format)


def test_impact_without_application_period_validation():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},
            "objects": [{"id": "stop_area:RTP:SA:3786125","type": "network"},{"id": "line:RTP:LI:378","type": "network"}],
            "application_periods": [{"begin": "2014-04-29T16:52:00Z", "end": "2014-06-22T02:15:00Z"}]
           }
    validate(json, formats.impact_input_format)


def test_impact_without_object_validation():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods": [{"begin": "2014-06-20T17:00:00Z","end":"2014-07-28T17:00:00Z"}],"objects": [{"id": "network:JDR:1","type": "network"}]}
    validate(json, formats.impact_input_format)


def test_impact_with_object_and_application_period_validation():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},
            "application_periods": [{"begin": "2014-06-20T17:00:00Z","end":"2014-07-28T17:00:00Z"}],
            "objects": [{"id": "stop_area:RTP:SA:3786125","type": "network"},{"id": "network:RTP:LI:378","type": "network"},
                        {"id": "line:RTP:LI:378","type": "line"}]
            }
    validate(json, formats.impact_input_format)


@raises(ValidationError)
def test_impact_without_severity_validation():
    json = {"application_periods": [{"begin": "2014-06-20T17:00:00Z","end":"2014-07-28T17:00:00Z"}],
            "objects": [{"id": "stop_area:RTP:SA:3786125","type": "network"},{"id": "line:RTP:LI:378","type": "network"}]
            }
    validate(json, formats.impact_input_format)


def test_disruption_validation():
    json = {"reference": "foo", "contributor": "contrib1", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_without_cause_validation():
    json = {"reference": "foo", "contributor": "contrib1","publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_without_contributor_validation():
    json = {"reference": "foo", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_not_cause_id_validation():
    json = {"reference": "foo", "contributor": "contrib1", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230$6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


def test_disruption_without_localisation_validation():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
    validate(json, formats.disruptions_input_format)


def test_disruption_with_localisation_validation():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello","localization":[{"id": "stop_area:aaaa", "type":"stop_area"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_with_list_localisation_doublon():
    json = {"severity": {"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"},"localization":[{"id": "stop_area:aaaa", "type":"stop_area"}, {"id": "stop_area:aaaa", "type":"stop_area"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_with_list_localisation_validation():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello","localization":{"id": "aaaa", "type":"stop_area"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_with_list_localisation_stop_point():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello","localization":[{"id": "aaaa", "type":"stop_point"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_with_list_localisation_line():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello","localization":[{"id": "aaaa", "type":"line"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_disruption_with_list_localisation_network():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello","localization":[{"id": "aaaa", "type":"network"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}}
    validate(json, formats.disruptions_input_format)

@raises(ValidationError)
def test_disruption_without_publication_period():
    json = {"reference": "foo", "contributor": "contrib1", "note": "hello", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
    validate(json, formats.disruptions_input_format)


def test_impact_whith_message_validation():
    json = {"severity":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"}, "messages":[{"text":"aaaaaa","channel":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea"}}]}
    validate(json, formats.impact_input_format)


@raises(ValidationError)
def test_impact_whith_message_validation():
    json = {"severity":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"}, "messages":[{"teaaaaxt":"aaaaaa","channel":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea"}}]}
    validate(json, formats.impact_input_format)

def test_impact_whith_message_meta_validation():
    json = {"severity":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"}, "messages":[{"text":"aaaaaa","channel":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea"},"meta":[{"key":"object","value":"mail object"}]}]}
    validate(json, formats.impact_input_format)

@raises(ValidationError)
def test_impact_whith_message_meta_validation():
    json = {"severity":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca8657ea"}, "messages":[{"text":"aaaaaa","channel":{"id": "3d1f42b2-e8df-11e3-8c3e-0008ca86c7ea"},"meta":[{"keys":"object","value":"mail object"}]}]}
    validate(json, formats.impact_input_format)

def test_impact_with_stop_area_validation():
    json = {'id': 'stop_area:...:200', 'type': 'stop_area'}
    validate(json, formats.object_input_format)


def test_tag_with_name_validation():
    json = {'name': 'aaa'}
    validate(json, formats.tag_input_format)


def test_tag_with_size_name_validation():
    json = {'name': 'a'*250}
    validate(json, formats.tag_input_format)


@raises(ValidationError)
def test_tag_with_invalid_size_name_validation():
    json = {'name': 'a'*251}
    validate(json, formats.tag_input_format)


@raises(ValidationError)
def test_tag_without_name_validation():
    json = {}
    validate(json, formats.tag_input_format)


def test_impact_with_line_section_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_without_end_point_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"}, "sens":0}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_and_line_type_invalid():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"stop_area"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_and_start_point_type_invalid():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"line"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_and_end_point_type_invalid():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_point"}, "sens":0}}
    validate(json, formats.object_input_format)


def test_impact_with_line_section_with_route_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_duplicate_route_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}, {"id":"route:MTD:9", "type":"route"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_route_type_invalid():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"line"}]}}
    validate(json, formats.object_input_format)


def test_impact_with_line_section_with_route_and_metas_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "metas":[{"key":"direction", "value":"1234"}]}}
    validate(json, formats.object_input_format)


def test_impact_with_line_section_with_route_and_via_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "via":[{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_route_and_metas_key_not_exist():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "metas":[{"value":"1234"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_route_and_metas_empty_key():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "metas":[{"key": "", "value":"1234"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_route_and_metas_doublon():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "metas":[{"key": "dd", "value":"1234"},{"key": "dd", "value":"1234"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_route_and_metas_value_not_exist():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "metas":[{"key":"direction"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_route_and_duplicate_via_validation():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "via":[{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, {"id":"stop_area:JDR:CHVIN", "type":"stop_area"}]}}
    validate(json, formats.object_input_format)


@raises(ValidationError)
def test_impact_with_line_section_with_route_and_via_invalid():
    json = {'id': 'line:AME:3', 'type': 'line_section', "line_section": {"line":{"id":"line:AME:3","type":"line"}, "start_point":{"id":"stop_area:MTD:SA:154", "type":"stop_area"},	"end_point":{"id":"stop_area:JDR:CHVIN", "type":"stop_area"}, "sens":0, "routes":[{"id":"route:MTD:9", "type":"route"}], "via":[{"id":"stop_area:JDR:CHVIN", "type":"stop_point"}]}}
    validate(json, formats.object_input_format)


def test_time_slot_input_format_valid():
    json = {"begin": "07:45", "end": "09:30"}
    validate(json, formats.time_slot_input_format)


@raises(ValidationError)
def test_time_slot_input_format_invalid():
    json = {"begin": "07:45:00", "end": "09:30"}
    validate(json, formats.time_slot_input_format)


def test_pattern_input_format_valid():
    json = {"start_date":"2015-02-01","end_date":"2015-02-06","weekly_pattern":"1111100","time_zone":"Europe/Paris","time_slots":[{"begin": "07:45", "end": "09:30"}, {"begin": "17:30", "end": "20:30"}]}
    validate(json, formats.pattern_input_format)


@raises(ValidationError)
def test_pattern_input_format_without_time_slot_invalid():
    json = {"start_date":"2015-02-01T16:52:00Z","end_date":"2015-02-06T16:52:00Z","weekly_pattern":"1111100"}
    validate(json, formats.pattern_input_format)


@raises(ValidationError)
def test_pattern_input_format_without_time_slot_content_invalid():
    json = {"start_date":"2015-02-01T16:52:00Z","end_date":"2015-02-06T16:52:00Z","weekly_pattern":"1111100", "time_slots":[]}
    validate(json, formats.pattern_input_format)


@raises(ValidationError)
def test_pattern_input_format_invalid():
    json = {"start_date":"2015-02-01T16:52:00Z","end_date":"2015-02-06T16:52:00Z","weekly_pattern":"1111100111","time_zone":"Europe/Paris","time_slots":[{"begin": "07:45", "end": "09:30"}, {"begin": "17:30", "end": "20:30"}]}
    validate(json, formats.pattern_input_format)


def test_impact_with_application_period_patterns_valid():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_period_patterns":[{"start_date":"2015-02-01","end_date":"2015-02-06","weekly_pattern":"1111100","time_zone":"Europe/Paris","time_slots":[{"begin": "07:45", "end": "09:30"}, {"begin": "17:30", "end": "20:30"}]}],"objects": [{"id": "network:JDR:1", "type": "network"}]}
    validate(json, formats.impact_input_format)


def test_impact_with_application_period_patterns_invalid():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_period_patterns":[{"start_date":"2015-02-01","end_date":"2015-02-06","weekly_pattern":"1111100","time_zone":"Europe/Paris","time_slots":[{"begin": "07:45", "end": "09:30"}, {"begin": "17:30", "end": "20:30"}]}],"objects": [{"id": "network:JDR:1", "type": "network"}]}
    validate(json, formats.impact_input_format)


def test_impact_with_route():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},
            "objects": [{"id": "route:RTP:LI:378","type": "route"}],
            "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]
            }
    validate(json, formats.impact_input_format)


def test_disruption_with_note_string_vide_validation():
    json = {"reference": "foo", "contributor": "contrib1", "note": "", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
    validate(json, formats.disruptions_input_format)


def test_disruption_with_note_null_validation():
    json = {"reference": "foo", "contributor": "contrib1", "note": None, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
    validate(json, formats.disruptions_input_format)


@raises(ValidationError)
def test_pattern_input_format_without_time_zone_invalid():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_period_patterns":[{"start_date":"2015-02-01T16:52:00Z","end_date":"2015-02-06T16:52:00Z","weekly_pattern":"1111100","time_slots":[{"begin": "07:45", "end": "09:30"}, {"begin": "17:30", "end": "20:30"}]}]}
    validate(json, formats.pattern_input_format)


@raises(ValidationError)
def test_pattern_input_format_with_time_zone_invalid():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_period_patterns":[{"start_date":"2015-02-01T16:52:00Z","end_date":"2015-02-06T16:52:00Z","weekly_pattern":"1111100","time_zone":"europe/paris","time_slots":[{"begin": "07:45", "end": "09:30"}, {"begin": "17:30", "end": "20:30"}]}]}
    validate(json, formats.pattern_input_format)


@raises(ValidationError)
def test_impact_with_send_notifications_not_boolean():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},
            "send_notifications": 1}
    validate(json, formats.impact_input_format)


def test_impact_with_send_notifications_boolean():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"send_notifications": True,"objects": [{"id": "network:JDR:1", "type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
    validate(json, formats.impact_input_format)


# Property
def test_property_validation():
    json = {'key': 'test', 'type': 'test'}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_no_key():
    json = {'type': 'test'}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_no_type():
    json = {'key': 'test'}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_empty():
    json = {}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_type_is_int():
    json = {'type': 42, 'key': 'test'}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_key_is_int():
    json = {'type': 'test', 'key': 42}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_key_is_empty_string():
    json = {'type': 'test', 'key': ''}
    validate(json, formats.property_input_format)


@raises(ValidationError)
def test_property_type_is_empty_string():
    json = {'type': '', 'key': 'test'}
    validate(json, formats.property_input_format)


# AssociateDisruptionProperty
def test_associate_disruption_property_validation():
    json = {
        'property_id': '7ffab232-3d48-4eea-aa2c-22f8680230b6',
        'value': 'test'
    }
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_no_value():
    json = {'property_id': '7ffab232-3d48-4eea-aa2c-22f8680230b6'}
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_no_property_id():
    json = {'value': 'test'}
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_empty():
    json = {}
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_value_is_int():
    json = {
        'property_id': '7ffab232-3d48-4eea-aa2c-22f8680230b6',
        'value': 42
    }
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_property_id_is_int():
    json = {
        'property_id': 42,
        'value': 'test'
    }
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_value_is_empty_string():
    json = {
        'property_id': '7ffab232-3d48-4eea-aa2c-22f8680230b6',
        'value': ''
    }
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_property_id_is_empty_string():
    json = {
        'property_id': '',
        'value': 'test'
    }
    validate(json, formats.associate_disruption_property_input_format)


@raises(ValidationError)
def test_associate_disruption_property_property_id_is_not_uuid():
    json = {
        'property_id': '7ffab232-3d48-4eea-aa2c-22f8680230b',
        'value': 'test'
    }
    validate(json, formats.associate_disruption_property_input_format)


def test_impact_with_notification_date():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"notification_date": "2014-06-20T17:00:00Z","objects": [{"id": "network:JDR:1", "type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
    validate(json, formats.impact_input_format)


def test_impact_with_notification_date_and_None_value():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"notification_date": None,"objects": [{"id": "network:JDR:1", "type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
    validate(json, formats.impact_input_format)


@raises(ValidationError)
def test_impact_with_notification_date_without_value():
    json = {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"notification_date": "","objects": [{"id": "network:JDR:1", "type": "network"}]}
    validate(json, formats.impact_input_format)
