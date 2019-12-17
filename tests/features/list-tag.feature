Feature: list tag

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Call without client in the header fails
        I clean header
        When I get "/tags"
        Then the status code should be "400"

    Scenario: if there is no tag the list is empty
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/tags"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        and "tags" should be empty

    Scenario: list of two tag
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/tags"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "tags" should have a size of 2
        And the field "tags.0.name" should be "weather"
        And the field "tags.1.name" should be "strike"

    Scenario: only visible tags have to be return
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | invisible | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/tags"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "tags" should have a size of 2
        And the field "tags.0.name" should be "weather"
        And the field "tags.1.name" should be "strike"

    Scenario: I can view one tag
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   |2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "5"
        When I get "/tags/7ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "tag.name" should be "weather"

    Scenario: I have a 400 if the id doesn't have the correct format
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   |2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/tags/7ffab230-3d48a-a2c-22f8680230b6"
        Then the status code should be "400"

    Scenario: if the tag on demand doesn't exist i have 404
        Given I have the following clients in my database:
        | client_code   | created_at          | updated_at          | id                                   |
        | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   |2014-04-02T23:52:12 | 2014-04-02T23:55:12 | False      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/tags/7ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
