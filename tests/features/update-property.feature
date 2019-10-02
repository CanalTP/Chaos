Feature: Update property

    Background:
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"

    Scenario: we cannot update a property without header X-Customer-Id
        I remove header "X-Customer-Id"
        When I put to "/properties/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"key": "test", "type": "test"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Customer-Id does not exist in the header"

    Scenario: we cannot update a property without referencing its id in request arguments
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/properties" with:
        """
        {"key": "test", "type": "test"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: the client must exist in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "no-test"
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test", "type": "test"}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "X-Customer-Id no-test Not Found"

    Scenario: the property must exist in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test", "type": "test"}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "Property e408adec-0243-11e6-954b-0050568c8382 not found"

    Scenario: we cannot update a property without data
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """

        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "None is not of type 'object'"

    Scenario: we cannot update a property without 'key' and 'type' in data
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'key' is a required property"

    Scenario: we cannot update a property without 'key' data
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"type": "test"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'key' is a required property"

    Scenario: we cannot create a property without 'type' data
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'type' is a required property"

    Scenario: we cannot create a property with an empty 'key' value
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "", "type": "test"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'' is too short"

    Scenario: we cannot create a property with an empty 'type' value
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test", "type": ""}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'' is too short"

    Scenario: 'key' value must be a string
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": 42, "type": "test"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "42 is not of type 'string'"

    Scenario: 'type' value must be a string
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test", "type": 42}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "42 is not of type 'string'"

    Scenario: we cannot update a property if new 'key' and 'type' values are both used in an other one
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "notest", "type": "notest"}
        """
        Then the status code should be "409"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should contain "UniqueViolation"

    Scenario: update a property with valid data
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | id                                   | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        | 2014-04-02T23:52:12 | f408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | notest | notest |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test", "type": "notest"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "property" should have a size of 6
        And the field "property.key" should be "test"
        And the field "property.type" should be "notest"
        And the field "property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "property.created_at" should be "2014-04-02T23:52:12Z"
        And the field "property.updated_at" should be not null
        And the field "property.self.href" should be not null

    Scenario: trying to update a property with the same data as before won't update in database
        Given I have the following clients in my database:
        | client_code | created_at          | updated_at          | id                                   |
        | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following properties in my database:
        | created_at          | updated_at          |id                                    | client_id                            | key    | type   |
        | 2014-04-02T23:52:12 | 2014-04-03T00:52:12 | e408adec-0243-11e6-954b-0050568c8382 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | test   | test   |
        When I put to "/properties/e408adec-0243-11e6-954b-0050568c8382" with:
        """
        {"key": "test", "type": "test"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "property" should have a size of 6
        And the field "property.key" should be "test"
        And the field "property.type" should be "test"
        And the field "property.id" should be "e408adec-0243-11e6-954b-0050568c8382"
        And the field "property.created_at" should be "2014-04-02T23:52:12Z"
        And the field "property.updated_at" should be "2014-04-03T00:52:12Z"
        And the field "property.self.href" should be not null
