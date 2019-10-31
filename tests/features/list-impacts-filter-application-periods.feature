Feature: list impacts by application periods

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"
#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#  TEST1
#  +------+
#

    Scenario: TEST1
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2013-12-01T23:52:12Z&end_date=2013-12-20T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 0

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                   TEST2
#               +----------------+
#

    Scenario: TEST2
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2013-12-01T23:52:12Z&end_date=2014-01-02T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.id" should be "network:JDR:1"
        And the field "objects.0.impacts" should have a size of 1

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                   TEST3
#               +---------------------------------------+
#

    Scenario: TEST3
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2013-12-01T23:52:12Z&end_date=2014-01-08T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.id" should be "network:JDR:1"
        And the field "objects.0.impacts" should have a size of 1

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                                        TEST4
#                                       +-----+
#

    Scenario: TEST4
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2014-01-02T23:52:12Z&end_date=2014-01-06T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.id" should be "network:JDR:1"
        And the field "objects.0.impacts" should have a size of 1

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                                                       TEST5
#                                                       +--+
#

    Scenario: TEST5
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2014-01-08T23:52:12Z&end_date=2014-01-09T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 0

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                                                                  TEST6
#                                                                  +-----+
#

    Scenario: TEST6
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2014-01-11T23:52:12Z&end_date=2014-01-13T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.id" should be "network:JDR:2"
        And the field "objects.0.impacts" should have a size of 1

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                                                                  TEST7
#                                             +-----------------------------------------------------+
#

    Scenario: TEST7
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | stop_area | stop_area:JDR:AGNET | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:BARBE | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=stop_area&start_date=2014-01-02T23:52:12Z&end_date=2014-01-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 2
        And the field "objects.0.id" should be "stop_area:JDR:BARBE"
        And the field "objects.0.impacts" should have a size of 1
        And the field "objects.1.id" should be "stop_area:JDR:AGNET"
        And the field "objects.1.impacts" should have a size of 1

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                                                                  TEST8
#                   +---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#

    Scenario: TEST8
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | stop_area | stop_area:JDR:AGNET | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:BARBE | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=stop_area&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 2
        And the field "objects.0.id" should be "stop_area:JDR:BARBE"
        And the field "objects.0.impacts" should have a size of 1
        And the field "objects.1.id" should be "stop_area:JDR:AGNET"
        And the field "objects.1.impacts" should have a size of 1

#
#  network:JDR:1|         01-01-2014
#               |             +--------------------------------------------------------------------------------------------------------------..........
#               |
#
#
#               |                                        10-01-2014        19-01-2014                               01-02-2014        18-02-2014
#               |                                            +-----------------+                                        +-----------------+
#  network:JDR:2|
#               |
#
#
#
#                                   TEST9
#           +-----------------------------------------------------------+
#

    Scenario: TEST9
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00                  |None                |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-10 16:52:00                  |2014-01-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-01 16:52:00                  |2014-02-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        When I get "/impacts?pt_object_type=network&start_date=2013-12-02T23:52:12Z&end_date=2014-01-12T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1

#
#               |                                                                20-01-2014                  30-01-2014
#               |                                                                    +---------------------------+
#  network:JDR:1|         01-01-2014              07-01-2014                                                                                      20-02-2014                  15-03-2014
#               |             +-----------------------+                                                                                               +----------------------------+
#               |                   04-01-2014              09-01-2014                                                                                      23-02-2014                  18-03-2014
#               |                   +-----------------------+                                                                                               +----------------------------+
#               |
#
#                                                                  TEST10
#                   +---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#

    Scenario: TEST10
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
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-01 16:52:00                  |2014-01-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-02-20 16:52:00                  |2014-03-15 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |2014-01-04 16:52:00                  |2014-01-09 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |2014-02-23 16:52:00                  |2014-03-18 16:52:00 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b2       |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b3       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b2       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b3       | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |

        When I get "/impacts?pt_object_type=network&start_date=2013-12-02T23:52:12Z&end_date=2014-05-21T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "objects" should have a size of 1
        And the field "objects.0.id" should be "network:JDR:1"
        And the field "objects.0.impacts" should have a size of 3
        And the field "objects.0.impacts.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b2"
        And the field "objects.0.impacts.1.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b3"
        And the field "objects.0.impacts.2.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
