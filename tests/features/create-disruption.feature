Feature: Create disruption

    Scenario: Reference is required
        When I post to "/disruptions"
        Then the status code should be "400"

    Scenario: creation of disruption

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.reference" should be "foo"
        And the field "disruption.note" should be null

    Scenario: Disruption are created

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I post to "/disruptions" with:
        """
        {"reference": "foo", "note": "hello", "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.reference" should be "foo"
        And the field "disruptions.0.note" should be "hello"

    Scenario: We can create a disruption with a publication_period

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": "2014-06-24T23:59:59Z"}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.reference" should be "foo"
        And the field "disruption.note" should be null
        And the field "disruption.publication_period.begin" should be "2014-06-24T10:35:00Z"
        And the field "disruption.publication_period.end" should be "2014-06-24T23:59:59Z"

    Scenario: Publication period must be complete

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z"}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"

    Scenario: We can create a disruption with a publication_period

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": "2014-06-24T23:59:59Z"}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.reference" should be "foo"
        And the field "disruption.note" should be null
        And the field "disruption.publication_period.begin" should be "2014-06-24T10:35:00Z"
        And the field "disruption.publication_period.end" should be "2014-06-24T23:59:59Z"

    Scenario: Disruption are created with publication_period

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": "2014-06-24T23:59:59Z"}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions.0.reference" should be "foo"
        And the field "disruptions.0.publication_period.begin" should be "2014-06-24T10:35:00Z"
        And the field "disruptions.0.publication_period.end" should be "2014-06-24T23:59:59Z"

    Scenario: We can create a disruption with a end_publication_date null

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": null}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.reference" should be "foo"
        And the field "disruption.note" should be null
        And the field "disruption.publication_period.begin" should be "2014-06-24T10:35:00Z"
        And the field "disruption.publication_period.end" should be null

    Scenario: We can create a disruption with localization

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": null}, "localization":[{"id":"stop_area:JDR:SA:CHVIN", "type": "stop_area"}], "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.localization" should exist
        And the field "disruption.localization.0.id" should be "stop_area:JDR:SA:CHVIN"
        And the field "disruption.localization.0.type" should be "stop_area"

    Scenario: We can create a disruption with tag

        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following tags in my database:
            | name      | created_at          | updated_at          | is_visible | id                                   |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I post to "/disruptions" with:
        """
        {"reference": "foo", "publication_period": {"begin": "2014-06-24T10:35:00Z", "end": "2014-06-24T23:35:00Z"}, "cause":{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}, "tags" [{"id": "7ffab230-3d48-4eea-aa2c-22f8680230b6"}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.tags" should exist
        And the field "disruption.tags.0.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruption.tags.0.name" should be "weather"