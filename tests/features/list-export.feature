Feature: list export

    Background:
        Given I fill in header "X-Customer-Id" with "5"
        And I fill navitia authorization in header

    Scenario: list without client in the header fails
        Given I remove header "X-Customer-Id"
        When I get "/impacts/exports"
        Then the status code should be "400"

    Scenario: list without client in the database fails
        When I get "/impacts/exports"
        Then the status code should be "404"

    Scenario: if no export for a client, the list is empty
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/impacts/exports"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And "exports" should be empty

    Scenario: list of two exports
        Given I have the following clients in my database:
            | client_code   | created_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | 6             | 2014-04-02T23:52:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b7 |
        Given I have the following exports in my database:
            | id                                   | client_id                            | status   | time_zone    | created_at          | process_start_date  | start_date          | end_date            | file_path                                           |
            | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | done     | UTC          | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 2014-03-01T00:00:00 | 2014-04-01T00:00:00 | /tmp/5/export_2014-03-01T00-00_2014-04-01T00-00.csv |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | handling | Europe/Paris | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2014-02-01T00:00:00 | 2014-03-01T00:00:00 | /tmp/5/export_2014-02-01T00-00_2014-03-01T00-00.csv |
            | 7ffab234-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b7 | done     | UTC          | 2014-04-04T23:52:12 | 2014-04-05T22:52:12 | 2014-02-01T00:00:00 | 2014-02-15T00:00:00 | /tmp/6/export_2014-02-01T00-00_2014-02-15T00-00.csv |
        When I get "/impacts/exports"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "exports" should have a size of 2
        And the field "exports.0.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "exports.0.status" should be "done"
        And the field "exports.0.created_at" should be "2014-04-02T23:52:12Z"
        And the field "exports.0.process_start_date" should be "2014-04-02T23:55:12Z"
        And the field "exports.0.start_date" should be "2014-03-01T00:00:00Z"
        And the field "exports.0.end_date" should be "2014-04-01T00:00:00Z"
        And the field "exports.0.time_zone" should be "UTC"
        And the field "exports.1.id" should be "7ffab232-3d48-4eea-aa2c-22f8680230b6"
        And the field "exports.1.time_zone" should be "Europe/Paris"

    Scenario: get export by id valid
        Given I have the following clients in my database:
            | client_code   | created_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | 6             | 2014-04-02T23:52:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b7 |
        Given I have the following exports in my database:
            | id                                   | client_id                            | status   | created_at          | process_start_date  | start_date          | end_date            | file_path                                           |
            | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | done     | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 2014-03-01T00:00:00 | 2014-04-01T00:00:00 | /tmp/5/export_2014-03-01T00-00_2014-04-01T00-00.csv |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | handling | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2014-02-01T00:00:00 | 2014-03-01T00:00:00 | /tmp/5/export_2014-02-01T00-00_2014-03-01T00-00.csv |
            | 7ffab234-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b7 | done     | 2014-04-04T23:52:12 | 2014-04-05T22:52:12 | 2014-02-01T00:00:00 | 2014-02-15T00:00:00 | /tmp/6/export_2014-02-01T00-00_2014-02-15T00-00.csv |
        When I get "/impacts/exports/7ffab232-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "export.id" should be "7ffab232-3d48-4eea-aa2c-22f8680230b6"
        And the field "export.status" should be "handling"
        And the field "export.created_at" should be "2014-04-04T23:52:12Z"
        And the field "export.process_start_date" should be "2014-04-06T22:52:12Z"
        And the field "export.start_date" should be "2014-02-01T00:00:00Z"
        And the field "export.end_date" should be "2014-03-01T00:00:00Z"
        And the field "export.time_zone" should be "UTC"

    Scenario: get export with invalid id
        Given I have the following clients in my database:
            | client_code   | created_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | 6             | 2014-04-02T23:52:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b7 |
        Given I have the following exports in my database:
            | id                                   | client_id                            | status   | created_at          | process_start_date  | start_date          | end_date            | file_path                                           |
            | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | done     | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 2014-03-01T00:00:00 | 2014-04-01T00:00:00 | /tmp/5/export_2014-03-01T00-00_2014-04-01T00-00.csv |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | handling | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2014-02-01T00:00:00 | 2014-03-01T00:00:00 | /tmp/5/export_2014-02-01T00-00_2014-03-01T00-00.csv |
            | 7ffab234-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b7 | done     | 2014-04-04T23:52:12 | 2014-04-05T22:52:12 | 2014-02-01T00:00:00 | 2014-02-15T00:00:00 | /tmp/6/export_2014-02-01T00-00_2014-02-15T00-00.csv |
        When I get "/impacts/exports/8ffab232-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "404"
