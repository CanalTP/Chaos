Feature: list cause

    Scenario: if there is no cause the list is empty
        When I get "/causes"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        and "causes" should be empty

        Scenario: list of two cause
            Given I have the following causes in my database:
                | wording   |  created_at          | updated_at          | is_visible | id                                   |
                | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
                | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            When I get "/causes"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "causes" should have a size of 2
            And the field "causes.0.wording" should be "weather"
            And the field "causes.1.wording" should be "strike"


        Scenario: only visible causes have to be return
            Given I have the following causes in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |
                | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
                | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
                | invisible | #123321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |
            When I get "/causes"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "causes" should have a size of 2
            And the field "causes.0.wording" should be "weather"
            And the field "causes.1.wording" should be "strike"

        Scenario: I can view one cause
            Given I have the following causes in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |
                | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
                | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            When I get "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "cause.wording" should be "weather"

        Scenario: I have a 400 if the id doesn't have the correct format
            Given I have the following causes in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |
                | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
                | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            When I get "/causes/7ffab230-3d48a-a2c-22f8680230b6"
            Then the status code should be "400"
