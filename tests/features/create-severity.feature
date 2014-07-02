Feature: Create severity

    Scenario: wording is required
        When I post to "/severities"
        Then the status code should be "400"

    Scenario: creation of severity
        When I post to "/severities" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wording" should be "foo"
        And the field "severity.color" should be null

    Scenario: Severity are created
        Given I post to "/severities" with:
        """
        {"wording": "foo"}
        """
        When I get "/severities"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "severities" should have a size of 1
        And the field "severities.0.wording" should be "foo"
        And the field "severities.0.color" should be null

    Scenario: We can create a severity with a color
        When I post to "/severities" with:
        """
        {"wording": "foo", "color": "#123456"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wording" should be "foo"
        And the field "severity.color" should be "#123456"
