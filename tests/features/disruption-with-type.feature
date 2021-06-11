Feature: Handle Disruption with author
    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Coverage" with "jdr"
        I fill navitia authorization in header
        I fill in header "X-Contributors" with "contrib1"

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2019-04-02T23:52:12 | 2019-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2019-04-04T23:52:12 | 2019-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2019-04-02T23:52:12 | 2019-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

    Scenario: Create disruption with unexpected type
        When I post to "/disruptions" with:
        """
        {"reference": "foo","contributor": "contrib1","cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2019-04-29T16:52:00Z","end": "2019-06-22T02:15:00Z"}]}],"type":"unexpected"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.type" should be "unexpected"

    Scenario: Get disruption with type
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date     | end_publication_date  |cause_id                              | client_id                            | contributor_id                       | type       |
            | foo       | hello | 2019-04-02T23:52:12 | 2019-04-02T23:55:12 | published | 7bbab230-3d48-4eea-aa2c-22f8680230b6 | 2019-04-01T00:00:00        | 2019-04-02T00:00:00   | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | unexpected |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status     | id                                   | disruption_id                          |severity_id                            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published  | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7bbab230-3d48-4eea-aa2c-22f8680230b6   |7ffab232-3d48-4eea-aa2c-22f8680230b6   |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published  | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7bbab230-3d48-4eea-aa2c-22f8680230b6   |7ffab232-3d48-4eea-aa2c-22f8680230b6   |

        When I get "/disruptions/7bbab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.type" should be "unexpected"

    Scenario: Update disruption with type
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       | type       |
            | foo       | hello | 2019-04-02T23:52:12 | 2019-04-02T23:55:12 | published | 7bbab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | unexpected |

        When I put to "/disruptions/7bbab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo","contributor": "contrib1","publication_period": {"begin": "2019-06-24T13:35:00Z","end": "2019-07-08T18:00:00Z"},"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2019-06-24T13:35:00Z","end": "2019-07-08T18:00:00Z"}]}], "type": null}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.type" should be null

    Scenario: Update disruption with undefined type
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       | type       |
            | foo       | hello | 2019-04-02T23:52:12 | 2019-04-02T23:55:12 | published | 7bbab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | unexpected |

        When I put to "/disruptions/7bbab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo","contributor": "contrib1","publication_period": {"begin": "2019-06-24T13:35:00Z","end": "2019-07-08T18:00:00Z"},"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2019-06-24T13:35:00Z","end": "2019-07-08T18:00:00Z"}]}], "type": "undefined_type"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "u'undefined_type' is not one of [None, 'unexpected']"

    Scenario: History of a disruption
        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | cause2    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7bfab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date | cause_id                               | client_id                            | contributor_id                         |version|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2018-09-11T13:50:00    | 2018-12-31T16:50:00  | 7ffab230-3d48-4eea-aa2c-22f8680230b6   | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6   |1      |
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
            | stop_area| stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area| stop_area:JDR:BASTI | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
        Given I have the following associate_disruption_properties in my database:
            | value | disruption_id                        | property_id                          |
            | val1  | a750994c-01fe-11e4-b4fb-080027079ff3 | e408adec-0243-11e6-954b-0050568c8382 |
        Given I have the following history_disruption in my database:
            | id | disruption_id  | data        | created_at          |
            | 8ffab555-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 | {"status": "published", "created_at": "2014-04-02T23:52:12Z", "impacts": [{"created_at": "2019-05-27T09:44:50Z", "updated_at": null, "disruption": {}, "objects": [{"type": "network", "id": "network:JDR:1", "name": "RATP"}], "id": "121fd37d-8064-11e9-9e35-34e6d748c530", "severity": {"color": "#654321", "created_at": "2014-04-04T23:52:12Z", "effect": "unknown_effect", "updated_at": "2014-04-06T22:52:12Z", "priority": null, "wordings": [], "id": "7ffab232-3d48-4eea-aa2c-22f8680230b6", "wording": "good news"}, "messages": [], "send_notifications": false, "notification_date": null, "application_period_patterns": [], "application_periods": [{"begin": "2014-04-29T16:52:00Z", "end": "2014-06-22T02:15:00Z"}]}], "reference": "foo", "publication_status": "past", "publication_period": {"begin": "2018-09-11T13:50:00Z", "end": "2018-12-31T16:50:00Z"}, "localization": [], "updated_at": "2019-05-27T09:44:50Z", "properties": {"property_type_1": [{"property": {"updated_at": null, "id": "e408adec-0243-11e6-954b-0050568c8382", "key": "key", "type": "type", "created_at": "2019-05-28T13:46:57Z"}, "value": "val1"}]}, "note": "hello", "version": 1, "contributor": "contrib1", "cause": {"category": null, "updated_at": "2014-04-02T23:55:12Z", "id": "7ffab230-3d48-4eea-aa2c-22f8680230b6", "wordings": [], "created_at": "2014-04-02T23:52:12Z"}, "id": "a750994c-01fe-11e4-b4fb-080027079ff3", "tags":[{"updated_at":"2014-04-02T23:55:12Z","created_at":"2014-04-02T23:52:12Z","id":"5ffab230-3d48-4eea-aa2c-22f8680230b6","name":"weather"}]} | 2014-04-02T23:52:12 |
        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foo2", "contributor": "contrib1", "type": "unexpected", "properties":[], "cause":{"id":"7bfab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions.0.type" should be "unexpected"
        And the field "disruptions.1.type" should be null
