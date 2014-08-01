Feature: Manipulate tags in a Disruption

    Scenario: Display tag in a disruption

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | a750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/a750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, {"id": "7ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 2

            When I get "/disruptions"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruptions" should have a size of 1
            And the field "disruptions.0.tags" should have a size of 2

    Scenario: Display tag in a disruption filter by tag.name=rer

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/1750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "1ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/2750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "2ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/3750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1


            When I get "/disruptions?tag[]=1ffab230-3d48-4eea-aa2c-22f8680230b6"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruptions" should have a size of 1
            And the field "disruptions.0.tags" should have a size of 1
            And the field "disruptions.0.id" should be "1750994c-01fe-11e4-b4fb-080027079ff3"
            And the field "disruptions.0.tags.0.id" should be "1ffab230-3d48-4eea-aa2c-22f8680230b6"
            And the field "disruptions.0.tags.0.name" should be "rer"


    Scenario: Display tag in a disruption filter by tag.name=rer or tag.name=meteo

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/1750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "1ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/2750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "2ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/3750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1


            When I get "/disruptions?tag[]=1ffab230-3d48-4eea-aa2c-22f8680230b6&tag[]=3ffab232-3d48-4eea-aa2c-22f8680230b6"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruptions" should have a size of 2
            And the field "disruptions.0.tags" should have a size of 1
            And the field "disruptions.0.tags.0.name" should be "rer"
            And the field "disruptions.1.tags" should have a size of 1
            And the field "disruptions.1.tags.0.name" should be "meteo"


    Scenario: Display tag in a disruption filter by tag.name=rer or tag.name=meteo or tag.name=probleme

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/1750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "1ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/2750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "2ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/3750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1


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

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/1750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "1ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/2750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "2ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/3750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1


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

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/1750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "1ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/2750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "2ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/3750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1


            When I get "/disruptions?tag[]=3ffab232-3d48-4eea-aa2c-22f8680230ba"
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruptions" should have a size of 0


    Scenario: Display tag in a disruption filter by tag.id not valid

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | start_publication_date | end_publication_date     | cause_id                             |
            | rer       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 2750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 3750994c-01fe-11e4-b4fb-080027079ff3 | 2014-04-15T23:52:12    | 2014-04-19T23:55:12      | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      |  created_at          | updated_at          | is_visible | id                                   |
            | rer       |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 1ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | probleme  |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 2ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | meteo     |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 3ffab232-3d48-4eea-aa2c-22f8680230b6 |

            When I put to "/disruptions/1750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "1ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/2750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "2ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1

            When I put to "/disruptions/3750994c-01fe-11e4-b4fb-080027079ff3" with:
            """
            {"reference":"foobarz", "cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags":[{"id": "3ffab232-3d48-4eea-aa2c-22f8680230b6"}]}
            """
            Then the status code should be "200"
            And the header "Content-Type" should be "application/json"
            And the field "disruption.tags" should have a size of 1


            When I get "/disruptions?tag[]=aa"
            Then the status code should be "400"
            And the header "Content-Type" should be "application/json"
            And the field "message" should exist
            And the field "message" should be "The tag[] argument value is not valid, you gave: aa"
