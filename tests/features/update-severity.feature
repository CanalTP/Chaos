Feature: update severity

    Background:
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"

    Scenario: I cannot update a severity without client in header
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following wording in my database:
            | key       | value     | color   | created_at          | updated_at          | id                                   |
            |  key1     | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            |  key2     | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_wording_severity in my database:
            | wording_id                                | severity_id                           |
            |  7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab232-3d48-4eea-aa2c-22f8680230b6  |

        I remove header "X-Customer-Id"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "test", "value": "foo"}], "color": "blue"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

    Scenario: deletion with client absent in database fails
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following wording in my database:
            | key       | value     | color   | created_at          | updated_at          | id                                   |
            |  key1     | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            |  key2     | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_wording_severity in my database:
            | wording_id                                | severity_id                           |
            |  7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab232-3d48-4eea-aa2c-22f8680230b6  |

        I fill in header "X-Customer-Id" with "6"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "test", "value": "foo"}], "color": "blue"}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"

    Scenario: the Severity must exist
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "404"

    Scenario: a severity must have a wording and it should not be empty
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"color": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [], "color": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "wordings should not be empty"

    Scenario: I can update the wording of a severity
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following wording in my database:
            | key       | value     | color   | created_at          | updated_at          | id                                   |
            |  key1     | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            |  key2     | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_wording_severity in my database:
            | wording_id                                | severity_id                           |
            |  7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab230-3d48-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab232-3d48-4eea-aa2c-22f8680230b6  |
        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "test", "value": "foo"}], "color": "blue"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wordings.0.value" should be "foo"
        And the field "severity.wordings.0.key" should be "test"
        And the field "severity.color" should be "blue"

    Scenario: I can update the effect of a severity
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   | effect |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None   |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | None   |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wordings": [{"key": "test", "value": "foo"}], "color": "blue", "effect": "no_service"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wordings.0.key" should be "test"
        And the field "severity.wordings.0.value" should be "foo"
        And the field "severity.effect" should be "no_service"
        And in the database for the severity "7ffab230-3d48-4eea-aa2c-22f8680230b6" the field "effect" should be "no_service"

    Scenario: I can't update a invisible severity
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"

    Scenario: update severity by id invalid
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities/AA" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: update severity by id not in url
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | blocking  | #123456 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "5"
        When I put to "/severities" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

        When I put to "/severities/" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: Client could update only his severity

        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 7             | 2017-01-30T00:00:00 | 2017-01-30T00:00:00 | 5ffab229-3d48-4eea-aa2c-22f8680230b5 |
        | 8             | 2017-01-30T00:00:00 | 2017-01-30T00:00:00 | 6ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
        | wording                | color   | created_at          | updated_at          | is_visible | id                                   | client_id                            |
        | severity_for_client_7  | #123456 | 2017-01-30T00:00:00 | 2017-01-30T00:00:00 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 5ffab229-3d48-4eea-aa2c-22f8680230b5 |
        | severity_for_client_8  | #ffffff | 2017-01-30T00:00:00 | 2017-01-30T00:00:00 | True       | 6ffab229-3d48-4eea-aa2c-22f8680230b6 | 6ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Customer-Id" with "8"

        #trying update severity of client_8 by client_7 should raise an arror
        When I put to "/severities/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        { "color": "#FFFFFF", "effect": "no_service", "priority": 1, "wording": "Blocking", "wordings": [ { "key": "short", "value": "short" }, { "key": "medium", "value": "medium" }, { "key": "long", "value": "long" } ]}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error" should have a size of 1
        And the field "error.message" should be "The severty with id 7ffab230-3d48-4eea-aa2c-22f8680230b6 does not exist for this client"

        #trying update severity of client_8 by client_8 should be fine
        When I put to "/severities/6ffab229-3d48-4eea-aa2c-22f8680230b6" with:
        """
        { "color": "#111111", "effect": "no_service", "priority": 1, "wording": "Blocking", "wordings": [ { "key": "short", "value": "short" }, { "key": "medium", "value": "medium" }, { "key": "long", "value": "long" } ]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "severity.color" should be "#111111"
