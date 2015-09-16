from nose.tools import *
import chaos
from chaos.populate_pb import populate_pb, get_pt_object_type, get_pos_time, get_channel_type
from aniso8601 import parse_datetime
import datetime


def get_disruption(with_via=True, with_routes=True):

    # Disruption
    disruption = chaos.models.Disruption()
    disruption.cause = chaos.models.Cause()
    disruption.cause.wording = "CauseTest"
    disruption.reference = "DisruptionTest"
    localization = chaos.models.PTobject()
    localization.uri = "stop_area:123"
    localization.type = "stop_area"
    disruption.localizations.append(localization)

    # Wording
    wording = chaos.models.Wording()
    wording.key = "key_1"
    wording.value = "value_1"
    disruption.cause.wordings.append(wording)
    wording = chaos.models.Wording()
    wording.key = "key_2"
    wording.value = "value_2"
    disruption.cause.wordings.append(wording)

    # Tag
    tag = chaos.models.Tag()
    tag.name = "rer"
    disruption.tags.append(tag)
    tag = chaos.models.Tag()
    tag.name = "metro"
    disruption.tags.append(tag)

    # Impacts
    impact = chaos.models.Impact()
    impact.severity = chaos.models.Severity()
    impact.severity.wording = "SeverityTest"
    impact.severity.color = "#FFFF00"
    impact.severity.effect = "no_service"
    impact.status = "published"

    # ApplicationPeriods
    application_period = chaos.models.ApplicationPeriods()
    application_period.start_date = parse_datetime("2014-04-12T16:52:00").replace(tzinfo=None)
    application_period.end_date = parse_datetime("2015-04-12T16:52:00").replace(tzinfo=None)
    impact.application_periods.append(application_period)

    # PTobject
    ptobject = chaos.models.PTobject()
    ptobject.uri = "stop_area:123"
    ptobject.type = "stop_area"
    impact.objects.append(ptobject)

    ptobject = chaos.models.PTobject()
    ptobject.uri = "line:123"
    ptobject.type = "line"
    impact.objects.append(ptobject)

    #LineSection
    ptobject = chaos.models.PTobject()
    ptobject.uri = "line_section:123"
    ptobject.type = "line_section"
    ptobject.line_section = chaos.models.LineSection()
    ptobject.line_section.sens = 1
    ptobject.line_section.line = chaos.models.PTobject()
    ptobject.line_section.line.uri = 'line:1'
    ptobject.line_section.line.type = 'line'

    ptobject.line_section.start_point = chaos.models.PTobject()
    ptobject.line_section.start_point.uri = 'stop_area:1'
    ptobject.line_section.start_point.type = 'stop_area'

    ptobject.line_section.end_point = chaos.models.PTobject()
    ptobject.line_section.end_point.uri = 'stop_area:2'
    ptobject.line_section.end_point.type = 'stop_area'

    if with_routes:
        route = chaos.models.PTobject()
        route.uri = 'route:1'
        route.type = 'route'
        ptobject.line_section.routes.append(route)

        route = chaos.models.PTobject()
        route.uri = 'route:2'
        route.type = 'route'
        ptobject.line_section.routes.append(route)

    if with_via:
        via = chaos.models.PTobject()
        via.uri = 'stop_area:11'
        via.type = 'stop_area'
        ptobject.line_section.via.append(via)

        via = chaos.models.PTobject()
        via.uri = 'stop_area:22'
        via.type = 'stop_area'
        ptobject.line_section.via.append(via)

    impact.objects.append(ptobject)

    ptobject = chaos.models.PTobject()
    ptobject.uri = "route:123"
    ptobject.type = "route"
    impact.objects.append(ptobject)

    ptobject = chaos.models.PTobject()
    ptobject.uri = "stop_point:AA"
    ptobject.type = "stop_point"
    impact.objects.append(ptobject)

    # Messages
    message = chaos.models.Message()
    message.text = "Meassage1 test"
    message.channel = chaos.models.Channel()
    message.channel.name = "sms"
    message.channel.max_size = 60
    message.channel.content_type = "text"
    channel_type = chaos.models.ChannelType()
    channel_type.name = 'web'
    message.channel.channel_types.append(channel_type)
    channel_type = chaos.models.ChannelType()
    channel_type.name = 'sms'
    message.channel.channel_types.append(channel_type)
    impact.messages.append(message)

    message = chaos.models.Message()
    message.text = "Meassage2 test"
    message.channel = chaos.models.Channel()
    message.channel.name = "email"
    message.channel.max_size = 250
    message.channel.content_type = "html"
    channel_type = chaos.models.ChannelType()
    channel_type.name = 'web'
    message.channel.channel_types.append(channel_type)
    channel_type = chaos.models.ChannelType()
    channel_type.name = 'email'
    message.channel.channel_types.append(channel_type)

    impact.messages.append(message)

    disruption.impacts.append(impact)

    # Impacts with send_notifications
    impact = chaos.models.Impact()
    impact.severity = chaos.models.Severity()
    impact.severity.wording = "SeverityTest"
    impact.severity.color = "#FFFF00"
    impact.severity.effect = "no_service"
    impact.status = "published"
    impact.send_notifications = True

    # ApplicationPeriods
    application_period = chaos.models.ApplicationPeriods()
    application_period.start_date = parse_datetime("2014-04-12T16:52:00").replace(tzinfo=None)
    application_period.end_date = parse_datetime("2015-04-12T16:52:00").replace(tzinfo=None)
    impact.application_periods.append(application_period)

    # PTobject
    ptobject = chaos.models.PTobject()
    ptobject.uri = "stop_area:125"
    ptobject.type = "stop_area"
    impact.objects.append(ptobject)

    disruption.impacts.append(impact)

    # Impacts with send_notifications false
    impact = chaos.models.Impact()
    impact.severity = chaos.models.Severity()
    impact.severity.wording = "SeverityTest"
    impact.severity.color = "#FFFF00"
    impact.severity.effect = "no_service"
    impact.status = "published"
    impact.send_notifications = False

    # ApplicationPeriods
    application_period = chaos.models.ApplicationPeriods()
    application_period.start_date = parse_datetime("2014-04-12T16:52:00").replace(tzinfo=None)
    application_period.end_date = parse_datetime("2015-04-12T16:52:00").replace(tzinfo=None)
    impact.application_periods.append(application_period)

    # PTobject
    ptobject = chaos.models.PTobject()
    ptobject.uri = "stop_area:124"
    ptobject.type = "stop_area"
    impact.objects.append(ptobject)

    disruption.impacts.append(impact)

    return disruption

def test_get_pos_time():
    dates = [
                datetime.datetime(2014, 1, 14, 9, 0),
                datetime.datetime(2014, 8, 14, 12, 0),
                datetime.datetime(2014, 3, 29, 2, 0)
            ]
    for d in dates:
        eq_(d, datetime.datetime.utcfromtimestamp(get_pos_time(d)))


def test_disruption():
    disruption = get_disruption()
    feed_entity = populate_pb(disruption).entity[0]
    eq_(feed_entity.is_deleted, False)
    disruption_pb = feed_entity.Extensions[chaos.chaos_pb2.disruption]

    eq_(disruption_pb.reference,  disruption.reference)
    eq_(disruption_pb.cause.wording,  disruption.cause.wording)
    eq_(len(disruption_pb.cause.wordings), 2)
    eq_(len(disruption_pb.localization),  1)
    eq_(disruption_pb.localization[0].uri,  disruption.localizations[0].uri)
    eq_(len(disruption_pb.tags),  2)
    eq_(disruption_pb.tags[0].name,  disruption.tags[0].name)
    eq_(disruption_pb.tags[1].name,  disruption.tags[1].name)


    eq_(len(disruption_pb.impacts),  3)
    eq_(disruption_pb.impacts[0].severity.wording,  "SeverityTest")
    eq_(disruption_pb.impacts[0].severity.color,  "#FFFF00")
    eq_(disruption_pb.impacts[0].severity.effect, chaos.gtfs_realtime_pb2.Alert.NO_SERVICE)

    eq_(len(disruption_pb.impacts[0].application_periods),  1)
    eq_(len(disruption_pb.impacts[0].informed_entities), 5)

    eq_(disruption_pb.impacts[0].informed_entities[0].uri, disruption.impacts[0].objects[0].uri)
    eq_(disruption_pb.impacts[0].informed_entities[0].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[0].type))

    eq_(disruption_pb.impacts[0].informed_entities[1].uri, disruption.impacts[0].objects[1].uri)
    eq_(disruption_pb.impacts[0].informed_entities[1].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[1].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].uri, disruption.impacts[0].objects[2].uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].type))

    eq_(disruption_pb.impacts[0].informed_entities[3].uri, disruption.impacts[0].objects[3].uri)
    eq_(disruption_pb.impacts[0].informed_entities[3].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[3].type))

    eq_(disruption_pb.impacts[0].informed_entities[4].uri, disruption.impacts[0].objects[4].uri)
    eq_(disruption_pb.impacts[0].informed_entities[4].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[4].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.uri,
    disruption.impacts[0].objects[2].line_section.line.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.line.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.uri,
    disruption.impacts[0].objects[2].line_section.start_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.start_point.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.uri,
    disruption.impacts[0].objects[2].line_section.end_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.end_point.type))

    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.routes), 2)
    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.via), 2)

    eq_(disruption_pb.impacts[0].messages[0].text, disruption.impacts[0].messages[0].text)
    eq_(disruption_pb.impacts[0].messages[0].channel.name, disruption.impacts[0].messages[0].channel.name)
    eq_(disruption_pb.impacts[0].messages[0].channel.max_size, disruption.impacts[0].messages[0].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[0].channel.content_type,
    disruption.impacts[0].messages[0].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[0].channel.types[0], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[0].channel.types[1], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[1].name))

    eq_(disruption_pb.impacts[0].messages[1].text, disruption.impacts[0].messages[1].text)
    eq_(disruption_pb.impacts[0].messages[1].channel.name, disruption.impacts[0].messages[1].channel.name)
    eq_(disruption_pb.impacts[0].messages[1].channel.max_size, disruption.impacts[0].messages[1].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[1].channel.content_type,
    disruption.impacts[0].messages[1].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[1].channel.types[0], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[1].channel.types[1], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[1].name))

    eq_(disruption_pb.impacts[0].HasField('send_notifications'), False)
    eq_(disruption_pb.impacts[1].HasField('send_notifications'), True)
    eq_(disruption_pb.impacts[1].send_notifications, True)
    eq_(disruption_pb.impacts[2].HasField('send_notifications'), False)



def test_disruption_without_via():
    disruption = get_disruption(False)
    feed_entity = populate_pb(disruption).entity[0]
    eq_(feed_entity.is_deleted, False)
    disruption_pb = feed_entity.Extensions[chaos.chaos_pb2.disruption]

    eq_(disruption_pb.reference, disruption.reference)
    eq_(disruption_pb.cause.wording, disruption.cause.wording)
    eq_(len(disruption_pb.localization), 1)
    eq_(disruption_pb.localization[0].uri,  disruption.localizations[0].uri)
    eq_(len(disruption_pb.tags), 2)
    eq_(disruption_pb.tags[0].name, disruption.tags[0].name)
    eq_(disruption_pb.tags[1].name, disruption.tags[1].name)


    eq_(len(disruption_pb.impacts), 3)
    eq_(disruption_pb.impacts[0].severity.wording, "SeverityTest")
    eq_(disruption_pb.impacts[0].severity.color, "#FFFF00")

    eq_(len(disruption_pb.impacts[0].application_periods), 1)
    eq_(len(disruption_pb.impacts[0].informed_entities), 5)

    eq_(disruption_pb.impacts[0].informed_entities[0].uri, disruption.impacts[0].objects[0].uri)
    eq_(disruption_pb.impacts[0].informed_entities[0].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[0].type))

    eq_(disruption_pb.impacts[0].informed_entities[1].uri, disruption.impacts[0].objects[1].uri)
    eq_(disruption_pb.impacts[0].informed_entities[1].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[1].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].uri, disruption.impacts[0].objects[2].uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].type))


    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.uri,
    disruption.impacts[0].objects[2].line_section.line.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.line.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.uri,
    disruption.impacts[0].objects[2].line_section.start_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.start_point.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.uri,
    disruption.impacts[0].objects[2].line_section.end_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.end_point.type))

    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.routes), 2)
    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.via), 0)

    eq_(disruption_pb.impacts[0].informed_entities[3].uri, disruption.impacts[0].objects[3].uri)
    eq_(disruption_pb.impacts[0].informed_entities[3].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[3].type))

    eq_(disruption_pb.impacts[0].messages[0].text, disruption.impacts[0].messages[0].text)
    eq_(disruption_pb.impacts[0].messages[0].channel.name, disruption.impacts[0].messages[0].channel.name)
    eq_(disruption_pb.impacts[0].messages[0].channel.max_size, disruption.impacts[0].messages[0].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[0].channel.content_type,
    disruption.impacts[0].messages[0].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[0].channel.types[0], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[0].channel.types[1], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[1].name))


    eq_(disruption_pb.impacts[0].messages[1].text, disruption.impacts[0].messages[1].text)
    eq_(disruption_pb.impacts[0].messages[1].channel.name, disruption.impacts[0].messages[1].channel.name)
    eq_(disruption_pb.impacts[0].messages[1].channel.max_size, disruption.impacts[0].messages[1].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[1].channel.content_type,
    disruption.impacts[0].messages[1].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[1].channel.types[0], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[1].channel.types[1], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[1].name))

    eq_(disruption_pb.impacts[0].HasField('send_notifications'), False)
    eq_(disruption_pb.impacts[1].HasField('send_notifications'), True)
    eq_(disruption_pb.impacts[1].send_notifications, True)
    eq_(disruption_pb.impacts[2].HasField('send_notifications'), False)

def test_disruption_without_routes():
    disruption = get_disruption(True, False)
    feed_entity = populate_pb(disruption).entity[0]
    eq_(feed_entity.is_deleted, False)
    disruption_pb = feed_entity.Extensions[chaos.chaos_pb2.disruption]

    eq_(disruption_pb.reference, disruption.reference)
    eq_(disruption_pb.cause.wording, disruption.cause.wording)
    eq_(len(disruption_pb.localization), 1)
    eq_(disruption_pb.localization[0].uri,  disruption.localizations[0].uri)
    eq_(len(disruption_pb.tags), 2)
    eq_(disruption_pb.tags[0].name, disruption.tags[0].name)
    eq_(disruption_pb.tags[1].name, disruption.tags[1].name)


    eq_(len(disruption_pb.impacts), 1)
    eq_(disruption_pb.impacts[0].severity.wording, "SeverityTest")
    eq_(disruption_pb.impacts[0].severity.color, "#FFFF00")

    eq_(len(disruption_pb.impacts[0].application_periods), 1)
    eq_(len(disruption_pb.impacts[0].informed_entities), 3)

    eq_(disruption_pb.impacts[0].informed_entities[0].uri, disruption.impacts[0].objects[0].uri)
    eq_(disruption_pb.impacts[0].informed_entities[0].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[0].type))

    eq_(disruption_pb.impacts[0].informed_entities[1].uri, disruption.impacts[0].objects[1].uri)
    eq_(disruption_pb.impacts[0].informed_entities[1].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[1].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].uri, disruption.impacts[0].objects[2].uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.uri,
    disruption.impacts[0].objects[2].line_section.line.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.line.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.uri,
    disruption.impacts[0].objects[2].line_section.start_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.start_point.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.uri,
    disruption.impacts[0].objects[2].line_section.end_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.end_point.type))

    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.routes), 0)
    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.via), 2)

    eq_(disruption_pb.impacts[0].messages[0].text, disruption.impacts[0].messages[0].text)
    eq_(disruption_pb.impacts[0].messages[0].channel.name, disruption.impacts[0].messages[0].channel.name)
    eq_(disruption_pb.impacts[0].messages[0].channel.max_size, disruption.impacts[0].messages[0].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[0].channel.content_type,
    disruption.impacts[0].messages[0].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[0].channel.types[0], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[0].channel.types[1], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[1].name))


    eq_(disruption_pb.impacts[0].messages[1].text, disruption.impacts[0].messages[1].text)
    eq_(disruption_pb.impacts[0].messages[1].channel.name, disruption.impacts[0].messages[1].channel.name)
    eq_(disruption_pb.impacts[0].messages[1].channel.max_size, disruption.impacts[0].messages[1].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[1].channel.content_type,
    disruption.impacts[0].messages[1].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[1].channel.types[0], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[1].channel.types[1], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[1].name))

    eq_(disruption_pb.impacts[0].HasField('send_notifications'), False)
    eq_(disruption_pb.impacts[1].HasField('send_notifications'), True)
    eq_(disruption_pb.impacts[1].send_notifications, True)
    eq_(disruption_pb.impacts[2].HasField('send_notifications'), False)

def test_disruption_without_routes():
    disruption = get_disruption(False, False)
    feed_entity = populate_pb(disruption).entity[0]
    eq_(feed_entity.is_deleted, False)
    disruption_pb = feed_entity.Extensions[chaos.chaos_pb2.disruption]

    eq_(disruption_pb.reference, disruption.reference)
    eq_(disruption_pb.cause.wording, disruption.cause.wording)
    eq_(len(disruption_pb.localization), 1)
    eq_(disruption_pb.localization[0].uri,  disruption.localizations[0].uri)
    eq_(len(disruption_pb.tags), 2)
    eq_(disruption_pb.tags[0].name, disruption.tags[0].name)
    eq_(disruption_pb.tags[1].name, disruption.tags[1].name)


    eq_(len(disruption_pb.impacts), 3)
    eq_(disruption_pb.impacts[0].severity.wording, "SeverityTest")
    eq_(disruption_pb.impacts[0].severity.color, "#FFFF00")

    eq_(len(disruption_pb.impacts[0].application_periods), 1)
    eq_(len(disruption_pb.impacts[0].informed_entities), 5)
    eq_(disruption_pb.impacts[0].informed_entities[0].uri, disruption.impacts[0].objects[0].uri)
    eq_(disruption_pb.impacts[0].informed_entities[0].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[0].type))
    eq_(disruption_pb.impacts[0].informed_entities[1].uri, disruption.impacts[0].objects[1].uri)
    eq_(disruption_pb.impacts[0].informed_entities[1].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[1].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].uri, disruption.impacts[0].objects[2].uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.uri,
    disruption.impacts[0].objects[2].line_section.line.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.line.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.line.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.uri,
    disruption.impacts[0].objects[2].line_section.start_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.start_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.start_point.type))

    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.uri,
    disruption.impacts[0].objects[2].line_section.end_point.uri)
    eq_(disruption_pb.impacts[0].informed_entities[2].pt_line_section.end_point.pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[2].line_section.end_point.type))

    eq_(disruption_pb.impacts[0].informed_entities[3].uri, disruption.impacts[0].objects[3].uri)
    eq_(disruption_pb.impacts[0].informed_entities[3].pt_object_type,
    get_pt_object_type(disruption.impacts[0].objects[3].type))

    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.routes), 0)
    eq_(len(disruption_pb.impacts[0].informed_entities[2].pt_line_section.via), 0)
    eq_(disruption_pb.impacts[0].messages[0].text, disruption.impacts[0].messages[0].text)
    eq_(disruption_pb.impacts[0].messages[0].channel.name, disruption.impacts[0].messages[0].channel.name)
    eq_(disruption_pb.impacts[0].messages[0].channel.max_size, disruption.impacts[0].messages[0].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[0].channel.content_type,
    disruption.impacts[0].messages[0].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[0].channel.types[0], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[0].channel.types[1], get_channel_type(disruption.impacts[0].messages[0].channel.channel_types[1].name))

    eq_(disruption_pb.impacts[0].messages[1].text, disruption.impacts[0].messages[1].text)
    eq_(disruption_pb.impacts[0].messages[1].channel.name, disruption.impacts[0].messages[1].channel.name)
    eq_(disruption_pb.impacts[0].messages[1].channel.max_size, disruption.impacts[0].messages[1].channel.max_size)
    eq_(disruption_pb.impacts[0].messages[1].channel.content_type,
    disruption.impacts[0].messages[1].channel.content_type)
    eq_(disruption_pb.impacts[0].messages[1].channel.types[0], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[0].name))
    eq_(disruption_pb.impacts[0].messages[1].channel.types[1], get_channel_type(disruption.impacts[0].messages[1].channel.channel_types[1].name))

    eq_(disruption_pb.impacts[0].HasField('send_notifications'), False)
    eq_(disruption_pb.impacts[1].HasField('send_notifications'), True)
    eq_(disruption_pb.impacts[1].send_notifications, True)
    eq_(disruption_pb.impacts[2].HasField('send_notifications'), False)

def test_disruption_is_deleted():
    disruption = get_disruption()
    disruption.status = 'archived'
    feed_entity = populate_pb(disruption).entity[0]

    eq_(feed_entity.is_deleted, True)

@raises(AttributeError)
def test_disruption_with_impact_without_severity():
    disruption = get_disruption()
    del disruption.impacts[0].severity
    feed_entity = populate_pb(disruption)


@raises(AttributeError)
def test_disruption_without_cause():
    disruption = get_disruption()
    del disruption.cause
    feed_entity = populate_pb(disruption)

