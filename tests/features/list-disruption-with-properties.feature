Feature: List disruptions with properties

    Scenario: list all disruptions with properties linked to them in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
        | contributor_code | created_at          | id                                   |
        | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
        | wording | created_at          | is_visible | id                                   | client_id                            |
        | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
        | reference | note  | created_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
        | foo       | hello | 2014-04-02T23:52:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:52:12  |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following associate_disruption_properties in my database:
        | value | disruption_id                        | property_id                          |
        | val1  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
        | val2  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | f408adec-0243-11e6-954b-0050568c8382 |
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"
        When I get to "/disruptions":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions.0.properties" should have a size of 2
        And the field "disruptions.0.properties.type.0.property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "disruptions.0.properties.type.0.value" should be "val1"
        And the field "disruptions.0.properties.test.0.property.id" should be "f408adec-0243-11e6-954b-0050568c8382"
        And the field "disruptions.0.properties.test.0.value" should be "val2"


    Scenario: list all disruptions without properties linked to them in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
        | contributor_code | created_at          | id                                   |
        | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
        | wording | created_at          | is_visible | id                                   | client_id                            |
        | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
        | reference | note  | created_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
        | foo       | hello | 2014-04-02T23:52:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:52:12  |
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"
        When I get to "/disruptions":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions.0.properties" should be not null
        And the field "disruptions.0.properties" should have a size of 0


    Scenario: list one disruption with properties linked to it in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
        | contributor_code | created_at          | id                                   |
        | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
        | wording | created_at          | is_visible | id                                   | client_id                            |
        | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
        | reference | note  | created_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
        | foo       | hello | 2014-04-02T23:52:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:52:12  |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following associate_disruption_properties in my database:
        | value | disruption_id                        | property_id                          |
        | val1  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
        | val2  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | f408adec-0243-11e6-954b-0050568c8382 |
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"
        When I get to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.properties" should have a size of 2
        And the field "disruption.properties.type.0.property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "disruption.properties.type.0.value" should be "val1"
        And the field "disruption.properties.test.0.property.id" should be "f408adec-0243-11e6-954b-0050568c8382"
        And the field "disruption.properties.test.0.value" should be "val2"
