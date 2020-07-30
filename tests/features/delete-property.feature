Feature: Delete property

    Background:
        I fill in header "X-Customer-Id" with "test"
        I fill navitia authorization in header

    Scenario: we cannot delete a property without header X-Customer-Id
        I remove header "X-Customer-Id"
        When I delete to "/properties/7ffab230-3d48-4eea-aa2c-22f8680230b6":
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Customer-Id does not exist in the header"


    Scenario: we cannot delete a property without referencing its id in request arguments
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I delete to "/properties":
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"


    Scenario: the client must exist in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I remove header "X-Customer-Id"
        I fill in header "X-Customer-Id" with "no-test"
        When I delete to "/properties/e408adec-0243-11e6-954b-0050568c8382"
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "X-Customer-Id no-test Not Found"


    Scenario: the property must exist in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I delete to "/properties/e408adec-0243-11e6-954b-0050568c8382"
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "Property e408adec-0243-11e6-954b-0050568c8382 not found"


    Scenario: the property must not be linked to a disruption that is not archived
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
        | contributor_code   | created_at          | id                                   |
        | contrib1           | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
        | wording | created_at          | is_visible | id                                   | client_id                            |
        | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
        | reference | note  | created_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       |
        | foo       | hello | 2014-04-02T23:52:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
        Given I have the following associate_disruption_properties in my database:
        | value | disruption_id                        | property_id                          |
        | test  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
        When I delete to "/properties/e408adec-0243-11e6-954b-0050568c8382"
        Then the status code should be "409"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The current <Property: e408adec-0243-11e6-954b-0050568c8382 type key> is linked to at least one disruption and cannot be deleted"


    Scenario: delete a property
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          |id                                    | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I delete to "/properties/e408adec-0243-11e6-954b-0050568c8382"
        Then the status code should be "204"


    Scenario: delete a property linked to an archived disruption
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
        | contributor_code   | created_at          | id                                   |
        | contrib1           | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
        | wording | created_at          | is_visible | id                                   | client_id                            |
        | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
        | reference | note  | created_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       |
        | foo       | hello | 2014-04-02T23:52:12 | archived | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | key    | type   |
        Given I have the following associate_disruption_properties in my database:
        | value | disruption_id                        | property_id                          |
        | test  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | e408adec-0243-11e6-954b-0050568c8382 |
        When I delete to "/properties/e408adec-0243-11e6-954b-0050568c8382"
        Then the status code should be "204"
