Feature: list cause

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header

    Scenario: Call without client in the header fails
        I remove header "X-Customer-Id"
        When I get "/causes"
        Then the status code should be "400"

    Scenario: if there is no cause the list is empty
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/causes"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        and "causes" should be empty

    Scenario: list of two cause
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   |  created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/causes"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "causes" should have a size of 2

    Scenario: only visible causes have to be return
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | invisible | #123321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/causes"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "causes" should have a size of 2

    Scenario: I can view one cause
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"

    Scenario: I have a 400 if the id doesn't have the correct format
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/causes/7ffab230-3d48a-a2c-22f8680230b6"
        Then the status code should be "400"

    Scenario: The client in the header must exist in database
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | invisible | #123321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "6"
        When I get "/causes"
        Then the status code should be "404"

    Scenario: list of causes one with category and another without
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
    Given I have the following categories in my database:
        | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording   |  created_at          | updated_at          | is_visible |category_id                          | id                                   |client_id                            |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | None                                | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       |7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/causes"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "causes" should have a size of 2

    Scenario: list of causes by category
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
    Given I have the following categories in my database:
        | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording   |  created_at          | updated_at          | is_visible |category_id                          | id                                   |client_id                            |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | None                                | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       |7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/causes?category=7ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "causes" should have a size of 1
        And the field "causes.0.category.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
