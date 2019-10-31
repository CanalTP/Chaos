Feature: list impacts by ptobject

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Use ptobject 'stop_point' filter to display impacts
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type          | uri                       | created_at          | updated_at          | id                                         |
            | stop_point    | stop_point:JDR:ABBES2  | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network       | network:JDR:1             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network       | network:JDR:1             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network       | network:JDR:2             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network       | network:JDR:2             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network       | network:JDR:2             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 6ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area     | stop_area:JDR:CHVIN    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 4ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 5ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |
            | 6ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=stop_point&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.impacts" should have a size of 1
        And the field "objects.0.type" should be "stop_point"
        And the field "objects.0.id" should be "stop_point:JDR:ABBES2"

    Scenario: Use ptobject 'network' filter to display impacts
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 6ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 4ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 5ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |
            | 6ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |


        When I get "/impacts?pt_object_type=network&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 2
        And the field "objects.0.impacts" should have a size of 3
        And the field "objects.1.impacts" should have a size of 3

    Scenario: Use ptobject 'stop_area' filter to display impacts
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 6ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 4ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 5ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |
            | 6ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=stop_area&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.impacts" should have a size of 1

    Scenario: Use ptobject 'line' filter to display impacts
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 6ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line      | line:JDR:M1            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 8ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 4ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 5ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |
            | 6ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 8ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=line&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.impacts" should have a size of 1
        And the field "objects.0.id" should be "line:JDR:M1"

    Scenario: Use ptobject 'stop_area' filter to display impacts (sort ptobject by name)
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type        | uri                             | created_at          | updated_at          | id                                         |
            | stop_area   | stop_area:JDR:BASTI          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:GDLYO          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:REUIL          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:NATIO          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:STMAN          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:BERAU          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 6ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:CHVIN          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 4ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 5ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |
            | 6ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=stop_area&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 7
        And the field "objects.0.id" should be "stop_area:JDR:BASTI"
        And the field "objects.0.name" should be "Bastille"

        And the field "objects.1.id" should be "stop_area:JDR:BERAU"
        And the field "objects.1.name" should be "Bérault"

        And the field "objects.2.id" should be "stop_area:JDR:CHVIN"
        And the field "objects.2.name" should be "Château de Vincennes"

        And the field "objects.3.id" should be "stop_area:JDR:GDLYO"
        And the field "objects.3.name" should be "Gare de Lyon"

        And the field "objects.4.id" should be "stop_area:JDR:NATIO"
        And the field "objects.4.name" should be "Nation"

        And the field "objects.5.id" should be "stop_area:JDR:REUIL"
        And the field "objects.5.name" should be "Reuilly - Diderot"

        And the field "objects.6.id" should be "stop_area:JDR:STMAN"
        And the field "objects.6.name" should be "Saint-Mandé"

    Scenario: archived disruption must not been shown
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | bar       |       | 2014-04-02T13:52:12 | 2014-04-02T23:55:12 | archived  | 8c32b230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T13:52:12 | 2014-04-06T22:52:12 | archived  | 9c32b234-3d49-4eec-aa2c-22f8680230b4 | 8c32b230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 6ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 4ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 5ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |
            | 6ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 9c32b234-3d49-4eec-aa2c-22f8680230b4 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab234-3d49-4eec-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |874ab232-3d47-4eea-aa2c-22f8680230b6 | 9c32b234-3d49-4eec-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=network&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 2
        And the field "objects.0.impacts" should have a size of 3
        And the field "objects.1.impacts" should have a size of 3

    Scenario: Use ptobject 'line_section' filter to display impacts (sort ptobject by name)
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type        | uri                             | created_at          | updated_at          | id                                         |
            | stop_area   | stop_area:JDR:BASTI          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:CHVIN          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section| line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line        | line:JDR:M1| 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab200-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id|sens|object_id|
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 7ffab200-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|0|7ffab232-3d48-4eea-aa2c-22f8680230b6|

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab200-3d48-4eea-aa2c-22f8680230b6          | 6ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=line_section&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.type" should be "line_section"
        And the field "objects.0.id" should be "line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6"
        And the field "objects.0.impacts.0.objects" should have a size of 2

    Scenario: Use ptobject 'line_section' filter to display impacts with line_section and routes (sort ptobject by name)
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type        | uri                             | created_at          | updated_at          | id                                         |
            | stop_area   | stop_area:JDR:BASTI          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:CHVIN          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section| line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line        | line:JDR:M1| 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab200-3d48-4eea-aa2c-22f8680230b6       |
            | route        | route:JDR:M14| 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 8ffab200-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id|sens|object_id|
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 7ffab200-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|0|7ffab232-3d48-4eea-aa2c-22f8680230b6|

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab200-3d48-4eea-aa2c-22f8680230b6          | 6ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_line_section_route_object in my database:
            | route_object_id                               | line_section_id                      |
            | 8ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=line_section&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.type" should be "line_section"
        And the field "objects.0.id" should be "line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6"
        And the field "objects.0.impacts.0.objects" should have a size of 2

    Scenario: Use ptobject 'line_section' filter to display impacts with line_section with routes and via (sort ptobject by name)
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 6ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type        | uri                             | created_at          | updated_at          | id                                         |
            | stop_area   | stop_area:JDR:BASTI          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area   | stop_area:JDR:CHVIN          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section| line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line        | line:JDR:M1| 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab200-3d48-4eea-aa2c-22f8680230b6       |
            | route        | route:JDR:M14| 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 8ffab200-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id|sens|object_id|
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 7ffab200-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|0|7ffab232-3d48-4eea-aa2c-22f8680230b6|

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 7ffab200-3d48-4eea-aa2c-22f8680230b6          | 6ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_line_section_route_object in my database:
            | route_object_id                               | line_section_id                      |
            | 8ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_line_section_via_object in my database:
            | stop_area_object_id                               | line_section_id                      |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6              | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |1ffab232-3d47-4eea-aa2c-22f8680230b1 | 6ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/impacts?pt_object_type=line_section&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.type" should be "line_section"
        And the field "objects.0.id" should be "line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6"
        And the field "objects.0.impacts.0.objects" should have a size of 2

    Scenario: Filter on type (pt_object_type) of an object in line_section to display impacts
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:BASTI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:CHVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line         | line:JDR:M1                                      | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | route        | route:JDR:M14                                    | 2014-04-06T22:52:12 | 5ffab200-3d48-4eea-aa2c-22f8680230b6       |
            | route        | route:JDR:M1_R                                   | 2014-04-06T22:52:12 | 6ffab200-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:NATIO                           | 2014-04-04T23:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:REUIL                           | 2014-04-04T23:52:12 | 8ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:TAD:CanalTP                              | 2014-04-04T23:52:12 | 9ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id|sens|object_id|
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 4ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|0|3ffab232-3d48-4eea-aa2c-22f8680230b6|

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_line_section_route_object in my database:
            | route_object_id                               | line_section_id                      |
            | 5ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |
            | 6ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_line_section_via_object in my database:
            | stop_area_object_id                           | line_section_id                      |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |
            | 8ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        #Fetch impact by type of object in start_point, end_point and line of line_section
        When I get "/impacts?pt_object_type=stop_area&start_date=2013-12-02T23:52:12Z&end_date=2014-10-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.impacts" should have a size of 1
        And the field "objects.0.impacts.0.objects.0.type" should be "line_section"
        And the field "objects.0.impacts.0.objects.0.line_section.start_point.type" should be "stop_area"
        And the field "objects.0.impacts.0.objects.0.line_section.start_point.id" should be "stop_area:JDR:BASTI"

        #Fetch impact by type of object in start_point, end_point and line of line_section
        When I get "/impacts?pt_object_type=network&start_date=2013-12-02T23:52:12Z&end_date=2014-10-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 0
