Feature: impacts with message meta

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: get impact
        Given I have the following client in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severity in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributor in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            
        Given I have the following cause in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruption in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | cause_id |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impact in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following meta in my database:
            | id                                   | key        | value      |
            | 55fab232-3d47-4eea-aa2c-22f8680230b6 | mailObject | Infotrafic |

        Given I have the following channel in my database:
            | name  | max_size | created_at          | updated_at          | content_type| id                                   | client_id                            |
            | email | 520      | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b7 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channel_type in my database:
            | name  | created_at          | updated_at          | id                                   | channel_id                           |
            | email | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b7 |

        Given I have the following message in my database:
            | text      | created_at          | updated_at | channel_id                           | id                                   | impact_id                            |
            | message 1 | 2014-04-02T23:52:12 | None       | 7ffab232-3d48-4eea-aa2c-22f8680230b7 | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_message_meta in my database:
            | message_id                           | meta_id                              |
            | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 55fab232-3d47-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impacts" should have a size of 1
        And the field "impacts.0.messages.0.meta" should have a size of 1
        And the field "impacts.0.messages.0.meta.0.key" should be "mailObject"
        And the field "impacts.0.messages.0.meta.0.value" should be "Infotrafic"
        
    Scenario: post impact
    
        Given I have the following client in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following cause in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributor in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruption in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             | client_id                            | contributor_id                       |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severity in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            
        Given I have the following channel in my database:
            | name  | max_size | created_at          | updated_at          | content_type| id                                   | client_id                            |
            | email | 520      | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | text/plain  | 7ffab232-3d48-4eea-aa2c-22f8680230b7 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following channel_type in my database:
            | name  | created_at          | updated_at          | id                                   | channel_id                           |
            | email | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 4ffbb230-3d48-4eea-aa2c-21f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b7 |

        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Contributors" with "contrib1"
        I fill in header "X-Coverage" with "jdr"
        I fill navitia authorization in header
        When I post to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3/impacts" with:
        """
        {"severity": {"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects":[{"id":"line:JDR:M1","type":"line"}],"messages":[{"text":"bodyMail","channel":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b7"},"meta":[{"key":"objectMail","value":"Traffic"}]}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"},{"begin": "2014-04-29T16:52:00Z","end": "2014-05-22T02:15:00Z"}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "impact.messages" should exist
        And the field "impact.messages.0.text" should be "bodyMail"
        And the field "impact.messages.0.meta" should exist
        And the field "impact.messages.0.meta" should have a size of 1
        And the field "impact.messages.0.meta.0.key" should be "objectMail"
        And the field "impact.messages.0.meta.0.value" should be "Traffic"
