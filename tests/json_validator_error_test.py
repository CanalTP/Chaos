from nose.tools import *
from chaos.utils import parse_error
from jsonschema import validate
from jsonschema.exceptions import ValidationError
from chaos.formats import impact_input_format, channel_input_format, severity_input_format,\
    disruptions_input_format, tag_input_format, pt_object_type_values, pattern_input_format


def test_wording_is_required_in_severity():
    try:
        validate({}, severity_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'wordings' is a required property", True)


def test_wording_is_empty_in_severity():
    try:
        validate({'wordings': []}, severity_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "wordings should not be empty", True)


def test_wording_is_value_not_in__wordings_severity():
    try:
        validate({'wordings': [{'key': 'aa'}]}, severity_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'value' is a required property", True)


def test_wording_is_key_not_in__wordings_severity():
    try:
        validate({'wordings': [{'key': 'aa'}]}, severity_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'value' is a required property", True)


def test_wording_is_empty_key_in__wordings_severity():
    try:
        validate({'wordings': [{'key': '', 'value': 'aa'}]}, severity_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'' is too short", True)


def test_name_is_required_in_channel():
    try:
        validate({"max_size": 500, "content_type": "text/type"}, channel_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'name' is a required property", True)


def test_max_size_is_required_in_channel():
    try:
        validate({"name": "sms", "content_type": "text/type"}, channel_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'max_size' is a required property", True)


def test_content_type_is_required_in_channel():
    try:
        validate({"name": "sms", "max_size": 500}, channel_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'content_type' is a required property", True)


def test_channel_types_is_required_in_channel():
    try:
        validate({"name": "sms", "max_size": 500, "content_type": "text/type"}, channel_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'types' is a required property", True)


def test_channel_types_name_is_required_in_channel():
    try:
        validate({"name": "sms", "max_size": 500, "content_type": "text/type", "types": []}, channel_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "types should not be empty", True)


def test_name_required_in_channel_types():
    try:
        validate({"name": "sms", "max_size": 500, "content_type": "text/type", "types": []}, channel_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "types should not be empty", True)


def test_reference_is_required_in_disruption():
    try:
        validate({"note": "hello", "contributor": "contrib1", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'reference' is a required property", True)


def test_cause_is_required_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "note": "hello"}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'cause' is a required property", True)


def test_severity_is_required_in_impcat():
    try:
        validate({"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-05-22T02:15:00Z"},{"begin": "2014-04-29T16:52:00Z","end": "2014-05-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'severity' is a required property", True)


def test_begin_date_is_required_in_impcat():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"end": "2014-05-22T02:15:00Z"}, {"begin": None,"end": "2014-05-22T02:15:00Z"}],"objects": [{"id": "network:JDR:1", "type": "network"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'begin' is a required property", True)


def test_id_object_is_required_in_impcat():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "network:JDR:2","type": "network"}, {"type": "stop_area"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'id' is a required property", True)


def test_type_object_is_required_in_impcat():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "network:JDR:2","type": "network"}, {"id": "network:JDR:1"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'type' is a required property", True)

def test_pt_object_stop_point_in_impcat():
    validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "stop_point:JDR:2", "type": "stop_point"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)


def test_not_pt_object_in_impcat():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "route_point:JDR:2", "type": "route_point"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'route_point' is not one of {}".format(pt_object_type_values), True)


def test_text_is_required_in_message():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}],"objects": [{"id": "network:JDR:1", "type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'text' is a required property", True)


def test_channel_is_required_in_message():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 1"}],"objects": [{"id": "network:JDR:1", "type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'channel' is a required property", True)


def test_id_is_required_in_localization():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "localization":[{"type": "stop_area"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'id' is a required property", True)


def test_type_is_required_in_localization():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "localization":[{"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'type' is a required property", True)


def test_cause_is_required_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'cause' is a required property", True)


def test_reference_is_required_in_disruption():
    try:
        validate({"publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'reference' is a required property", True)


def test_impacts_is_required_in_disruption():
    try:
        validate({"reference": "foo","contributor": "contrib1","publication_period": {"begin": "2014-06-24T10:35:00Z","end": "2018-06-24T10:35:00Z"},"localization": [{"id": "stop_area:JDR:SA:CHVIN","type": "stop_area"}],"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'impacts' is a required property", True)


def test_min_1_impact_is_required_in_disruption():
    try:
        validate({"reference": "foo","contributor": "contrib1","publication_period": {"begin": "2014-06-24T10:35:00Z","end": "2018-06-24T10:35:00Z"},"localization": [{"id": "stop_area:JDR:SA:CHVIN","type": "stop_area"}],"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": []}, disruptions_input_format)
        assert True
    except ValidationError as e:
        eq_(parse_error(e), "impacts should not be empty", True)

def test_impact_format_is_checked_in_disruption():
    try:
        validate({"reference": "foo","contributor": "contrib1","publication_period": {"begin": "2014-06-24T10:35:00Z","end": "2018-06-24T10:35:00Z"},"localization": [{"id": "stop_area:JDR:SA:CHVIN","type": "stop_area"}],"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert True
    except ValidationError as e:
        eq_(parse_error(e), "'objects' is a required property", True)

def test_begin_date_is_required_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"end": None}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'begin' is a required property", True)


def test_unique_localization_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "localization":[{"id":"stop_area:JDR:SA:CHVIN", "type": "stop_area"}, {"id":"stop_area:JDR:SA:CHVIN", "type": "stop_area"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        assert_in("non-unique elements", parse_error(e))


def test_unique_application_periods_in_impact():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-05-22T02:15:00Z"},{"begin": "2014-04-29T16:52:00Z","end": "2014-05-22T02:15:00Z"}],"objects": [{"id": "network:JDR:1", "type": "network"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        assert_in("non-unique elements", parse_error(e))


def test_unique_pt_object_in_impact():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "network:JDR:2","type": "network"}, {"id": "network:JDR:2","type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        assert_in("non-unique elements", parse_error(e))


def test_unique_message_in_impact():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 1","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}, {"text": "message 1","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}],"objects": [{"id": "network:JDR:1", "type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert False
    except ValidationError as e:
        assert_in("non-unique elements", parse_error(e))


def test_obects_is_required_in_impact():
    try:
        validate({"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 1", "channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}, {"text": "message 1", "channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}, impact_input_format)
        assert True
    except ValidationError as e:
        eq_(parse_error(e), "'objects' is a required property", True)

def test_name_is_required_in_tag():
    try:
        validate({}, tag_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'name' is a required property", True)


def test_unique_tag_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "tags":[{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        assert_in("non-unique elements", parse_error(e))


def test_id_tag_is_required_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "tags":[{}, {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'id' is a required property", True)


def test_id_tag_format_is_not_valid_in_disruption():
    try:
        validate({"reference": "foo", "contributor": "contrib1", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": None}, "tags":[{"id": "7ffab230-3d48-4eea-aa2c-22f8680230"}, {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'7ffab230-3d48-4eea-aa2c-22f8680230' does not match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'", True)

def test_contributor_is_required_in_disruption():
    try:
        validate({"reference": "foo", "note": "hello", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}, disruptions_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'contributor' is a required property", True)

def test_time_slots_is_required_in_pattern():
    try:
        validate({"start_date":"2015-02-01T16:52:00Z","end_date":"2015-02-06T16:52:00Z","weekly_pattern":"1111100"}, pattern_input_format)
        assert False
    except ValidationError as e:
        eq_(parse_error(e), "'time_slots' is a required property", True)
