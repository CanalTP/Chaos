Feature: Create category

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header

    Scenario: we cannot create a categories without client
        I remove header "X-Customer-Id"
        When I post to "/categories"
        """
        {"name": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

    Scenario: name is required

        When I post to "/categories"
        """
        {"wording": "foo"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'name' is a required property"

    Scenario: creation of category
        When I post to "/categories" with:
        """
        {"name": "foo"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "category.name" should be "foo"

    Scenario: Category are created
        Given I post to "/categories" with:
        """
        {"name": "foo"}
        """
        When I get "/categories"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "categories" should have a size of 1
        And the field "categories.0.name" should be "foo"

    Scenario: Create category when X-Customer-Id in database
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I post to "/categories" with:
        """
        {"name": "foo"}
        """
        When I get "/categories"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "categories" should have a size of 1
        And the field "categories.0.name" should be "foo"

    Scenario: Create category when X-Customer-Id in database and category in database (visible)
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I post to "/categories" with:
        """
        {"name": "weather"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

    Scenario: Create category when X-Customer-Id in database and category in database (not visible)
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I post to "/categories" with:
        """
        {"name": "weather"}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"

        When I get "/categories"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "categories" should have a size of 1
        And the field "categories.0.name" should be "weather"
