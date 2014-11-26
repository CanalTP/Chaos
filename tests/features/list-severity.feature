Feature: list severity

    Scenario: if there is no severity the list is empty
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Customer-Id" with "5"
        When I get "/severities"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        and "severities" should be empty

        Scenario: No severity without client in the header
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            When I get "/severities"
            Then the status code should be "400"
            And the header "Content-Type" should be "application/json"

        Scenario: No severity for a client absent in the base
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "6"
            When I get "/severities"
            Then the status code should be "400"
            And the header "Content-Type" should be "application/json"

        Scenario: list of two severity
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "5"
            When I get "/severities"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "severities" should have a size of 2
            And the field "severities.0.wording" should be "blocking"
            And the field "severities.0.color" should be "#123456"
            And the field "severities.0.priority" should be null
            And the field "severities.1.wording" should be "good news"
            And the field "severities.1.color" should be "#654321"
            And the field "severities.1.priority" should be null


        Scenario: only visible severities have to be return
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | invisible | #123321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "5"
            When I get "/severities"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "severities" should have a size of 2
            And the field "severities.0.wording" should be "blocking"
            And the field "severities.1.wording" should be "good news"

        Scenario: I can view one severity
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "5"
            When I get "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "severity.wording" should be "blocking"

        Scenario: I have a 400 if the id doesn't have the correct format
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "5"
            When I get "/severities/7ffab230-3d48a-a2c-22f8680230b6"
            Then the status code should be "400"

        Scenario: Severities are sorted by priority
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   | priority |client_id                            |
                | null       | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True      | 7ffab238-3d48-4eea-aa2c-22f8680230b6 | None     |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 2        |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 1        |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | foo       | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab234-3d48-4eea-aa2c-22f8680230b6 | 4        |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | bar       | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab236-3d48-4eea-aa2c-22f8680230b6 | 3        |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "5"
            When I get "/severities"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "severities" should have a size of 5
            And the field "severities.0.wording" should be "good news"
            And the field "severities.0.priority" should be "1"
            And the field "severities.1.wording" should be "blocking"
            And the field "severities.1.priority" should be "2"
            And the field "severities.2.wording" should be "bar"
            And the field "severities.2.priority" should be "3"
            And the field "severities.3.wording" should be "foo"
            And the field "severities.3.priority" should be "4"
            And the field "severities.4.wording" should be "null"
            And the field "severities.4.priority" should be null

        Scenario: list of two severity with one blocking
            Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   | effect   |client_id                            |
                | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None     |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | blocking |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            I fill in header "X-Customer-Id" with "5"
            When I get "/severities"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "severities" should have a size of 2
            And the field "severities.0.wording" should be "blocking"
            And the field "severities.0.color" should be "#123456"
            And the field "severities.0.effect" should be null
            And the field "severities.0.priority" should be null
            And the field "severities.1.wording" should be "good news"
            And the field "severities.1.color" should be "#654321"
            And the field "severities.1.priority" should be null
            And the field "severities.1.effect" should be "blocking"
