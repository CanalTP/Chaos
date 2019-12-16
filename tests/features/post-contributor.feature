Feature: Create contributor

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"

    Scenario: we cannot create contributor without client in the header
        I remove header "X-Customer-Id"
        When I post to "/contributors" with:
        """
        {"code": "foo"}
        """
        Then the status code should be "400"

    Scenario: code is required
        When I post to "/contributors"
        """
        {"codewitherror": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'code' is a required property"

    Scenario: code is too short
        When I post to "/contributors"
        """
        {"code": ""}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "u'' is too short"

    Scenario: code is too long
        When I post to "/contributors"
        """
        {"code": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "u'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' is too long"

    Scenario: Code already exist
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | foo                | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/contributors"
        """
        {"code": "foo"}
        """
        Then the status code should be "409"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "Contributor with code 'foo' already exist"

    Scenario: creation of contributor
        When I post to "/contributor" with:
        """
        {"code": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "code" should be "foo"
