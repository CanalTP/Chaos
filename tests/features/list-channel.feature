Feature: list channel

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header

    Scenario: list without client in the header fails
        I remove header "X-Customer-Id"
        When I get "/channels"
        Then the status code should be "400"

    Scenario: list without client in the database fails
        When I get "/channels"
        Then the status code should be "404"

    Scenario: if there is no channel the list is empty
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/channels"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        and "channels" should be empty

    Scenario: list of two channels
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   | client_id                            | required
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | true
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | false
        When I get "/channels"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "channels" should have a size of 2
        And the field "channels.0.name" should be "email"
        And the field "channels.0.max_size" should be 520
        And the field "channels.0.content_type" should be "text/plain"
        And the field "channels.0.required" should be "False"
        And the field "channels.1.required" should be "True"

    Scenario: list of four channels sorted by name
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following channels in my database:
            | name                  | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | Message SMS (OV1)     | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b7 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | Message Email (OV1)   | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b8 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | short                 | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b9 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | long                  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b5 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/channels"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "channels" should have a size of 4
        And the field "channels.0.name" should be "long"
        And the field "channels.1.name" should be "Message Email (OV1)"
        And the field "channels.2.name" should be "Message SMS (OV1)"
        And the field "channels.3.name" should be "short"

    Scenario: I have a 400 if the id doesn't have the correct format
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/channels/7ffab230-3d48a-a2c-22f8680230b6"
        Then the status code should be "400"

    Scenario: get channel by id valid
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/channels/7ffab232-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the field "channel.name" should be "email"
        And the field "channel.max_size" should be 520
        And the field "channel.content_type" should be "text/plain"
