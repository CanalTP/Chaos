Feature: update cause

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: modify of Cause without client in the header fails
        I remove header "X-Customer-Id"
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"

    Scenario: The client in the header must exist in database
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "6"
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "404"

    Scenario: the Cause must exist
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "404"

    Scenario: the Cause with id not valid
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/AA-BB" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: the Cause with id not in url
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

        When I put to "/causes/" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: a cause must have a wording
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings":[]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "wordings should not be empty"

    Scenario: I can update the wording of a cause
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "cause.wordings" should have a size of 2
        And in the database for the cause "7ffab230-3d48-4eea-aa2c-22f8680230b6" the field "wording" should be "bb"

    Scenario: I can update a cause with a default wording
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wording": "cc", "wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "cause.wordings" should have a size of 2
        And in the database for the cause "7ffab230-3d48-4eea-aa2c-22f8680230b6" the field "wording" should be "cc"

    Scenario: I can't update a invisible cause
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}]}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"

    Scenario: I can update the category of a cause
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      |created_at          | updated_at          | id                                   | client_id                            |
            | foo       |2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | test      |2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 6ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible |category_id                           | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       |7ffab230-3d48-4eea-aa2c-22f8680230b6  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      |6ffab230-3d48-4eea-aa2c-22f8680230b6  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}], "category":{"id": "6ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "cause.category.id" should be "6ffab230-3d48-4eea-aa2c-22f8680230b6"

    Scenario: I can update  a cause with category null
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      |created_at          | updated_at          | id                                   | client_id                            |
            | foo       |2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible |category_id                               | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       |7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      |7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put to "/causes/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
