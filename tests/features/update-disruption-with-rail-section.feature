Feature: Manipulate impacts in a Disruption

    Scenario: Put impact with rail_section : from no line to added line
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

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
            | rail_section | stop_area:JDR:BASTI:stop_area:JDR:CHVIN:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following rail_section in my database:
            | id                                    | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id                           |blocked_stop_areas               |
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|[{"uri":"stop_area:1","order":0}]|

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Contributors" with "contrib1"
        I fill in header "X-Coverage" with "jdr"
        I fill navitia authorization in header
        When I get "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects" should exist
        And the field "impact.objects" should have a size of 1
        And the field "impact.objects.0.type" should be "rail_section"
        And "impact.objects.0.rail_section.line" should be empty
        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"line":{"id":"line:JDR:M5","type":"line"},"start_point":{"id":"stop_area:JDR:BASTI","type":"stop_area"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"},"blocked_stop_areas":[{"id":"stop_area:1","order":0}],"route_patterns":[[{"id":"stop_area:JDR:BASTI","order":0},{"id":"stop_area:1","order":1},{"id":"stop_area:JDR:CHVIN","order":2}]]}}],"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects" should have a size of 1
        And the field "impact.objects.0.type" should be "rail_section"
        And the field "impact.objects.0.rail_section.line.id" should be "line:JDR:M5"

    Scenario: Put impact with rail_section : from no routes to added routes
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
            | reference | note  | created_at          | updated_at          | status    | id                                   | cause_id                             | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

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
            | rail_section | stop_area:JDR:BASTI:stop_area:JDR:CHVIN:7ffab234-3d49-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12 | 3ffab232-3d48-4eea-aa2c-22f8680230b6       |

        Given I have the following rail_section in my database:
            | id                                    | created_at            | updated_at          | start_object_id                      |end_object_id                       |object_id                           |blocked_stop_areas               |
            | 7ffab234-3d49-4eea-aa2c-22f8680230b6  | 2014-04-04T23:52:12   | 2014-04-04T23:52:12 | 1ffab232-3d48-4eea-aa2c-22f8680230b6 |2ffab232-3d48-4eea-aa2c-22f8680230b6|3ffab232-3d48-4eea-aa2c-22f8680230b6|[{"uri":"stop_area:1","order":0}]|

        Given I have the relation associate_impact_pt_object in my database:
            | pt_object_id                                  | impact_id                            |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6          | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |

        Given I have the following applicationperiods in my database:
            | created_at          | updated_at          |id                                   | impact_id                            |start_date                           |end_date            |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 |7ffab232-3d47-4eea-aa2c-22f8680230b1 | 7ffab232-3d47-4eea-aa2c-22f8680230b6 |2014-01-20 16:52:00                  |2014-01-30 16:52:00 |

        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Contributors" with "contrib1"
        I fill in header "X-Coverage" with "jdr"
        I fill navitia authorization in header
        When I get "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects" should exist
        And the field "impact.objects" should have a size of 1
        And the field "impact.objects.0.type" should be "rail_section"
        And "impact.objects.0.rail_section.line" should be empty
        When I put to "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts/7ffab232-3d47-4eea-aa2c-22f8680230b6" with:
        """
        {"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"routes":[{"type":"route", "id":"route:JDR:M14"}, {"type":"route", "id":"route:JDR:M1"}],"start_point":{"id":"stop_area:JDR:BASTI","type":"stop_area"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"},"blocked_stop_areas":[{"id":"stop_area:1","order":0}],"route_patterns":[[{"id":"stop_area:JDR:BASTI","order":0},{"id":"stop_area:1","order":1},{"id":"stop_area:JDR:CHVIN","order":2}]]}}],"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"}]}
        """
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "impact.objects" should have a size of 1
        And the field "impact.objects.0.type" should be "rail_section"
        And the field "impact.objects.0.rail_section.routes" should have a size of 2
