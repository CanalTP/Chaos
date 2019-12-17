Feature: Update disruptions with properties

    Background:
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"

    Scenario: Update a disruption and do not change its properties
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
            | created_at          | id                                   | client_id                            | key    | type   |
            | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
            | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following associate_disruption_properties in my database:
            | value | disruption_id                        | property_id                          |
            | val1  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
            | val2  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | f408adec-0243-11e6-954b-0050568c8382 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo","contributor": "contributor","cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.properties" should be not null
        And the field "disruption.properties" should have a size of 2

    Scenario: Update a disruption and unlink its properties
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
            | created_at          | id                                   | client_id                            | key    | type   |
            | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
            | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following associate_disruption_properties in my database:
            | value | disruption_id                        | property_id                          |
            | val1  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
            | val2  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | f408adec-0243-11e6-954b-0050568c8382 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo","contributor": "contributor","cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}],"properties": []}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.properties" should be not null
        And the field "disruption.properties" should have a size of 0

    Scenario: Update a disruption and unlink one of its properties
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
            | created_at          | id                                   | client_id                            | key    | type   |
            | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
            | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following associate_disruption_properties in my database:
            | value | disruption_id                        | property_id                          |
            | val1  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
            | val2  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | f408adec-0243-11e6-954b-0050568c8382 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo","contributor": "contributor","cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c8382","value": "val1"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.properties" should be not null
        And the field "disruption.properties" should have a size of 1
        And the field "disruption.properties.type.0.property.id" should be "e408adec-0243-11e6-954b-0050568c8382"

    Scenario: Update a disruption and update one of its properties
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
            | created_at          | id                                   | client_id                            | key    | type   |
            | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
            | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        Given I have the following associate_disruption_properties in my database:
            | value           | disruption_id                        | property_id                          |
            | old type value  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
            | old test value  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | f408adec-0243-11e6-954b-0050568c8382 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo","contributor": "contributor","cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c8382","value": "old type value"},{"property_id": "f408adec-0243-11e6-954b-0050568c8382","value": "new test value"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.properties" should be not null
        And the field "disruption.properties" should have a size of 2
        And the field "disruption.properties.type.0.property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "disruption.properties.type.0.value" should be "old type value"
        And the field "disruption.properties.test.0.property.id" should be "f408adec-0243-11e6-954b-0050568c8382"
        And the field "disruption.properties.test.0.value" should be "new test value"

    Scenario: The property must have the field value
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c8382"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'value' is a required property"

    Scenario: The property's value must not be empty
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c8382", "value": ""}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "u'' is too short"

    Scenario: The property's value must be a string
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c8382", "value": 42}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "42 is not of type 'string'"

    Scenario: The property must have the field property_id
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"value": "test"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'property_id' is a required property"

    Scenario: The property's id must not be empty
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"property_id": "", "value": "test"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "u'' does not match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'"

    Scenario: The property's id must be a valid uuid
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c838", "value": "test"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "u'e408adec-0243-11e6-954b-0050568c838' does not match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'"

    Scenario: The property must exist before linking it to a disruption
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
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "properties": [{"property_id": "e408adec-0243-11e6-954b-0050568c8382", "value": "val1"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "property e408adec-0243-11e6-954b-0050568c8382 not found"
