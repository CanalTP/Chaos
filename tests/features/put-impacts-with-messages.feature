Feature: Manipulate messages in a impact

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Add an message in a impact (1 message)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                             |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channel_type in my database:
            | name   | created_at          | updated_at          | id                                   | channel_id                           |
            | web    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b6 | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"messages": [{"text": "message 1","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 1
        And the field "impact.messages.0.text" should be "message 1"
        And the field "impact.messages.0.updated_at" should be null
        And the field "impact.messages.0.channel.id" should be "4ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "impact.messages.0.channel.types.0" should be "web"

    Scenario: Put message in a impact (1 message)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                             |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channel_type in my database:
            | name   | created_at          | updated_at          | id                                   | channel_id                           |
            | web    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b6 | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following messages in my database:
            | text       |  created_at          | updated_at          | channel_id                            | id                                   | impact_id                            |
            | message 1  |  2014-04-02T23:52:12 | None                | 4ffab230-3d48-4eea-aa2c-22f8680230b6  | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 2","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}], "objects": [{"id": "network:JDR:1","type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 1
        And the field "impact.messages.0.text" should be "message 2"
        And the field "impact.messages.0.updated_at" should be not null
        And the field "impact.messages.0.channel.types.0" should be "web"

    Scenario: add message in a impact (2 messages)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                             |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | short  | 60         | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/sms    | 8ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channel_type in my database:
            | name   | created_at          | updated_at          | id                                   | channel_id                           |
            | web    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b6 | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | mobile | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b7 | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following messages in my database:
            | text       |  created_at          | updated_at          | channel_id                            | id                                   |impact_id                           |
            | message 1  |  2014-04-02T23:52:12 | None                | 4ffab230-3d48-4eea-aa2c-22f8680230b6  | 5ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6|

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"messages": [{"text": "message 2","channel": {"id": "8ffab230-3d48-4eea-aa2c-22f8680230b6"}},{"text": "message 1","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 2
        And the field "impact.messages" should have "channel" with "{"id": "8ffab230-3d48-4eea-aa2c-22f8680230b6", "name": "short", "types": []}"
        And the field "impact.messages" should have "channel" with "{"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6", "name": "short", "types": ["web", "mobile"]}"

    Scenario: delete one message in a impact (2 messages)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |client_id                             |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | short  | 60         | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/sms    | 8ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channel_type in my database:
            | name   | created_at          | updated_at          | id                                   | channel_id                           |
            | web    | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b6 | 8ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | mobile | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b7 | 8ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following messages in my database:
            | text       |  created_at          | updated_at          | channel_id                            | id                                   |impact_id                           |
            | message 1  |  2014-04-02T23:52:12 | None                | 4ffab230-3d48-4eea-aa2c-22f8680230b6  | 5ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6|
            | message 2  |  2014-04-02T23:52:12 | None                | 8ffab230-3d48-4eea-aa2c-22f8680230b6  | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6|

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}],"messages" : [{"text": "message 2","channel": {"id": "8ffab230-3d48-4eea-aa2c-22f8680230b6"}}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 1
        And the field "impact.messages.0.text" should be "message 2"
        And the field "impact.messages.0.channel.id" should be "8ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "impact.messages.0.channel.types.0" should be "web"
        And the field "impact.messages.0.channel.types.1" should be "mobile"
