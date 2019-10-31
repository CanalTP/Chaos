Feature: update disruption

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

   Scenario: update disruption without contributor in the header

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        I remove header "X-Contributors"
        When I put to "/disruptions/AA-BB" with:
        """
        {"reference":"foobarz","contributor": "contrib1", "publication_period": {"begin":"2014-06-24T13:35:00Z","end":"2014-07-08T18:00:00Z"}, "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Contributors does not exist in the header"

   Scenario: update disruption with id not valid

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/AA-BB" with:
        """
        {"reference":"foobarz","contributor": "contrib1", "publication_period": {"begin":"2014-06-24T13:35:00Z","end":"2014-07-08T18:00:00Z"}, "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

   Scenario: update disruption with id not not in url

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions" with:
        """
        {"reference":"foobarz","contributor": "contrib1", "publication_period": {"begin":"2014-06-24T13:35:00Z","end":"2014-07-08T18:00:00Z"}, "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

        When I put to "/disruptions/" with:
        """
        {"reference":"foobarz","contributor": "contrib1", "publication_period": {"begin":"2014-06-24T13:35:00Z","end":"2014-07-08T18:00:00Z"}, "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

   Scenario: update disruption with localization not in navitia

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foobarz","contributor": "contrib1","publication_period": {"begin": "2014-06-24T13:35:00Z","end": "2014-07-08T18:00:00Z"},"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"localization": [{"id": "AA","type": "stop_area"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "ptobject AA doesn't exist"

   Scenario: update disruption without contributor

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference":"foobarz", "publication_period": {"begin":"2014-06-24T13:35:00Z","end":"2014-07-08T18:00:00Z"}, "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'contributor' is a required property"

   Scenario: update disruption without reference

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"contributor": "contrib1", "publication_period": {"begin":"2014-06-24T13:35:00Z","end":"2014-07-08T18:00:00Z"}, "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'reference' is a required property"

   Scenario: I can update the wording of a cause

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foobarz","contributor": "contrib1","publication_period": {"begin": "2014-06-24T13:35:00Z","end": "2014-07-08T18:00:00Z"},"cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.publication_period.begin" should be "2014-06-24T13:35:00Z"
        And the field "disruption.publication_period.end" should be "2014-07-08T18:00:00Z"

   Scenario: I can update with tag and associate_disruption_tag is empty

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foobarz","contributor": "contrib1","cause": {"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"tags": [{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 1
        And the field "disruption.tags.0.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruption.tags.0.name" should be "weather"

   Scenario: I can update with add tag and associate_disruption_tag is not empty (1 associate_disruption_tag)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "5ffab230-3d48-4eea-aa2c-22f8680230b6"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 1

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "5ffab230-3d48-4eea-aa2c-22f8680230b6"}, {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 2

   Scenario: I can update with delete tag and associate_disruption_tag is not empty (2 associate_disruption_tag)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "5ffab230-3d48-4eea-aa2c-22f8680230b6"}, {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 2

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "5ffab230-3d48-4eea-aa2c-22f8680230b6"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 1
        And the field "disruption.tags.0.id" should be "5ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruption.tags.0.name" should be "weather"

   Scenario: I can update with delete 2 tags and associate_disruption_tag is not empty (2 associate_disruption_tag)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 5ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "5ffab230-3d48-4eea-aa2c-22f8680230b6"}, {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 2

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should have a size of 0

        When I get "/tags"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "tags" should have a size of 2

   Scenario: I can update, verification version

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |version|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |1|

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "2"

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "3"

   Scenario: I can update with add 1 localization and associate_disruption_tag is empty

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "localization":[{"id": "stop_area:JDR:PTVIN", "type": "stop_area"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should have a size of 1

   Scenario: I can update with add 2 localization and associate_disruption_tag is empty

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "localization":[{"id": "stop_area:JDR:PTVIN", "type": "stop_area"}, {"id": "stop_area:JDR:ALESI", "type": "stop_area"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should have a size of 2

   Scenario: I can update with add 2 localization and associate_disruption_tag is not empty (2 element)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:ALESI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:PTVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_disruption_pt_object in my database:
            | pt_object_id                                  | disruption_id                        |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "localization":[{"id": "stop_area:JDR:PTVIN", "type": "stop_area"}, {"id": "stop_area:JDR:ALESI", "type": "stop_area"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should have a size of 2

   Scenario: I can update with add 1 localization and associate_disruption_tag is not empty (2 element)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:ALESI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:PTVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_disruption_pt_object in my database:
            | pt_object_id                                  | disruption_id                        |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "localization":[{"id": "stop_area:JDR:ALESI", "type": "stop_area"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should have a size of 1
        And the field "disruption.localization.0.id" should be "stop_area:JDR:ALESI"

   Scenario: I can update with add 0 localization and associate_disruption_tag is not empty (2 element)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:ALESI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:PTVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_disruption_pt_object in my database:
            | pt_object_id                                  | disruption_id                        |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should have a size of 0

   Scenario: I can update with add 2 localization and associate_disruption_tag is not empty (1 element)

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date |cause_id                              | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | None                   | None                 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:PTVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_disruption_pt_object in my database:
            | pt_object_id                                  | disruption_id                        |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6          | a750994c-01fe-11e4-b4fb-080027079ff3 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
        """
        {"reference":"foobarz", "contributor": "contrib1", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "localization":[{"id": "stop_area:JDR:PTVIN", "type": "stop_area"}, {"id": "stop_area:JDR:ALESI", "type": "stop_area"}],"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should have a size of 2

    Scenario: Update a 'draft' disruption without explicit status doesn't change it
        Given I have the following clients in my database:
            | client_code | created_at          | updated_at          | id                                   |
            | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code | created_at          | id                                   |
            | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording | created_at          | is_visible | id                                   | client_id                            |
            | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | status | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | draft  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Contributors" with "contributor"
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "bar", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.reference" should be "bar"
        And the field "disruption.status" should be "draft"

    Scenario: Update a 'published' disruption without explicit status doesn't change it
        Given I have the following clients in my database:
            | client_code | created_at          | updated_at          | id                                   |
            | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code | created_at          | id                                   |
            | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording | created_at          | is_visible | id                                   | client_id                            |
            | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | status     | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Contributors" with "contributor"
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "bar", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.reference" should be "bar"
        And the field "disruption.status" should be "published"

    Scenario: Update a 'draft' disruption to 'published'
        Given I have the following clients in my database:
            | client_code | created_at          | updated_at          | id                                   |
            | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code | created_at          | id                                   |
            | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording | created_at          | is_visible | id                                   | client_id                            |
            | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | status | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | draft  | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Contributors" with "contributor"
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "status": "published","publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.status" should be "published"

    Scenario: Update a 'published' disruption to 'draft' is forbidden
        Given I have the following clients in my database:
            | client_code | created_at          | updated_at          | id                                   |
            | test        | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following contributors in my database:
            | contributor_code | created_at          | id                                   |
            | contributor      | 2014-04-02T23:52:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording | created_at          | is_visible | id                                   | client_id                            |
            | weather | 2014-04-02T23:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following disruptions in my database:
            | reference | note  | created_at          | status    | id                                   | cause_id                              | client_id                           | contributor_id                       |
            | foo       | hi    | 2014-04-02T23:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Customer-Id" with "test"
        I fill in header "X-Contributors" with "contributor"
        When I put to "/disruptions/2ffab230-3d48-4eea-aa2c-22f8680230b6" with:
        """
        {"reference": "foo", "contributor": "contributor", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "status": "draft","publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts": [{"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}],"application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}]}
        """
        Then the status code should be "409"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The current disruption is already published and cannot get back to the 'draft' status."
