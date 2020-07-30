Feature: Manipulate tags in a Disruption

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Display of disruption without contributor in the header fails

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
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 |
        I remove header "X-Contributors"
        When I get "/disruptions"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "The parameter X-Contributors does not exist in the header"

    Scenario: Display tag in a disruption

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
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 |
            | 7ffab232-3d48-4eea-aa2c-22f8680230b6 | a750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.tags" should have a size of 2
        And the field "disruptions.0.contributor" should be "contrib1"

    Scenario: Display tag in a disruption filter by tag.name=rer

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
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 1750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 2750994c-01fe-11e4-b4fb-080027079ff3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 3750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions?tag[]=1ffab230-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.tags" should have a size of 1
        And the field "disruptions.0.id" should be "1750994c-01fe-11e4-b4fb-080027079ff3"
        And the field "disruptions.0.tags.0.id" should be "1ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.0.tags.0.name" should be "rer"


    Scenario: Display tag in a disruption filter by tag.name=rer or tag.name=meteo

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
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-14T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-15T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-16T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 1750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 2750994c-01fe-11e4-b4fb-080027079ff3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 3750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions?tag[]=1ffab230-3d48-4eea-aa2c-22f8680230b6&tag[]=3ffab232-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        And the field "disruptions.0.tags" should have a size of 1
        And the field "disruptions.0.tags.0.name" should be "rer"
        And the field "disruptions.1.tags" should have a size of 1
        And the field "disruptions.1.tags.0.name" should be "meteo"


    Scenario: Display tag in a disruption filter by tag.name=rer or tag.name=meteo or tag.name=probleme

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
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-14T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-15T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-16T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 1750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 2750994c-01fe-11e4-b4fb-080027079ff3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 3750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions?tag[]=1ffab230-3d48-4eea-aa2c-22f8680230b6&tag[]=3ffab232-3d48-4eea-aa2c-22f8680230b6&tag[]=2ffab232-3d48-4eea-aa2c-22f8680230b6"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 3
        And the field "disruptions.0.tags" should have a size of 1
        And the field "disruptions.0.tags.0.name" should be "rer"
        And the field "disruptions.1.tags" should have a size of 1
        And the field "disruptions.1.tags.0.name" should be "probleme"
        And the field "disruptions.2.tags" should have a size of 1
        And the field "disruptions.2.tags.0.name" should be "meteo"

    Scenario: Display tag in a disruption not filter by tag

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
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:13      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:14      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 1750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 2750994c-01fe-11e4-b4fb-080027079ff3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 3750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 3
        And the field "disruptions.0.tags" should have a size of 1
        And the field "disruptions.0.tags.0.name" should be "rer"
        And the field "disruptions.1.tags" should have a size of 1
        And the field "disruptions.1.tags.0.name" should be "probleme"
        And the field "disruptions.2.tags" should have a size of 1
        And the field "disruptions.2.tags.0.name" should be "meteo"

    Scenario: Display tag in a disruption filter by tag.id not exist

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
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 1750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 2750994c-01fe-11e4-b4fb-080027079ff3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 3750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions?tag[]=3ffab232-3d48-4eea-aa2c-22f8680230ba"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 0


    Scenario: Display tag in a disruption filter by tag.id not valid

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
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                             |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the relation associate_disruption_tag in my database:
            | tag_id                               | disruption_id                        |
            | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 1750994c-01fe-11e4-b4fb-080027079ff3 |
            | 2ffab232-3d48-4eea-aa2c-22f8680230b6 | 2750994c-01fe-11e4-b4fb-080027079ff3 |
            | 3ffab232-3d48-4eea-aa2c-22f8680230b6 | 3750994c-01fe-11e4-b4fb-080027079ff3 |

        When I get "/disruptions?tag[]=aa"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should exist
        And the field "message" should be "The tag[] argument value is not valid, you gave: aa"
