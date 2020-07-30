Feature: channel can be deleted

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: modify of one channel without client in the header fails
        I remove header "X-Customer-Id"
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type"}
        """
        Then the status code should be "400"

    Scenario: modify of one channel with client absent in database fails
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "6"
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type"}
        """
        Then the status code should be "404"

    Scenario: modify of one channel without channel type fails
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type"}
        """
        Then the status code should be "400"

    Scenario: modify of one channel
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            | required
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 | False
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 | False
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type", "types": ["web", "sms"], "required": true}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "channel.name" should be "foo"
        And the field "channel.max_size" should be 500
        And the field "channel.types.1" should be "sms"
        And the field "channel.required" should be "True"

    Scenario: modify of one channel by id invalid
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/AA" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: modify of one channel not exist in database
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b2" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type"}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"

    Scenario: modify of one channel without name
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"max_size": 500, "content_type": "text/type"}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'name' is a required property"

    Scenario: modification of one channel with duplicate channel types fails
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type", "types": ["web", "web"}]}
        """
        Then the status code should be "400"

    Scenario: modification of one channel with wrong channel type fails
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                            |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | email  | 520        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        When I put "/channels/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"name": "foo", "max_size": 500, "content_type": "text/type", "types": ["web", "wev"]}
        """
        Then the status code should be "400"
