Feature: list disruptions with ptObjects filter

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Filter on network no return

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-18 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-04-10 16:52:00                  |2014-04-18 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 0

    Scenario: Filter on network with empty publication_status

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": [], "ptObjectFilter": {"networks": ["network:JDR:1"]}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "publication_status should not be empty"

    Scenario: Filter on network with empty status

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "status": [], "ptObjectFilter": {"networks": ["network:JDR:1"]}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "status should not be empty"

    Scenario: Filter on network

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-11 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-04-12 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |2014-04-11 16:52:00                  |2014-04-30 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

    Scenario: Filter on network and stop_area

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b7 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab234-3d49-4eec-aa2c-22f8680230b4 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b8 | 7ffab234-3d49-4eec-aa2c-22f8680230b7 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"], "stop_areas": ["stop_area:JDR:CHVIN"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2

    Scenario: Filter on network return 2 disruptions

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-18 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-20T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1", "network:JDR:2"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2

    Scenario: Filter on line

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:BASTI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:CHVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line         | line:JDR:M1                                      | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:TAD:1                              | 2014-04-04T23:52:12 | 9ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id|
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 4ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|

        Given I have the following wording in my database:
            | key       | value     | created_at          | updated_at          | id                                   |
            |  key1     | 1234      | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            |  key2     | 235       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_wording_line_section in my database:
            | wording_id                                | line_section_id                       |
            |  7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab234-3d49-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab234-3d49-4eea-aa2c-22f8680230b6  |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 9ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:TAD:1"], "lines": ["line:JDR:M1"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

    Scenario: Filter on line no result

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:BASTI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:CHVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line         | line:JDR:M1                                      | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:TAD:1                              | 2014-04-04T23:52:12 | 9ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id                           |
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 4ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|

        Given I have the following wording in my database:
            | key       | value     | created_at          | updated_at          | id                                   |
            |  key1     | 1234      | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            |  key2     | 235       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_wording_line_section in my database:
            | wording_id                                | line_section_id                       |
            |  7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab234-3d49-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab234-3d49-4eea-aa2c-22f8680230b6  |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 9ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-20 16:52:00                  |2014-04-30 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-12T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M2"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 0

    Scenario: Use pager and filter network

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-30T23:42:00  |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-30T23:42:00  |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-30T23:42:00  |
            | chien     |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-30T23:42:00  |
            | clown     |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-30T23:42:00  |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   | client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1ffab232-3d47-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3ffab232-3d47-4eea-aa2c-22f8680230b6 | 3ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 4ffab232-3d47-4eea-aa2c-22f8680230b6 | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 5ffab232-3d47-4eea-aa2c-22f8680230b6 | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri           | created_at          | id                                         |
            | network      | network:JDR:1 | 2014-04-04T23:52:12 | 1ffab234-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:JDR:2 | 2014-04-04T23:52:12 | 2ffab234-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 1ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 2ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab234-3d48-4eea-aa2c-22f8680230b6          | 3ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 4ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 5ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          | id                                   | impact_id                            | start_date          | end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab230-3d47-4eea-aa2c-22f8680230b1 | 1ffab232-3d47-4eea-aa2c-22f8680230b6 | 2014-04-10 16:52:00 | 2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab230-3d47-4eea-aa2c-22f8680230b1 | 2ffab232-3d47-4eea-aa2c-22f8680230b6 | 2014-04-10 16:52:00 | 2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab230-3d47-4eea-aa2c-22f8680230b1 | 3ffab232-3d47-4eea-aa2c-22f8680230b6 | 2014-04-10 16:52:00 | 2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 4ffab230-3d47-4eea-aa2c-22f8680230b1 | 4ffab232-3d47-4eea-aa2c-22f8680230b6 | 2014-04-10 16:52:00 | 2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 5ffab230-3d47-4eea-aa2c-22f8680230b1 | 5ffab232-3d47-4eea-aa2c-22f8680230b6 | 2014-04-10 16:52:00 | 2014-04-30 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}, "start_page": 1, "items_per_page": 3}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 3
        And the field "meta" should exist
        And the field "meta.pagination.items_per_page" should be 3
        And the field "meta.pagination.items_on_page" should be 3
        And the field "meta.pagination.start_page" should be 1
        And the field "meta.pagination.total_result" should be 4

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}, "start_page": 0, "items_per_page": 3}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "page_index argument value is not valid"

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}, "start_page": -1, "items_per_page": 3}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "page_index argument value is not valid"

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}, "start_page": 1, "items_per_page": 0}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 0
        And the field "meta" should exist

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}, "start_page": 1, "items_per_page": -3}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "items_per_page argument value is not valid"

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"networks": ["network:JDR:1"]}, "start_page": 1, "items_per_page": 1001}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "items_per_page argument value can't be superior than 1000"

    Scenario: Test if about body when ptObjectFilter is not added
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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                              | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | chien     |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | clown     |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   | client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1ffab232-3d47-4eea-aa2c-22f8680230b6 | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3ffab232-3d47-4eea-aa2c-22f8680230b6 | 3ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 4ffab232-3d47-4eea-aa2c-22f8680230b6 | 4ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 5ffab232-3d47-4eea-aa2c-22f8680230b6 | 5ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri           | created_at          | id                                         |
            | network      | network:JDR:1 | 2014-04-04T23:52:12 | 1ffab234-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:JDR:2 | 2014-04-04T23:52:12 | 2ffab234-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 1ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 2ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab234-3d48-4eea-aa2c-22f8680230b6          | 3ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 4ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab234-3d48-4eea-aa2c-22f8680230b6          | 5ffab232-3d47-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions/_search" with:
        """
        {}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should exist
        And the field "disruptions" should have a size of 5
        And the field "meta" should exist
        And the field "meta.pagination.items_per_page" should be 20
        And the field "meta.pagination.items_on_page" should be 5
        And the field "meta.pagination.start_page" should be 1
        And the field "meta.pagination.total_result" should be 5

    Scenario: Test errors about body when ptObjectFilter is empty
        When I post to "/disruptions/_search" with:
        """
        {"ptObjectFilter": {}}
        """
        Then the status code should be "404"
        And the header "Content-Type" should be "application/json"

    Scenario: Filter on stop_area

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date | cause_id                             |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  | 7ffab230-3d48-4eea-aa2c-22f868023042 |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b7 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab234-3d49-4eec-aa2c-22f8680230b5 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b8 | 7ffab234-3d49-4eec-aa2c-22f8680230b7 |2014-04-10 16:52:00                  |2014-04-30 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"stop_areas": ["stop_area:JDR:CHVIN"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

    Scenario: Filter on line section

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:BASTI                           | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:CHVIN                           | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line         | line:JDR:M1                                      | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:TAD:1                              | 2014-04-04T23:52:12 | 9ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following line_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id                             |
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 4ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6  |

        Given I have the following wording in my database:
            | key       | value     | created_at          | updated_at          | id                                   |
            |  key1     | 1234      | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            |  key2     | 235       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_wording_line_section in my database:
            | wording_id                                | line_section_id                       |
            |  7ffab230-3d48-4eea-aa2c-22f8680230b6     | 7ffab234-3d49-4eea-aa2c-22f8680230b6  |
            |  7ffab232-3d48-4eea-aa2c-22f8680230b6     | 7ffab234-3d49-4eea-aa2c-22f8680230b6  |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |

        # string accepted as boolean
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}, "line_section": "true"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

        # boolean
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}, "line_section": true}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

        # int accepted as boolean
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}, "line_section": 1}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
@test
    Scenario: Filter on rail section

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type         | uri                                              | created_at          | id                                         |
            | stop_area    | stop_area:JDR:BASTI                              | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | stop_area    | stop_area:JDR:CHVIN                              | 2014-04-04T23:52:12 | 2ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | rail_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line         | line:JDR:M1                                      | 2014-04-06T22:52:12 | 4ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network      | network:TAD:1                                    | 2014-04-04T23:52:12 | 9ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following rail_section in my database:
            | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id                       |blocked_stop_areas                                                                                |object_id                             |
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 4ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|'[{"id": "stop_area:DUA:SA:8775810", "order": 1}, {"id": "stop_area:DUA:SA:8768603", "order": 2}]'|3ffab232-3d48-4eea-aa2c-22f8680230b6  |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |

        # string accepted as boolean
        # When I post to "/disruptions/_search" with:
        # """
        # {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}, "rail_section": "true"}
        #"""
        # Then the status code should be "200"
        # And the header "Content-Type" should be "application/json"
        # And the field "disruptions" should have a size of 1

        # boolean
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}, "rail_section": true}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

        # int accepted as boolean
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}, "rail_section": 1}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

    Scenario: Filter on category
        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following categories in my database:
            | name      | note  | created_at          | updated_at          | id                                   | client_id                            |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | goo       | helio | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   |  created_at          | updated_at          | is_visible | category_id                          | id                                   | client_id                            |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab234-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | nuke      |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab231-3d48-4eea-aa2c-22f8680230b6 | 7ffab233-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   | client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b7 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffac230-3d48-4eea-aa2c-22f8680230b6 | 7ffab233-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | bar       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 3ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab234-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        | severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b7 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 3ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b7 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b7 | 7ffac230-3d48-4eea-aa2c-22f8680230b6 | 7ffab232-3d48-4eea-aa2c-22f8680230b7 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | stop_area | stop_area:JDR:CHVIN | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eea-aa2c-22f8680230b3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab234-3d49-4eec-aa2c-22f8680230b7 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            | start_date           | end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 2014-04-10 16:52:00  | 2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 2014-04-10 16:52:00  | 2014-04-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b8 | 7ffab234-3d49-4eec-aa2c-22f8680230b7 | 2014-04-10 16:52:00  | 2014-04-30 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "cause_category_id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "publication_status": ["ongoing"], "cause_category_id": "7ffab231-3d48-4eea-aa2c-22f8680230b6"}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1

    Scenario: Filter on line with application_status

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |
            | foo2      | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b7 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b8 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-04-17 16:52:00                  |2014-04-19 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b8 |2014-04-10 16:52:00                  |2014-04-14 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status": ["ongoing"]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status": ["coming"]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status": ["past"]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status": ["ongoing", "coming"]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        And the field "disruptions.1.impacts.impacts" should have a size of 1
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        And the field "disruptions.0.impacts.impacts" should have a size of 2
        And the field "disruptions.1.impacts.impacts" should have a size of 1

    Scenario: Filter on ptojbect return correct impacts

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-10T23:42:00    | 2014-04-20T23:42:00  |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type  | uri           | created_at          | id                                         |
            | line  | line:JDR:M1   | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | line  | line:JDR:M2   | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b7       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b7          | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-04-10 16:52:00                  |2014-04-17 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status":["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M1"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status":["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M2"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 1
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_status":["ongoing"], "ptObjectFilter": {"lines": ["line:JDR:M2", "line:JDR:M1"]}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 2

    Scenario: Filter on application_period return correct impacts

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-01T00:00:00 | 2014-04-01T00:00:00 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f868023042 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-01T00:00:00    | 2014-04-20T23:42:00  |

        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type  | uri           | created_at          | id                                         |
            | line  | line:JDR:M1   | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b1       |
            | line  | line:JDR:M2   | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b2       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b1          | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b2          | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-04-04 16:52:00                  |2014-04-05 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-04-03 16:52:00                  |2014-04-06 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |2014-04-02 16:52:00                  |2014-04-07 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-04-01 16:52:00                  |2014-04-04 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b5 |2014-04-06 16:52:00                  |2014-04-07 16:52:00 |

        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_period":{"begin": "2014-04-03T00:00:00Z", "end": "2014-04-06T23:59:00Z"}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 5
        When I post to "/disruptions/_search" with:
        """
        {"current_time": "2014-04-15T14:00:00Z", "depth":2, "application_period":{"begin": "2014-04-03T00:00:00Z", "end": "2014-04-05T23:59:00Z"}}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 4
