Feature: disruption with impacts history

    Background:

        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Contributors" with "contrib1"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"

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
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   | client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

    Scenario: List an updated disruption with impact posted

        Given I have the following disruptions in my database:
            | reference | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date | cause_id                               | client_id                            | contributor_id                         |version|
            | foo       | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff4 | 2018-09-11T13:50:00    | 2018-12-31T16:50:00  | 7ffab230-3d48-4eea-aa2c-22f8680230b6   | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6   |1      |

        When I post to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff4/impacts" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "line:JDR:RER-B","type": "line"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects" should exist
        And the field "impact.objects" should have a size of 1
        And the field "impact.objects.0.id" should be "line:JDR:RER-B"
        And the field "impact.objects.0.type" should be "line"

        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff4/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects.0.id" should be "line:JDR:RER-B"

    Scenario: List of an updated disruption with impact put

        Given I have the following disruptions in my database:
            | reference | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date | cause_id                               | client_id                            | contributor_id                         |version|
            | foo       | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2018-09-11T13:50:00    | 2018-12-31T16:50:00  | 7ffab230-3d48-4eea-aa2c-22f8680230b6   | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6   |1      |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 4ffab232-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/impacts/4ffab232-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "network:JDR:2","type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects" should have a size of 1
        And the field "impact.objects.0.id" should be "network:JDR:2"
        And the field "impact.objects.0.type" should be "network"

        When I get "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects" should have a size of 1
        And the field "disruptions.0.impacts.impacts.0.objects.0.id" should be "network:JDR:2"

    Scenario: List an updated disruption with impacts deleted

        Given I have the following disruptions in my database:
            | reference | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date | cause_id                               | client_id                            | contributor_id                         |version|
            | foo       | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | b750994c-01fe-11e4-b4fb-080027079ff5 | 2018-09-11T13:50:00    | 2018-12-31T16:50:00  | 7ffab230-3d48-4eea-aa2c-22f8680230b6   | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6   |1      |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | b750994c-01fe-11e4-b4fb-080027079ff5 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:53:13 | 2014-04-06T20:50:10 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b2 | b750994c-01fe-11e4-b4fb-080027079ff5 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        When I delete "/disruptions/b750994c-01fe-11e4-b4fb-080027079ff5/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b1" with:
        Then the status code should be "204"

        When I get "/disruptions/b750994c-01fe-11e4-b4fb-080027079ff5/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 2

        When I delete "/disruptions/b750994c-01fe-11e4-b4fb-080027079ff5/impacts/7ffab234-3d49-4eea-aa2c-22f8680230b2" with:
        Then the status code should be "204"

        When I get "/disruptions/b750994c-01fe-11e4-b4fb-080027079ff5/history"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        And the field "disruptions.0.status" should be "archived"
