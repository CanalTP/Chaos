Feature: Create cause

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"

    Scenario: we cannot create a cause without client
        I remove header "X-Customer-Id"
        When I post to "/causes"
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}], "category":{"id": "7ffab555-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

    Scenario: wordings is required
        When I post to "/causes"
        """
        {"category":{"id": "7ffab555-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'wordings' is a required property"

    Scenario: wordings empty
        When I post to "/causes"
        """
        {"wordings": [], "category":{"id": "7ffab555-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "wordings should not be empty"

    Scenario: creation of cause
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/causes" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}], "category":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "cause.wordings" should have a size of 2

    Scenario: Cause are created
       Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/causes" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}], "category":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        When I get "/causes"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "causes" should have a size of 1
        And the field "causes.0.wordings" should have a size of 2

    Scenario: Cause with category not in database
       Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/causes" with:
        """
        {"wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}], "category":{"id": "6ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"

    Scenario: Cause with empty key
       Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/causes" with:
        """
        {"wordings": [{"key": "  ", "value": "bb"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "Json invalid: key is empty, you give : [{u'value': u'bb', u'key': u'  '}]"

    Scenario: creation of cause with default wording
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/causes" with:
        """
        {"wording": "mm", "wordings": [{"key": "aa", "value": "bb"}, {"key": "dd", "value": "cc"}, {"key": "pp", "value": "mm"}], "category":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "cause.wordings" should have a size of 3
