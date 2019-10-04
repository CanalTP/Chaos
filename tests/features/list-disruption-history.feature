Feature: disruption history
    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: List of an updated disruption
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | cause1    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | cause2    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7bfab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date | cause_id                               | client_id                            | contributor_id                         |version|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2018-09-11T13:50:00    | 2018-12-31T16:50:00  | 7ffab230-3d48-4eea-aa2c-22f8680230b6   | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6   |1      |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   | client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 5ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 |
        Given I have the following properties in my database:
            | created_at          | id                                   | client_id                            | key    | type   |
            | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
            | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following ptobject in my database:
            | type     | uri                    | created_at          | updated_at          | id                                         |
            | stop_area| stop_area:JDR:SA:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area| stop_area:JDR:SA:BASTI | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
        Given I have the following associate_disruption_properties in my database:
            | value | disruption_id                        | property_id                          |
            | val1  | a750994c-01fe-11e4-b4fb-080027079ff3 | e408adec-0243-11e6-954b-0050568c8382 |
        Given I have the following history_disruption in my database:
            | id | disruption_id  | data        | created_at          |
            | 8ffab555-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 | {"status": "published", "created_at": "2014-04-02T23:52:12Z", "impacts": [{"created_at": "2019-05-27T09:44:50Z", "updated_at": null, "disruption": {}, "objects": [{"type": "network", "id": "network:JDR:1", "name": "RATP"}], "id": "121fd37d-8064-11e9-9e35-34e6d748c530", "severity": {"color": "#654321", "created_at": "2014-04-04T23:52:12Z", "effect": "unknown_effect", "updated_at": "2014-04-06T22:52:12Z", "priority": null, "wordings": [], "id": "7ffab232-3d48-4eea-aa2c-22f8680230b6", "wording": "good news"}, "messages": [], "send_notifications": false, "notification_date": null, "application_period_patterns": [], "application_periods": [{"begin": "2014-04-29T16:52:00Z", "end": "2014-06-22T02:15:00Z"}]}], "reference": "foo", "publication_status": "past", "publication_period": {"begin": "2018-09-11T13:50:00Z", "end": "2018-12-31T16:50:00Z"}, "localization": [], "updated_at": "2019-05-27T09:44:50Z", "properties": {"property_type_1": [{"property": {"updated_at": null, "id": "e408adec-0243-11e6-954b-0050568c8382", "key": "key", "type": "type", "created_at": "2019-05-28T13:46:57Z"}, "value": "val1"}]}, "note": "hello", "version": 1, "contributor": "contrib1", "cause": {"category": null, "updated_at": "2014-04-02T23:55:12Z", "id": "7ffab230-3d48-4eea-aa2c-22f8680230b6", "wordings": [], "created_at": "2014-04-02T23:52:12Z"}, "id": "a750994c-01fe-11e4-b4fb-080027079ff3", "tags":[{"updated_at":"2014-04-02T23:55:12Z","created_at":"2014-04-02T23:52:12Z","id":"5ffab230-3d48-4eea-aa2c-22f8680230b6","name":"weather"}]} | 2014-04-02T23:52:12 |
        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foo2", "contributor": "contrib1", "properties":[], "cause":{"id":"7bfab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "2"
        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        And the field "disruptions.1.reference" should be "foo"
        And the field "disruptions.1.note" should be "hello"
        And the field "disruptions.1.cause.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.1.publication_period.begin" should be "2018-09-11T13:50:00Z"
        And the field "disruptions.1.publication_period.end" should be "2018-12-31T16:50:00Z"
        And the field "disruptions.1.localization" should have a size of 0
        And the field "disruptions.1.properties" should have a size of 1
        And the field "disruptions.1.properties.type.0.property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "disruptions.1.properties.type.0.value" should be "val1"
        And the field "disruptions.1.tags" should have a size of 1
        And the field "disruptions.1.tags.0.name" should be "weather"
        And the field "disruptions.1.version" should be 1

        And the field "disruptions.0.reference" should be "foo2"
        And the field "disruptions.0.note" should be null
        And the field "disruptions.0.cause.id" should be "7bfab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.publication_period.begin" should be "2018-09-11T13:50:00Z"
        And the field "disruptions.0.publication_period.end" should be "2018-12-31T16:50:00Z"
        And the field "disruptions.0.properties" should have a size of 0
        And the field "disruptions.0.localization" should have a size of 0
        And the field "disruptions.0.tags" should have a size of 0
        And the field "disruptions.0.version" should be 2

    Scenario: Disruption with ptobject line_section
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date | cause_id                            | client_id                            | contributor_id                       | version |
            | foo       | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 2018-09-11T13:50:00    | 2018-12-31T16:50:00  | 7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 1       |
        When I put to "/disruptions/5ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contrib1", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"}, "impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"},{"begin": "2014-04-29T16:52:00Z","end": "2014-05-22T02:15:00Z"}], "objects": [{"id":"line:JDR:M5", "type":"line_section","line_section": {"line":{"id":"line:JDR:M5","type":"line"}, "start_point":{"id":"stop_area:JDR:SA:BASTI", "type":"stop_area"}, "end_point":{"id":"stop_area:JDR:SA:CHVIN", "type":"stop_area"}, "sens":2, "routes":[{"type":"route", "id":"route:JDR:M14"}, {"type":"route", "id":"route:JDR:M1"}], "metas":[{"key":"direction", "value":"1234"}] }}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        When I get "/disruptions/5ffab230-3d48-4eea-aa2c-22f8680230b6/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.reference" should be "foo"
        And the field "disruptions.0.note" should be null
        And the field "disruptions.0.cause.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.publication_period.begin" should be "2018-09-11T13:50:00Z"
        And the field "disruptions.0.publication_period.end" should be "2018-12-31T16:50:00Z"
        And the field "disruptions.0.properties" should have a size of 0
        And the field "disruptions.0.localization" should have a size of 0

    Scenario: Test disruptions impacts in history
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following history_disruption in my database:
            | id                                    |disruption_id                         | created_at          |  data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
            | 8ffab555-3d48-4eea-aa2c-22f8680230b6  | a750994c-01fe-11e4-b4fb-080027079ff3 | 2019-05-30T23:52:12 | {"status":"published","created_at":"2014-04-02T23:52:12Z","impacts":[{"created_at":"2019-05-27T09:44:50Z","updated_at":null,"disruption":{},"objects":[{"type":"network","id":"network:JDR:1","name":"RATP"}],"id":"121fd37d-8064-11e9-9e35-34e6d748c530","severity":{"color":"#654321","created_at":"2014-04-04T23:52:12Z","effect":"unknown_effect","updated_at":"2014-04-06T22:52:12Z","priority":null,"wordings":[],"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6","wording":"good news"},"messages":[{"text":"test contenu email","created_at":"2019-05-29T09:55:08Z","meta":[{"key":"subject","value":"test object"}],"updated_at":null,"channel":{"name":"email","created_at":"2019-04-04T14:58:33Z","required":false,"updated_at":null,"max_size":255,"content_type":"text/plain","id":"1decb83e-56ea-11e9-9d43-185e0fa9992b","types":["email"]}},{"text":"test contenu titre","created_at":"2019-05-29T09:55:08Z","meta":[],"updated_at":null,"channel":{"name":"Titre (OV1)","created_at":"2016-05-31T09:13:40Z","required":false,"updated_at":"2016-08-10T09:19:49Z","max_size":50,"content_type":"text/plain","id":"f7335c8c-270f-11e6-8ada-005056a47b86","types":["title"]}}],"send_notifications":false,"notification_date":null,"application_period_patterns":[{"weekly_pattern":"1111100","start_date":"2019-05-30","end_date":"2019-12-31","time_slots":[{"begin":"00:00","end":"14:00"},{"begin":"03:59","end":"10:01"}]}],"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"}]}],"reference":"foo","publication_status":"past","publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"localization":[],"updated_at":"2019-05-27T09:44:50Z","properties":{"property_type_1":[{"property":{"updated_at":null,"id":"e408adec-0243-11e6-954b-0050568c8382","key":"key","type":"type","created_at":"2019-05-28T13:46:57Z"},"value":"val1"}]},"note":"hello","version":1,"contributor":"contrib1","cause":{"category":null,"updated_at":"2014-04-02T23:55:12Z","id":"7ffab230-3d48-4eea-aa2c-22f8680230b6","wordings":[],"created_at":"2014-04-02T23:52:12Z"},"id":"a750994c-01fe-11e4-b4fb-080027079ff3","tags":[{"updated_at":"2014-04-02T23:55:12Z","created_at":"2014-04-02T23:52:12Z","id":"5ffab230-3d48-4eea-aa2c-22f8680230b6","name":"weather"}]} |
        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts" should have a size of 2
        And the field "disruptions.0.impacts.pagination" should have a size of 8
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.created_at" should be "2019-05-27T09:44:50Z"
        And the field "disruptions.0.impacts.impacts.0.updated_at" should be null
        And the field "disruptions.0.impacts.impacts.0.id" should be "121fd37d-8064-11e9-9e35-34e6d748c530"
        And the field "disruptions.0.impacts.impacts.0.notification_date" should be null
        And the field "disruptions.0.impacts.impacts.0.send_notifications" should be "False"

        And the field "disruptions.0.impacts.impacts.0.disruption" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.disruption.href" should contain "a750994c-01fe-11e4-b4fb-080027079ff3"

        And the field "disruptions.0.impacts.impacts.0.severity" should have a size of 9
        And the field "disruptions.0.impacts.impacts.0.severity.color" should be "#654321"
        And the field "disruptions.0.impacts.impacts.0.severity.created_at" should be "2014-04-04T23:52:12Z"
        And the field "disruptions.0.impacts.impacts.0.severity.effect" should be "unknown_effect"
        And the field "disruptions.0.impacts.impacts.0.severity.updated_at" should be "2014-04-06T22:52:12Z"
        And the field "disruptions.0.impacts.impacts.0.severity.wording" should be "good news"
        And the field "disruptions.0.impacts.impacts.0.severity.id" should be "7ffab232-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.impacts.impacts.0.severity.self.href" should contain "7ffab232-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.impacts.impacts.0.severity.wordings" should have a size of 0
        And the field "disruptions.0.impacts.impacts.0.severity.priority" should be null

        And the field "disruptions.0.impacts.impacts.0.application_period_patterns" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.weekly_pattern" should contain "1111100"
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.start_date" should be "2019-05-30"
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.end_date" should be "2019-12-31"
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.time_slots" should have a size of 2
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.time_slots.0.begin" should be "00:00"
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.time_slots.0.end" should be "14:00"
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.time_slots.1.begin" should be "03:59"
        And the field "disruptions.0.impacts.impacts.0.application_period_patterns.0.time_slots.1.end" should be "10:01"

        And the field "disruptions.0.impacts.impacts.0.application_periods" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.application_periods.0.begin" should be "2014-04-29T16:52:00Z"
        And the field "disruptions.0.impacts.impacts.0.application_periods.0.end" should be "2014-06-22T02:15:00Z"

        And the field "disruptions.0.impacts.impacts.0.messages" should have a size of 2
        And the field "disruptions.0.impacts.impacts.0.messages.0" should have a size of 5
        And the field "disruptions.0.impacts.impacts.0.messages.0.text" should be "test contenu email"
        And the field "disruptions.0.impacts.impacts.0.messages.0.created_at" should be "2019-05-29T09:55:08Z"
        And the field "disruptions.0.impacts.impacts.0.messages.0.updated_at" should be null
        And the field "disruptions.0.impacts.impacts.0.messages.0.meta" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.messages.0.meta.0.key" should be "subject"
        And the field "disruptions.0.impacts.impacts.0.messages.0.meta.0.value" should be "test object"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel" should have a size of 9
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.name" should be "email"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.created_at" should be "2019-04-04T14:58:33Z"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.required" should be "False"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.updated_at" should be null
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.max_size" should be "255"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.self.href" should contain "1decb83e-56ea-11e9-9d43-185e0fa9992b"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.id" should be "1decb83e-56ea-11e9-9d43-185e0fa9992b"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.content_type" should be "text/plain"
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.types" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.messages.0.channel.types.0" should be "email"

        And the field "disruptions.0.impacts.impacts.0.objects" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects.0" should have a size of 3
        And the field "disruptions.0.impacts.impacts.0.objects.0.type" should be "network"
        And the field "disruptions.0.impacts.impacts.0.objects.0.id" should be "network:JDR:1"
        And the field "disruptions.0.impacts.impacts.0.objects.0.name" should be "RATP"

    Scenario: Test disruptions history when impact is on line section
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following history_disruption in my database:
            | id                                    |disruption_id                         | created_at          |  data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
            | 8ffab555-3d48-4eea-aa2c-22f8680230b6  | a750994c-01fe-11e4-b4fb-080027079ff3 | 2019-05-30T23:52:12 | {"status":"published","created_at":"2019-05-31T09:21:25Z","impacts":[{"created_at":"2019-05-31T09:21:25Z","updated_at":null,"disruption":{},"objects":[{"line_section":{"end_point":{"type":"stop_area","id":"stop_area:DUA:SA:8768603","name":"PARIS GARE DE LYON"},"line":{"type":"line","id":"line:DUA:800804081","name":"Creil - Corbeil Essonnes / Melun / Malesherbes"},"start_point":{"type":"stop_area","id":"stop_area:DUA:SA:8775860","name":"CHATELET LES HALLES"}},"type":"line_section","id":"line:DUA:800804081:76acb7f6-8385-11e9-ac12-185e0fa9992b"},{"line_section":{"end_point":{"type":"stop_area","id":"stop_area:DUA:SA:8775860","name":"CHATELET LES HALLES"},"line":{"type":"line","id":"line:DUA:800804081","name":"Creil - Corbeil Essonnes / Melun / Malesherbes"},"start_point":{"type":"stop_area","id":"stop_area:DUA:SA:8768603","name":"PARIS GARE DE LYON"}},"type":"line_section","id":"line:DUA:800804081:76acb7f8-8385-11e9-ac12-185e0fa9992b"},{"line_section":{"end_point":{"type":"stop_area","id":"stop_area:DUA:SA:8768603","name":"PARIS GARE DE LYON"},"line":{"type":"line","id":"line:DUA:810801041","name":"Cergy Le Haut / Poissy / St-Germain-en-Laye - Marne-la-Vallée Chessy Disneyland / Boissy-St-Léger"},"start_point":{"type":"stop_area","id":"stop_area:DUA:SA:8775860","name":"CHATELET LES HALLES"}},"type":"line_section","id":"line:DUA:810801041:76acb7fa-8385-11e9-ac12-185e0fa9992b"},{"line_section":{"end_point":{"type":"stop_area","id":"stop_area:DUA:SA:8775860","name":"CHATELET LES HALLES"},"line":{"type":"line","id":"line:DUA:810801041","name":"Cergy Le Haut / Poissy / St-Germain-en-Laye - Marne-la-Vallée Chessy Disneyland / Boissy-St-Léger"},"start_point":{"type":"stop_area","id":"stop_area:DUA:SA:8768603","name":"PARIS GARE DE LYON"}},"type":"line_section","id":"line:DUA:810801041:76acb7fc-8385-11e9-ac12-185e0fa9992b"}],"id":"76acb7f5-8385-11e9-ac12-185e0fa9992b","severity":{"color":"#FF4455","created_at":"2016-05-31T09:13:36Z","effect":"significant_delays","updated_at":null,"priority":2,"wordings":[{"value":"ralenti","key":"short"},{"value":"20 à 30 minutes supplémentaires de trajet","key":"long"},{"value":"20 à 30 min de trajet en plus","key":"medium"}],"id":"f4b1eba4-270f-11e6-83cb-005056a47b86","wording":"20 à 30 minutes supplémentaires de trajet"},"messages":[],"send_notifications":true,"notification_date":"2019-05-31T09:21:25Z","application_period_patterns":[],"application_periods":[{"begin":"2019-05-31T09:20:00Z","end":"2019-05-31T11:20:00Z"}]}],"reference":"realtime_root-20190531112012","publication_status":"ongoing","publication_period":{"begin":"2019-05-31T09:20:00Z","end":"2019-05-31T11:20:00Z"},"localization":[],"updated_at":null,"properties":{},"note":null,"version":1,"contributor":"shortterm.tr_transilien","cause":{"category":{"updated_at":"2016-05-31T09:13:36Z","created_at":"2015-02-05T14:22:56Z","id":"7a8160fa-ad42-11e4-adc9-005056a47b86","name":"Trafic inopiné"},"updated_at":null,"id":"f4fb6568-270f-11e6-81b3-005056a44da2","wordings":[{"value":"accident de personne","key":"external_long"},{"value":"accident de personne","key":"external_short"},{"value":"accident de personne","key":"internal"},{"value":"S I accident de personne","key":"external_medium"}],"created_at":"2016-05-31T09:13:36Z"},"id":"76acb7f4-8385-11e9-ac12-185e0fa9992b","tags":[]} |
        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects" should have a size of 4
        And the field "disruptions.0.impacts.impacts.0.objects.0" should have a size of 3
        And the field "disruptions.0.impacts.impacts.0.objects.0.type" should be "line_section"
        And the field "disruptions.0.impacts.impacts.0.objects.0.id" should be "line:DUA:800804081:76acb7f6-8385-11e9-ac12-185e0fa9992b"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section" should have a size of 3
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point" should have a size of 3
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point.type" should be "stop_area"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point.id" should be "stop_area:DUA:SA:8768603"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point.name" should be "PARIS GARE DE LYON"

        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.start_point.type" should be "stop_area"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.start_point.id" should be "stop_area:DUA:SA:8775860"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.start_point.name" should be "CHATELET LES HALLES"

        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.line.type" should be "line"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.line.id" should be "line:DUA:800804081"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.line.name" should be "Creil - Corbeil Essonnes / Melun / Malesherbes"

    Scenario: Test disruptions history when impact is on line section (type route_point)
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following history_disruption in my database:
        | id                                    |disruption_id                         | created_at          |  data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
        | 8ffab555-3d48-4eea-aa2c-22f8680230b6  | a750994c-01fe-11e4-b4fb-080027079ff3 | 2019-05-30T23:52:12 | {"status":"published","created_at":"2019-05-31T09:21:25Z","impacts":[{"created_at":"2019-05-31T09:21:25Z","updated_at":null,"disruption":{},"objects":[{"line_section":{"end_point":{"type":"stop_area","id":"stop_area:DUA:SA:8775860","name":"PARIS GARE DE LYON"},"line":{"type":"line","id":"line:DUA:800804081","name":"Creil - Corbeil Essonnes / Melun / Malesherbes"},"routes":[{"type":"route","id":"route:DUA:10011000100010","name":"Melun"}],"start_point":{"type":"stop_area","id":"stop_area:DUA:SA:8775860","name":"PARIS GARE DE LYON"}},"type":"line_section","id":"line:DUA:800804081:76acb752-8385-11e9-ac12-185e0fa9992b"}],"id":"76acb7f5-8385-11e9-ac12-185e0fa9992b","severity":{"color":"#FF4455","created_at":"2016-05-31T09:13:36Z","effect":"significant_delays","updated_at":null,"priority":2,"wordings":[{"value":"ralenti","key":"short"},{"value":"20 à 30 minutes supplémentaires de trajet","key":"long"},{"value":"20 à 30 min de trajet en plus","key":"medium"}],"id":"f4b1eba4-270f-11e6-83cb-005056a47b86","wording":"20 à 30 minutes supplémentaires de trajet"},"messages":[],"send_notifications":true,"notification_date":"2019-05-31T09:21:25Z","application_period_patterns":[],"application_periods":[{"begin":"2019-05-31T09:20:00Z","end":"2019-05-31T11:20:00Z"}]}],"reference":"realtime_root-20190531112012","publication_status":"ongoing","publication_period":{"begin":"2019-05-31T09:20:00Z","end":"2019-05-31T11:20:00Z"},"localization":[],"updated_at":null,"properties":{},"note":null,"version":1,"contributor":"shortterm.tr_transilien","cause":{"category":{"updated_at":"2016-05-31T09:13:36Z","created_at":"2015-02-05T14:22:56Z","id":"7a8160fa-ad42-11e4-adc9-005056a47b86","name":"Trafic inopiné"},"updated_at":null,"id":"f4fb6568-270f-11e6-81b3-005056a44da2","wordings":[{"value":"accident de personne","key":"external_long"},{"value":"accident de personne","key":"external_short"},{"value":"accident de personne","key":"internal"},{"value":"S I accident de personne","key":"external_medium"}],"created_at":"2016-05-31T09:13:36Z"},"id":"76acb7f4-8385-11e9-ac12-185e0fa9992b","tags":[]} |
        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects.0" should have a size of 3
        And the field "disruptions.0.impacts.impacts.0.objects.0.type" should be "line_section"
        And the field "disruptions.0.impacts.impacts.0.objects.0.id" should be "line:DUA:800804081:76acb752-8385-11e9-ac12-185e0fa9992b"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section" should have a size of 4
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point" should have a size of 3
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point.type" should be "stop_area"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point.id" should be "stop_area:DUA:SA:8775860"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.end_point.name" should be "PARIS GARE DE LYON"

        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.start_point.type" should be "stop_area"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.start_point.id" should be "stop_area:DUA:SA:8775860"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.start_point.name" should be "PARIS GARE DE LYON"

        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.line.type" should be "line"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.line.id" should be "line:DUA:800804081"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.line.name" should be "Creil - Corbeil Essonnes / Melun / Malesherbes"

        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.routes" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.routes.0.type" should be "route"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.routes.0.id" should be "route:DUA:10011000100010"
        And the field "disruptions.0.impacts.impacts.0.objects.0.line_section.routes.0.name" should be "Melun"

    Scenario: Test disruptions history with invalid UUID
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/disruptions/invalidUUID/history"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error" should have a size of 1
        And the field "error.message" should be "id invalid"
