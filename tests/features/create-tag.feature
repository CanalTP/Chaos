Feature: Create tag

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"

    Scenario: we cannot create tag  without client in the header
        I remove header "X-Customer-Id"
        When I post to "/tags" with:
        """
        {"name": "foo"}
        """
        Then the status code should be "400"

    Scenario: name is required
        When I post to "/tags"
        """
        {"nameaa": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'name' is a required property"

    Scenario: creation of tag
        When I post to "/tags" with:
        """
        {"name": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "tag.name" should be "foo"

    Scenario: creation of tag with client present in database
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/tags" with:
        """
        {"name": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "tag.name" should be "foo"

    Scenario: Tag are created
        Given I post to "/tags" with:
        """
        {"name": "foo"}
        """
        When I get "/tags"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "tags" should have a size of 1
        And the field "tags.0.name" should be "foo"

    Scenario: We don't accept two tags with the same name
        Given I post to "/tags" with:
        """
        {"name": "foo"}
        """
        Given I post to "/tags" with:
        """
        {"name": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

    Scenario: We activate the archived tag if want to create with the same name and client
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following tags in my database:
            | name   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | foo    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | weather| 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/tags/7ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "404"
        Given I post to "/tags" with:
        """
        {"name": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "tag.name" should be "foo"

        When I get "/tags/7ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "tag.name" should be "foo"
