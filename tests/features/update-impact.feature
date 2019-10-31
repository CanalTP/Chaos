Feature: Update (put) impacts in a Disruption

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Contributors" with "contributor"

    Scenario: Update an impact in a disruption without contributor in the Header fails

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |priority|client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |0       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good      | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 0ffab232-3d48-4eea-aa2c-22f8680230b6 |1       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |0ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | created_at          | updated_at          | type    | id                                   | uri           |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | network:JDR:1 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | network:JDR:2 |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                         | impact_id                           |
            | 7ffab231-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        I remove header "X-Contributors"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-06-01T16:52:00Z","end": "2014-10-22T02:15:00Z"}, {"begin": "2014-06-29T16:52:00Z","end": "2014-11-22T02:15:00Z"}], "objects": [{"id": "network:JDR:1","type": "network"},{"id": "network:JDR:2","type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Contributors does not exist in the header"

    Scenario: Update an impact in a disruption with severity without client in the header fails

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |priority|client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |0       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good      | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 0ffab232-3d48-4eea-aa2c-22f8680230b6 |1       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |0ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | created_at          | updated_at          | type    | id                                   | uri           |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | network:JDR:1 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | network:JDR:2 |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                         | impact_id                           |
            | 7ffab231-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        I remove header "X-Customer-Id"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-06-01T16:52:00Z","end": "2014-10-22T02:15:00Z"}, {"begin": "2014-06-29T16:52:00Z","end": "2014-11-22T02:15:00Z"}], "objects": [{"id": "network:JDR:1","type": "network"},{"id": "network:JDR:2","type": "network"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Customer-Id does not exist in the header"

    Scenario: Update an impact in a disruption with severity of another client fails

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | 10            | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |priority|client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |0       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good      | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 0ffab232-3d48-4eea-aa2c-22f8680230b6 |1       |7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |0ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | created_at          | updated_at          | type    | id                                   | uri           |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | network:JDR:1 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | network:JDR:2 |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                         | impact_id                           |
            | 7ffab231-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "0ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-06-01T16:52:00Z","end": "2014-10-22T02:15:00Z"}, {"begin": "2014-06-29T16:52:00Z","end": "2014-11-22T02:15:00Z"}], "objects": [{"id": "network:JDR:1","type": "network"},{"id": "network:JDR:2","type": "network"}]}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"

    Scenario: Update an impact in a disruption with severity and application_periods in json

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |priority|client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |0       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good      | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 0ffab232-3d48-4eea-aa2c-22f8680230b6 |1       |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |0ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | created_at          | updated_at          | type    | id                                   | uri           |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | network:JDR:1 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | network:JDR:2 |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                         | impact_id                           |
            | 7ffab231-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Contributors" with "contrib1"
        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impacts" should have a size of 2
        And the field "impacts.0.objects" should have a size of 2
        And the field "impacts.1.application_periods" should have a size of 0
        And in the database for the impacts "7ffab232-3d47-4eea-aa2c-22f8680230b6" the field "version" should be "1"

        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "application_periods": [{"begin": "2014-06-01T16:52:00Z","end": "2014-10-22T02:15:00Z"}, {"begin": "2014-06-29T16:52:00Z","end": "2014-11-22T02:15:00Z"}], "objects": [{"id": "network:JDR:1","type": "network"},{"id": "network:JDR:2","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects.0.id" should be "network:JDR:1"
        And the field "impact.objects.1.id" should be "network:JDR:2"
        And the field "impact.application_periods" should have a size of 2
        And in the database for the impacts "7ffab232-3d47-4eea-aa2c-22f8680230b6" the field "version" should be "2"

    Scenario: Update an impact in a disruption with ptobject/application_periods and without severity in json

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_ id                             | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | created_at          | updated_at          | type    | id                                   | uri           |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | network:JDR:1 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | network | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | network:JDR:2 |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                         | impact_id                           |
            | 7ffab231-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Contributors" with "contrib1"
        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impacts" should have a size of 2
        And the field "impacts.0.severity.id" should be "7ffab232-3d48-4eea-aa2c-22f8680230b6"

        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"objects": [{"id": "network:TAD:1","type": "network"}, {"id": "network:default_network","type": "network"}], "application_periods": [{"begin": "2014-07-01T16:52:00Z","end": "2014-08-30T02:15:00Z"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'severity' is a required property"

    Scenario: Update an impact in a disruption with post 3 application_period and 2 application_periods in database

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods": [{"begin": "2014-01-01T16:52:00Z","end": "2014-01-07T16:52:00Z"},{"begin": "2014-01-20T16:52:00Z","end": "2014-01-30T16:52:00Z"},{"begin": "2014-01-20T16:52:00Z","end": "2014-02-20T16:52:00Z"}],"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.application_periods" should have a size of 3

    Scenario: Update an impact in a disruption with post 2 application_period and 2 application_periods in database

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods": [{"begin": "2014-01-20T16:52:00Z","end": "2014-01-30T16:52:00Z"},{"begin": "2014-01-20T16:52:00Z","end": "2014-02-20T16:52:00Z"}],"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.application_periods" should have a size of 2

    Scenario: Update an impact in a disruption with post 1 application_period and 2 application_periods in database

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods": [{"begin": "2014-01-20T16:52:00Z","end": "2014-02-20T16:52:00Z"}],"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.application_periods" should have a size of 1

    Scenario: Update an impact in a disruption with post 1 application_period and 2 application_periods in database

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.application_periods" should have a size of 1

    Scenario: Update an impact in a disruption with post 0 application_period and 2 application_periods in database fails

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should contain "is not valid under any of the given schemas"

    Scenario: Update impact with id not valid

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/AA-BB" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: Update impact with id not not in url

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "id invalid"

    Scenario: Update impact with id valid and impact not in database

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/5ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "404"

    Scenario: Modify severity of impact

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
                | good      | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01T16:52:00                  |2014-01-07T16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20T16:52:00                  |2014-01-30T16:52:00 |
        I fill in header "X-Contributors" with "contrib1"
        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "1ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods": [{"begin": "2014-01-20T16:52:00Z","end": "2014-02-20T16:52:00Z"}],"objects": [{"id": "network:JDR:1","type": "network"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.severity.id" should be "1ffab232-3d48-4eea-aa2c-22f8680230b6"

    Scenario: Verification version of disruption: POST impact

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |version    |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |1          |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        I fill in header "X-Contributors" with "contrib1"
        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "1"

        When I post to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "network:JDR:1","type": "network"},{"id": "stop_area:JDR:PTVIN","type": "stop_area"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"

        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "2"

    Scenario: Verification version of disruption: PUT impact

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |version    |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |1          |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Contributors" with "contrib1"
        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "1"

        When I put to "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity": {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}, "objects": [{"id": "network:JDR:1","type": "network"},{"id": "stop_area:JDR:PTVIN","type": "stop_area"}], "application_periods": [{"begin": "2014-04-29T16:52:00Z","end": "2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"

        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "2"

    Scenario: Verification version of disruption: DELETE impact

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     |cause_id                              | client_id                            | contributor_id                       |version    |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6a826e64-028f-11e4-92d0-090027079ff3 | 2014-04-20T23:52:12    | 2014-04-30T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |1          |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                         |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 6a826e64-028f-11e4-92d0-090027079ff3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        I fill in header "X-Contributors" with "contrib1"
        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "1"

        When I delete "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6":
        Then the status code should be "204"
        And the header "Content-Type" should be "application/json"

        When I get "/disruptions/6a826e64-028f-11e4-92d0-090027079ff3"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.version" should be "2"