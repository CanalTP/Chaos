Feature: traffic report api

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: response of traffic report api without "X-Contributors"
        I remove header "X-Contributors"
        When I get "/traffic_reports"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Contributors does not exist in the header"

    Scenario: response of traffic report api without "X-Coverage"
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        I remove header "X-Coverage"
        When I get "/traffic_reports"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Coverage does not exist in the header"

    Scenario: response of traffic report api without "Authorization"
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        I remove header "Authorization"
        When I get "/traffic_reports"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter Authorization does not exist in the header"

    Scenario: response of traffic report api
        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        When I get "/traffic_reports"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"

    Scenario: impact on network, current_time before publication period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
#
#  TEST1
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2013-12-15T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 0
        And the field "traffic_reports" should have a size of 0

    Scenario: impact on network, current_time between start publication period and start application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                         TEST2
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-01-15T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "traffic_reports" should have a size of 1
        And the field "disruptions.0.status" should be "future"
        And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "traffic_reports.0.network.id" should be "network:JDR:1"
        And the field "traffic_reports.0.network.name" should be "RATP"
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
        And the field "traffic_reports.0.network.links.0.rel" should be "disruptions"

    Scenario: impact on network, current_time between start publication period and end application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                                            TEST2
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-01-23T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "traffic_reports" should have a size of 1
        And the field "disruptions.0.status" should be "active"
        And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "traffic_reports.0.network.id" should be "network:JDR:1"
        And the field "traffic_reports.0.network.name" should be "RATP"
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
        And the field "traffic_reports.0.network.links.0.rel" should be "disruptions"

    Scenario: impact on network, current_time between end publication period and end application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                                                           TEST2
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-02-01T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "traffic_reports" should have a size of 1
        And the field "disruptions.0.status" should be "past"
        And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "traffic_reports.0.network.id" should be "network:JDR:1"
        And the field "traffic_reports.0.network.name" should be "RATP"
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
        And the field "traffic_reports.0.network.links.0.rel" should be "disruptions"

    Scenario: impact on network, current_time after end publication period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                                                                           TEST2
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-02-15T23:52:12Z"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 0
        And the field "traffic_reports" should have a size of 0

    Scenario: impact on network, current_time before publication period
#
#                       |     01-01-2014                                                                  02-03-2014
#  publication_period   |          +--------------------------------------------------------------------------+
#                       |                  20-01-2014      30-01-2014          20-02-2014      28-02-2014
#  application_period   |                     +------------------+                +------------------+
#                       |
# PtObject: network:JDR:1
#
#  TEST1
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-03-02 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b0 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-02-28 16:52:00 |

    When I get "/traffic_reports?current_time=2013-12-15T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 0
    And the field "traffic_reports" should have a size of 0

    Scenario: impact on network, current_time between 2 application periods
#
#                       |     01-01-2014                                                                  02-03-2014
#  publication_period   |          +--------------------------------------------------------------------------+
#                       |                  20-01-2014      30-01-2014          20-02-2014      28-02-2014
#  application_period   |                     +------------------+                +------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                                        TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-03-02 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b0 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-02-20 16:52:00                  |2014-02-28 16:52:00 |

    When I get "/traffic_reports?current_time=2014-02-02T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions.0.status" should be "future"
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should have a size of 1
    And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.links.0.rel" should be "disruptions"

    Scenario: impact on line, current_time between start publication period and end application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: line:JDR:M1
#
#                                                                            TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | line      | line:JDR:M1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-23T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions.0.status" should be "active"
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should not exist
    And the field "traffic_reports.0.lines" should have a size of 1
    And the field "traffic_reports.0.lines.0.id" should be "line:JDR:M1"
    And the field "traffic_reports.0.lines.0.code" should be 1
    And the field "traffic_reports.0.lines.0.name" should be "Château de Vincennes - La Défense"
    And the field "traffic_reports.0.lines.0.links" should have a size of 1
    And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.lines.0.links.0.rel" should be "disruptions"

    Scenario: impact on stop area, current_time between start publication period and end application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: stop_area:JDR:SA:DENFE
#
#                                                                            TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                     | created_at          | updated_at          | id                                         |
        | stop_area | stop_area:JDR:SA:DENFE  | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-23T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions.0.status" should be "active"
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should not exist
    And the field "traffic_reports.0.stop_areas" should have a size of 1
    And the field "traffic_reports.0.stop_areas.0.id" should be "stop_area:JDR:SA:DENFE"
    And the field "traffic_reports.0.stop_areas.0.name" should be "La Défense Grande Arche"
    And the field "traffic_reports.0.stop_areas.0.links" should have a size of 1
    And the field "traffic_reports.0.stop_areas.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.stop_areas.0.links.0.rel" should be "disruptions"

    Scenario: impact on stop point, current_time between start publication period and end application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: stop_point:JDR:SP:BERCY4
#
#                                                                            TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type       | uri                       | created_at          | updated_at          | id                                         |
        | stop_point | stop_point:JDR:SP:BERCY4  | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-23T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions.0.status" should be "active"
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should not exist
    And the field "traffic_reports.0.stop_points" should have a size of 1
    And the field "traffic_reports.0.stop_points.0.id" should be "stop_point:JDR:SP:BERCY4"
    And the field "traffic_reports.0.stop_points.0.name" should be "Bercy"
    And the field "traffic_reports.0.stop_points.0.links" should have a size of 1
    And the field "traffic_reports.0.stop_points.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.stop_points.0.links.0.rel" should be "disruptions"

    Scenario: 2 impacts on network, current_time between start publication period and end application period
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                   +------------------------------------------------------------------------+
#                       |                           05-01-2014      10-01-2014
#  application_period   |                               +------------------+
#                       |                                                                20-01-2014      30-01-2014
#  application_period   |                                                                   +------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                                               TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |


    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-05 16:52:00                  |2014-01-10 16:52:00 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-15T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 2
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions" should contain all of "{"status": "future", "disruption_id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}"
    And the field "disruptions" should contain all of "{"status": "past", "disruption_id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should have a size of 2
    And the field "traffic_reports.0.network.links" should contain all of "{"id": "7ffab232-3d47-4eea-aa2c-22f8680230b6", "rel": "disruptions"}"
    And the field "traffic_reports.0.network.links" should contain all of "{"id": "7ffab232-3d47-4eea-aa2c-22f8680230b7", "rel": "disruptions"}"

    Scenario: 2 disruptions with an impacts on the same network, current_time between start publication period and end application period
#
#                       |          01-01-2014                                  01-31-2014
#  publication_period   |               +-------------------------------------------+
#                       |                           10-01-2014      20-01-2014
#  application_period   |                             +-----------------------+
#
#                       |                            11-01-2014                                        28-02-2014
#  publication_period   |                                +--------------------------------------------------+
#                       |                                    15-01-2014                 05-02-2014
#  application_period   |                                        +---------------------------+
#                       |
# PtObject: network:JDR:1
#
#                                                                    TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-01-31 16:52:00|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b7 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-11 16:52:00|2014-02-28 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b7 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |


    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-10 16:52:00                  |2014-01-20 16:52:00 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-01-15 16:52:00                  |2014-02-05 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-17T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 2
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions" should contain all of "{"status": "active", "id": "7ffab232-3d47-4eea-aa2c-22f8680230b6", "disruption_id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}"
    And the field "disruptions" should contain all of "{"status": "active", "id": "7ffab232-3d47-4eea-aa2c-22f8680230b7", "disruption_id": "7ffab230-3d48-4eea-aa2c-22f8680230b7"}"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should have a size of 2
    And the field "traffic_reports.0.network.links" should contain all of "{"id": "7ffab232-3d47-4eea-aa2c-22f8680230b6", "rel": "disruptions"}"
    And the field "traffic_reports.0.network.links" should contain all of "{"id": "7ffab232-3d47-4eea-aa2c-22f8680230b7", "rel": "disruptions"}"

    Scenario: Impact on 2 networks, current_time between start publication period and end application period
#
#                       |          01-01-2014                                  01-31-2014
#  publication_period   |               +-------------------------------------------+
#                       |                           10-01-2014      20-01-2014
#  application_period   |                             +-----------------------+
#                       |
# PtObject: network:JDR:1 and network:JDR:2
#
#                                                               TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-01-31 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b7       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-10 16:52:00                  |2014-01-20 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-17T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 2
    And the field "disruptions.0.status" should be "active"
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.id" should be "network:JDR:2"
    And the field "traffic_reports.0.network.name" should be "SNCF"
    And the field "traffic_reports.0.network.links" should have a size of 1
    And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.network.links.0.rel" should be "disruptions"
    And the field "traffic_reports.1.network.id" should be "network:JDR:1"
    And the field "traffic_reports.1.network.name" should be "RATP"
    And the field "traffic_reports.1.network.links" should have a size of 1
    And the field "traffic_reports.1.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.1.network.links.0.rel" should be "disruptions"

    Scenario: Impact on 2 lines with same network, current_time between start publication period and end application period
#
#                       |          01-01-2014                                  01-31-2014
#  publication_period   |               +-------------------------------------------+
#                       |                           10-01-2014      20-01-2014
#  application_period   |                             +-----------------------+
#                       |
# PtObject: line:JDR:M1 and line:JDR:M2
#
#                                                               TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-01-31 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

    Given I have the following ptobject in my database:
        | type      | uri                    | created_at          | updated_at          | id                                         |
        | line      | line:JDR:M1            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | line      | line:JDR:M2            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b7       |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-10 16:52:00                  |2014-01-20 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-17T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions.0.status" should be "active"
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.line_sections" should not exist
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should not exist
    And the field "traffic_reports.0.lines" should have a size of 2
    And the field "traffic_reports.0.lines.0.id" should be "line:JDR:M1"
    And the field "traffic_reports.0.lines.0.name" should be "Château de Vincennes - La Défense"
    And the field "traffic_reports.0.lines.0.code" should be 1
    And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.lines.0.links.0.rel" should be "disruptions"
    And the field "traffic_reports.0.lines.1.id" should be "line:JDR:M2"
    And the field "traffic_reports.0.lines.1.name" should be "Nation - Porte Dauphine"
    And the field "traffic_reports.0.lines.1.code" should be 2
    And the field "traffic_reports.0.lines.1.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.lines.1.links.0.rel" should be "disruptions"

    Scenario: Impact on line_section, current_time between start publication period and end application period. The line section should appear
#
#                       |          01-01-2014                                  01-31-2014
#  publication_period   |               +-------------------------------------------+
#                       |                           10-01-2014      20-01-2014
#  application_period   |                             +-----------------------+
#                       |
# PtObject: line:JDR:M1 and line:JDR:M2
#
#                                                               TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-01-31 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


    Given I have the following ptobject in my database:
        | type         | uri                                              | created_at          | updated_at          | id                                         |
        | line         | line:JDR:M1                                      | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | route        | route:JDR:M14                                    | 2014-04-06T22:52:12 | 2014-04-06T22:52:12 | 5ffab200-3d48-4eea-aa2c-22f8680230b6       |
        | route        | route:JDR:M1_R                                   | 2014-04-06T22:52:12 | 2014-04-06T22:52:12 | 6ffab200-3d48-4eea-aa2c-22f8680230b6       |
        | stop_area    | stop_area:JDR:SA:BASTI                           | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | stop_area    | stop_area:JDR:SA:CHVIN                           | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 8ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the following line_section in my database:
        | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id                           |
        | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 1ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |8ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|

    Given I have the relation associate_line_section_route_object in my database:
        | route_object_id                               | line_section_id                      |
        | 5ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |
        | 6ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-10 16:52:00                  |2014-01-20 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-17T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 1
    And the field "traffic_reports" should have a size of 1
    And the field "disruptions.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "disruptions.0.disruption_id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.line_sections" should exist
    And the field "traffic_reports.0.line_sections.0.line_section" should exist
    And the field "traffic_reports.0.line_sections.0.type" should be "line_section"
    And the field "traffic_reports.0.line_sections.0.line_section.end_point.type" should be "stop_area"
    And the field "traffic_reports.0.line_sections.0.line_section.end_point.id" should be "stop_area:JDR:SA:CHVIN"
    And the field "traffic_reports.0.line_sections.0.line_section.start_point.type" should be "stop_area"
    And the field "traffic_reports.0.line_sections.0.line_section.start_point.id" should be "stop_area:JDR:SA:BASTI"
    And the field "traffic_reports.0.line_sections.0.line_section.line.type" should be "line"
    And the field "traffic_reports.0.line_sections.0.line_section.line.id" should be "line:JDR:M1"
    And the field "traffic_reports.0.line_sections.0.line_section.line.name" should exist
    And the field "traffic_reports.0.line_sections.0.line_section.line.code" should exist
    And the field "traffic_reports.0.line_sections.0.line_section.routes" should exist
    And the field "traffic_reports.0.line_sections.0.line_section.routes" should have a size of 2
    And the field "traffic_reports.0.line_sections.0.line_section.routes" should contain all of "{"type": "route", "id": "route:JDR:M1_R"}"
    And the field "traffic_reports.0.line_sections.0.line_section.routes" should contain all of "{"type": "route", "id": "route:JDR:M14"}"
    And the field "traffic_reports.0.network.id" should be "network:JDR:1"
    And the field "traffic_reports.0.network.name" should be "RATP"
    And the field "traffic_reports.0.network.links" should not exist
    And the field "traffic_reports.0.lines" should have a size of 1
    And the field "traffic_reports.0.lines.0.id" should be "line:JDR:M1"
    And the field "traffic_reports.0.lines.0.code" should be 1
    And the field "traffic_reports.0.lines.0.name" should be "Château de Vincennes - La Défense"
    And the field "traffic_reports.0.lines.0.links" should have a size of 1
    And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b6"
    And the field "traffic_reports.0.lines.0.links.0.rel" should be "disruptions"

    Scenario: Impact on two line_sections identicals, current_time between start publication period and end application period. The line_sections should appear two times
#
#                       |          01-01-2014                                  01-31-2014
#  publication_period   |               +-------------------------------------------+
#                       |                           10-01-2014      20-01-2014
#  application_period   |                             +-----------------------+
#                       |
# PtObject: line:JDR:M1 and line:JDR:M2
#
#                                                               TEST2
#
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
        | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
        | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-01-31 16:52:00|

    Given I have the following impacts in my database:
        | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |


    Given I have the following ptobject in my database:
        | type         | uri                                              | created_at          | updated_at          | id                                         |
        | line         | line:JDR:M1                                      | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | line_section | line:JDR:M1:7ffab234-3d49-4eea-aa2c-22f8680230b7 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b7       |
        | route        | route:JDR:M14                                    | 2014-04-06T22:52:12 | 2014-04-06T22:52:12 | 5ffab200-3d48-4eea-aa2c-22f8680230b6       |
        | route        | route:JDR:M1_R                                   | 2014-04-06T22:52:12 | 2014-04-06T22:52:12 | 6ffab200-3d48-4eea-aa2c-22f8680230b6       |
        | stop_area    | stop_area:JDR:SA:BASTI                           | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6       |
        | stop_area    | stop_area:JDR:SA:CHVIN                           | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 8ffab232-3d48-4eea-aa2c-22f8680230b6       |

    Given I have the following line_section in my database:
        | id                                    | line_object_id                        | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id                           |
        | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 1ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |8ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|
        | 7ffab234-3d49-4eea-aa2c-22f8680230b7  | 1ffab232-3d48-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |8ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b7|

    Given I have the relation associate_line_section_route_object in my database:
        | route_object_id                               | line_section_id                      |
        | 5ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |
        | 6ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b6 |
        | 5ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b7 |
        | 6ffab200-3d48-4eea-aa2c-22f8680230b6          | 7ffab234-3d49-4eea-aa2c-22f8680230b7 |

    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 3ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
        | 3ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |

    Given I have the following applicationperiods in my database:
        | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-10 16:52:00                  |2014-01-20 16:52:00 |
        | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-01-10 16:52:00                  |2014-01-20 16:52:00 |

    When I get "/traffic_reports?current_time=2014-01-17T23:52:12Z"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"
    And the field "disruptions" should have a size of 2
    And the field "traffic_reports.0.line_sections" should exist
    And the field "traffic_reports.0.line_sections" should have a size of 2

    Scenario: 2 impacts with 2 networks
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
# PtObject: network:JDR:2
#
#                                                                       TEST1
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b7       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-01-20 16:53:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-01-21T23:52:12Z"
        Then the status code should be "200"
        And the field "disruptions" should have a size of 2
        And the field "traffic_reports" should have a size of 2
        And the field "disruptions" should contain all of "{"id": "7ffab232-3d47-4eea-aa2c-22f8680230b6", "disruption_id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}"
        And the field "traffic_reports.0.line_sections" should not exist
        And the field "traffic_reports.0.network.id" should be "network:JDR:2"
        And the field "traffic_reports.0.network.name" should be "SNCF"
        And the field "traffic_reports.0.network.links" should have a size of 2
        And the field "traffic_reports.1.network.id" should be "network:JDR:1"
        And the field "traffic_reports.1.network.name" should be "RATP"
        And the field "traffic_reports.1.network.links" should have a size of 2

    Scenario: 4 lines for one network, http://jira.canaltp.fr/browse/TR-679

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
            | reference  | note   | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo1       | hello1 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|
            | foo2       | hello2 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b2 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|
            | foo3       | hello3 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b3 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|
            | foo4       | hello4 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b4 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b2 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b3 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b4 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type   | uri                      | created_at          | updated_at          | id                                         |
            | line   | line:JDR:M1              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b1       |
            | line   | line:JDR:M13             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b2       |
            | line   | line:JDR:M14             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b3       |
            | line   | line:JDR:M2              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b4       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b1       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b2       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b3       | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b4       | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b4       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-01-21T23:52:12Z"
        Then the status code should be "200"
        And the field "disruptions" should have a size of 4
        And the field "traffic_reports" should have a size of 1
        And the field "traffic_reports.0.network.id" should be "network:JDR:1"
        And the field "traffic_reports.0.network.name" should be "RATP"
        And the field "traffic_reports.0.network.links" should not exist
        And the field "traffic_reports.0.lines" should have a size of 4
        And the field "traffic_reports.0.lines.0.id" should be "line:JDR:M1"
        And the field "traffic_reports.0.lines.0.links" should have a size of 1
        And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b1"
        And the field "traffic_reports.0.lines.1.id" should be "line:JDR:M2"
        And the field "traffic_reports.0.lines.1.links" should have a size of 2
        And the field "traffic_reports.0.lines.1.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b1"
        And the field "traffic_reports.0.lines.1.links.1.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b4"
        And the field "traffic_reports.0.lines.2.id" should be "line:JDR:M13"
        And the field "traffic_reports.0.lines.2.links" should have a size of 1
        And the field "traffic_reports.0.lines.2.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b2"
        And the field "traffic_reports.0.lines.3.id" should be "line:JDR:M14"
        And the field "traffic_reports.0.lines.3.links" should have a size of 1
        And the field "traffic_reports.0.lines.3.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b3"

    Scenario: One network, one line, 2 stop_areas and 2 stop_points : http://jira.canaltp.fr/browse/TR-706

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
            | reference  | note   | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo1       | hello1 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type          | uri                                       | created_at          | updated_at          | id                                         |
            | network       | network:JDR:2                             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b1       |
            | line          | line:JDR:TGV                              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b2       |
            | stop_area     | stop_area:JDR:SA:GareMontparnasse         | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b3       |
            | stop_area     | stop_area:JDR:SA:LeMans                   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b4       |
            | stop_point    | stop_point:JDR:SP:Nantes-TGV              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b5       |
            | stop_point    | stop_point:JDR:SP:GareMontparnasse-TGV    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b1       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b2       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b3       | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b4       | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b5       | 7ffab232-3d47-4eea-aa2c-22f8680230b5 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-01-21T23:52:12Z"
        Then the status code should be "200"
        And the field "disruptions" should have a size of 6
        And the field "traffic_reports" should have a size of 1
        And the field "traffic_reports.0.network.id" should be "network:JDR:2"
        And the field "traffic_reports.0.network.name" should be "SNCF"
        And the field "traffic_reports.0.network.links" should exist
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b1"
        And the field "traffic_reports.0.lines" should have a size of 1
        And the field "traffic_reports.0.lines.0.id" should be "line:JDR:TGV"
        And the field "traffic_reports.0.lines.0.links" should have a size of 1
        And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b2"
        And the field "traffic_reports.0.stop_areas" should have a size of 2
        And the field "traffic_reports.0.stop_points" should have a size of 2

    Scenario: One network in an impact archived, one line, 2 stop_areas and 2 stop_points

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
            | reference  | note   | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo1       | hello1 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | archived  | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type          | uri                                       | created_at          | updated_at          | id                                         |
            | network       | network:JDR:2                             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b1       |
            | line          | line:JDR:TGV                              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b2       |
            | stop_area     | stop_area:JDR:SA:GareMontparnasse         | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b3       |
            | stop_area     | stop_area:JDR:SA:LeMans                   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b4       |
            | stop_point    | stop_point:JDR:SP:Nantes-TGV              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b5       |
            | stop_point    | stop_point:JDR:SP:GareMontparnasse-TGV    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b1       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b2       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b3       | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b4       | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b5       | 7ffab232-3d47-4eea-aa2c-22f8680230b5 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |


        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b3 | 7ffab232-3d47-4eea-aa2c-22f8680230b3 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b4 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b5 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab232-3d47-4eea-aa2c-22f8680230b4 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I get "/traffic_reports?current_time=2014-01-21T23:52:12Z"
        Then the status code should be "200"
        And the field "disruptions" should have a size of 5
        And the field "traffic_reports" should have a size of 1
        And the field "traffic_reports.0.network.id" should be "network:JDR:2"
        And the field "traffic_reports.0.network.name" should be "SNCF"
        And the field "traffic_reports.0.network.links" should not exist
        And the field "traffic_reports.0.lines" should have a size of 1
        And the field "traffic_reports.0.lines.0.id" should be "line:JDR:TGV"
        And the field "traffic_reports.0.lines.0.links" should have a size of 1
        And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b2"
        And the field "traffic_reports.0.stop_areas" should have a size of 2
        And the field "traffic_reports.0.stop_points" should have a size of 2

    Scenario: One network with filter on network  : http://jira.canaltp.fr/browse/BOT-503

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
            | reference  | note   | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo1       | hello1 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type          | uri                                       | created_at          | updated_at          | id                                         |
            | network       | network:JDR:2                             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b1       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b1       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I post to "/traffic_reports" with:
        """
        {"current_time": "2014-01-21T23:52:12Z", "ptObjectFilter": {"networks": ["network:JDR:2"]}}
        """
        Then the status code should be "200"
        And the field "disruptions" should have a size of 1
        And the field "traffic_reports" should have a size of 1
        And the field "traffic_reports.0.network.id" should be "network:JDR:2"
        And the field "traffic_reports.0.network.name" should be "SNCF"
        And the field "traffic_reports.0.network.links" should exist
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b1"

    Scenario: One network, one line, with filter on network  : http://jira.canaltp.fr/browse/BOT-503

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
            | reference  | note   | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo1       | hello1 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type          | uri                                       | created_at          | updated_at          | id                                         |
            | network       | network:JDR:2                             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b1       |
            | line          | line:JDR:TGV                              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b2       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b1       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b2       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I post to "/traffic_reports" with:
        """
        {"current_time": "2014-01-21T23:52:12Z", "ptObjectFilter": {"networks": ["network:JDR:2"]}}
        """
        Then the status code should be "200"
        And the field "disruptions" should have a size of 0
        And the field "traffic_reports" should have a size of 0

    Scenario: One network, one line, with filter on network and line  : http://jira.canaltp.fr/browse/BOT-503

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
            | reference  | note   | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo1       | hello1 | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type          | uri                                       | created_at          | updated_at          | id                                         |
            | network       | network:JDR:2                             | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b1       |
            | line          | line:JDR:TGV                              | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b2       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b1       | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b2       | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b1 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b2 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        When I post to "/traffic_reports" with:
        """
        {"current_time": "2014-01-21T23:52:12Z", "ptObjectFilter": {"networks": ["network:JDR:2"], "lines": ["line:JDR:TGV"]}}
        """
        Then the status code should be "200"
        And the field "disruptions" should have a size of 2
        And the field "traffic_reports" should have a size of 1
        And the field "traffic_reports.0.network.id" should be "network:JDR:2"
        And the field "traffic_reports.0.network.name" should be "SNCF"
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b1"
        And the field "traffic_reports.0.lines" should have a size of 1
        And the field "traffic_reports.0.lines.0.id" should be "line:JDR:TGV"
        And the field "traffic_reports.0.lines.0.links" should have a size of 1
        And the field "traffic_reports.0.lines.0.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b2"

    Scenario: 2 impacts with one on 2 networks and another on one network and filter on one network
#
#                       |                       01-01-2014                                  02-02-2014
#  publication_period   |                           +-------------------------------------------+
#                       |                                       20-01-2014      30-01-2014
#  application_period   |                                           +------------------+
#                       |
# PtObject: network:JDR:1
# PtObject: network:JDR:2
#
#
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       |start_publication_date|end_publication_date|
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|
            | foo1      | hello1| 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b1 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |2014-01-01 16:52:00|2014-02-02 16:52:00|

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b7 | 7ffab230-3d48-4eea-aa2c-22f8680230b1 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following ptobject in my database:
            | type      | uri                    | created_at          | updated_at          | id                                         |
            | network   | network:JDR:1          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6       |
            | network   | network:JDR:2          | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b7       |

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                               | impact_id                            |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b6       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |
            | 1ffab232-3d48-4eea-aa2c-22f8680230b7       | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab232-3d47-4eea-aa2c-22f8680230b7 |2014-01-20 16:53:00                  |2014-01-30 16:52:00 |

        When I post to "/traffic_reports" with:
        """
        {"current_time": "2014-01-21T23:52:12Z", "ptObjectFilter": {"networks": ["network:JDR:2"]}}
        """
        Then the status code should be "200"
        And the field "disruptions" should have a size of 1
        And the field "traffic_reports" should have a size of 1
        And the field "traffic_reports.0.network.id" should be "network:JDR:2"
        And the field "traffic_reports.0.network.name" should be "SNCF"
        And the field "traffic_reports.0.network.links" should have a size of 1
        And the field "traffic_reports.0.network.links.0.id" should be "7ffab232-3d47-4eea-aa2c-22f8680230b7"
