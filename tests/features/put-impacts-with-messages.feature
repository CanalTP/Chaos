Feature: Manipulate messages in a impact

    Scenario: Add an message in a impact (1 message)

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

       Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 1","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}], "objects": [{"id": "network:JDR:2","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 1
        And the field "impact.messages.0.text" should be "message 1"
        And the field "impact.messages.0.updated_at" should be null

    Scenario: Put message in a impact (1 message)

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

       Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |

            Given I have the following messages in my database:
            | text       |  created_at          | updated_at          | channel_id                            | id                                   |
            | message 1  |  2014-04-02T23:52:12 | None                | 4ffab230-3d48-4eea-aa2c-22f8680230b6  | 5ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 2","channel": {"id": "4ffab230-3d48-4eea-aa2c-22f8680230b6"}}], "objects": [{"id": "network:JDR:2","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 1
        And the field "impact.messages.0.text" should be "message 2"
        And the field "impact.messages.0.updated_at" should be not null

    Scenario: add message in a impact (2 messages)

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

       Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            Given I have the following channels in my database:
            | name   | max_size   | created_at          | updated_at          | content_type| id                                   |
            | short  | 140        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/plain  | 4ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | short  | 60         | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | text/sms    | 8ffab230-3d48-4eea-aa2c-22f8680230b6 |

            Given I have the following messages in my database:
            | text       |  created_at          | updated_at          | channel_id                            | id                                   |impact_id                           |
            | message 1  |  2014-04-02T23:52:12 | None                | 4ffab230-3d48-4eea-aa2c-22f8680230b6  | 5ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6|

       When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}, "messages": [{"text": "message 2","channel": {"id": "8ffab230-3d48-4eea-aa2c-22f8680230b6"}}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should have a size of 2
