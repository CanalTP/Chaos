Feature: List property

    Background:
        I fill in header "X-Customer-Id" with "test"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: we cannot list properties without header X-Customer-Id
        I remove header "X-Customer-Id"
        When I get to "/properties":
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Customer-Id does not exist in the header"

    Scenario: the client must exist in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "no-test"
        When I get to "/properties":
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "X-Customer-Id no-test Not Found"

    Scenario: list all properties without properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get to "/properties":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "properties" should have a size of 0

    Scenario: list all properties with 3 existing properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        | 2014-04-02T23:52:12 | d408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | notest |
        When I get to "/properties":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "properties" should have a size of 3

    Scenario: the requested property must exist in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get to "/properties/e408adec-0243-11e6-954b-0050568c8382":
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "Property e408adec-0243-11e6-954b-0050568c8382 not found"

    Scenario: list one property by id with 3 existing properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        | 2014-04-02T23:52:12 | d408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | notest |
        When I get to "/properties/e408adec-0243-11e6-954b-0050568c8382":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "property" should have a size of 5
        And the field "property.key" should be "test"
        And the field "property.type" should be "test"
        And the field "property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "property.created_at" should be "2014-04-02T23:52:12Z"
        And the field "property.self.href" should contain "properties/e408adec-0243-11e6-954b-0050568c8382"

    Scenario: list properties filtered by an existing 'key' with 3 existing properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        | 2014-04-02T23:52:12 | d408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | notest |
        When I get to "/properties?key=test":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "properties" should have a size of 2

    Scenario: list properties filtered by a non existing 'key' with 3 existing properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        | 2014-04-02T23:52:12 | d408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | notest |
        When I get to "/properties?key=42":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "properties" should have a size of 0

    Scenario: list properties filtered by an existing 'type' with 3 existing properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        | 2014-04-02T23:52:12 | d408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | notest |
        When I get to "/properties?type=test":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "properties" should have a size of 1
        And the field "properties.0.id" should be "e408adec-0243-11e6-954b-0050568c8382"

    Scenario: list properties filtered by a non existing 'type' with 3 existing properties in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        | 2014-04-02T23:52:12 | d408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | notest |
        When I get to "/properties?type=42":
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "properties" should have a size of 0
