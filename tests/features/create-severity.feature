Feature: Create severity

    Scenario: we cannot create severity without client
        When I post to "/severities" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"

    Scenario: wording is required
        I fill in header "X-Customer-Id" with "5"
        When I post to "/severities"
        Then the status code should be "400"


    Scenario: creation of severity
        I fill in header "X-Customer-Id" with "5"
        When I post to "/severities" with:
        """
        {"wording": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wording" should be "foo"
        And the field "severity.color" should be null

    Scenario: Severity are created
        I fill in header "X-Customer-Id" with "5"
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
        I fill in header "X-Customer-Id" with "5"
        When I post to "/severities" with:
        """
        {"wording": "foo", "color": "#123456"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wording" should be "foo"
        And the field "severity.color" should be "#123456"

    Scenario: We can create a severity with a priority
        I fill in header "X-Customer-Id" with "5"
        When I post to "/severities" with:
        """
        {"wording": "foo", "color": "#123456", "priority": 2, "effect": null}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wording" should be "foo"
        And the field "severity.color" should be "#123456"
        And the field "severity.priority" should be "2"
        And the field "severity.effect" should be null
        When I get "/severities"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "severities" should have a size of 1
        And the field "severities.0.priority" should be "2"

    Scenario: We can create a blocking severity
        I fill in header "X-Customer-Id" with "5"
        When I post to "/severities" with:
        """
        {"wording": "foo", "color": "#123456", "priority": 2, "effect": "blocking"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "severity.wording" should be "foo"
        And the field "severity.color" should be "#123456"
        And the field "severity.priority" should be "2"
        And the field "severity.effect" should be "blocking"

    Scenario: We can't create a severity with any effect
        When I post to "/severities" with:
        """
        {"wording": "foo", "color": "#123456", "priority": 2, "effect": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
