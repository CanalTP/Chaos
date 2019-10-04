Feature: list disruptions with pager

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "Authorization" with "d5b0148c-36f4-443c-9818-1f2f74a00be0"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Use pager to display disruptions

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                            | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:55:12  |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12    | 2014-04-06T22:52:12  |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12    | 2014-04-06T22:52:12  |

        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 3
        And the field "meta" should exist
        And the field "meta.pagination.items_per_page" should be 20
        And the field "meta.pagination.items_on_page" should be 3
        And the field "meta.pagination.start_page" should be 1


    Scenario: Use pager to display disruptions with parameters (start_page=1)

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                            | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:55:12  |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12    | 2014-04-06T22:52:12  |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12    | 2014-04-06T22:52:12  |

        When I get "/disruptions?start_page=1&items_per_page=2"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 2
        And the field "meta" should exist
        And the field "meta.pagination.items_per_page" should be 2
        And the field "meta.pagination.items_on_page" should be 2
        And the field "meta.pagination.start_page" should be 1
        And the field "meta.pagination.total_result" should be 3
        And the field "meta.pagination.prev.href" should be null
        And the field "meta.pagination.first.href" should be "http://localhost/disruptions?items_per_page=2&start_page=1"
        And the field "meta.pagination.next.href" should be "http://localhost/disruptions?items_per_page=2&start_page=2"
        And the field "meta.pagination.last.href" should be "http://localhost/disruptions?items_per_page=2&start_page=2"

    Scenario: Use pager to display disruptions with parameters (start_page=2)

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                            | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:55:12  |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12    | 2014-04-06T22:52:12  |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-04T23:52:12    | 2014-04-06T22:52:12  |

        When I get "/disruptions?start_page=2&items_per_page=2"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "meta" should exist
        And the field "meta.pagination.items_per_page" should be 2
        And the field "meta.pagination.items_on_page" should be 1
        And the field "meta.pagination.start_page" should be 2
        And the field "meta.pagination.total_result" should be 3
        And the field "meta.pagination.prev.href" should be "http://localhost/disruptions?items_per_page=2&start_page=1"
        And the field "meta.pagination.first.href" should be "http://localhost/disruptions?items_per_page=2&start_page=1"
        And the field "meta.pagination.next.href" should be null
        And the field "meta.pagination.last.href" should be "http://localhost/disruptions?items_per_page=2&start_page=2"

    Scenario: Use pager to display disruptions with parameters (start_page=2)

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                            | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:55:12  |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "meta" should exist
        And the field "disruptions.0.impacts" should exist
        And the field "disruptions.0.impacts.pagination" should exist
        And the field "disruptions.0.impacts.pagination.items_on_page" should be 2
        And the field "disruptions.0.impacts.pagination.start_page" should be 1
        And the field "disruptions.0.impacts.pagination.total_result" should be 2
        And the field "disruptions.0.impacts.pagination.prev.href" should be null
        And the field "disruptions.0.impacts.pagination.first.href" should be "http://localhost/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts?items_per_page=20&start_page=1"
        And the field "disruptions.0.impacts.pagination.next.href" should be null
        And the field "disruptions.0.impacts.pagination.last.href" should be "http://localhost/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6/impacts?items_per_page=20&start_page=1"


    Scenario: Use pager to display disruptions with parameters (page_index=0)

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                            | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions?start_page=0&items_per_page=10"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "page_index argument value is not valid"

    Scenario: Use pager to display disruptions with parameters (items_per_page not valid)

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
            | reference | note  | created_at          | updated_at          | status    | id                                   |cause_id                            | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions?start_page=1&items_per_page=-1"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "items_per_page argument value is not valid"

        When I get "/disruptions?start_page=1&items_per_page=1001"
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "message" should be "items_per_page argument value can't be superior than 1000"

    Scenario: Use pager to order disruptions with identical end_publication_date

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | end_publication_date |cause_id                            | client_id                            | contributor_id                       |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 2014-05-02T19:00:00 | 7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | bar       | bye   | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 8ffab230-3d48-4eea-aa2c-22f8680230b6 | 2014-05-02T19:00:00 | 7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | toto      |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 9ffab230-3d48-4eea-aa2c-22f8680230b6 | 2014-05-02T19:00:00 | 7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | chien     |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 0ffab230-3d48-4eea-aa2c-22f8680230b6 | 2014-05-02T19:00:00 | 7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |
            | clown     |       | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 1ffab230-3d48-4eea-aa2c-22f8680230b6 | 2014-05-02T19:00:00 | 7ffab230-3d48-4eea-aa2c-22f8680230b6| 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 5
        And the field "disruptions.0.id" should be "0ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.1.id" should be "1ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.2.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.3.id" should be "8ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.4.id" should be "9ffab230-3d48-4eea-aa2c-22f8680230b6"
        When I get "/disruptions?start_page=2&items_per_page=2"
        Then the status code should be "200"
        And the field "disruptions.0.id" should be "7ffab230-3d48-4eea-aa2c-22f8680230b6"
        And the field "disruptions.1.id" should be "8ffab230-3d48-4eea-aa2c-22f8680230b6"
        When I get "/disruptions?start_page=3&items_per_page=2"
        Then the status code should be "200"
        And the field "disruptions.0.id" should be "9ffab230-3d48-4eea-aa2c-22f8680230b6"

    Scenario: Display disruptions with impacts using parameter (depth=2)

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
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:55:12  |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b3 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eec-aa2c-22f8680230b4 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions?depth=1"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should not exist

        When I get "/disruptions?depth=2"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 6
        And the field "disruptions.0.impacts.impacts.0" is valid impact

        When I get "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6?depth=1"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.impacts.impacts" should not exist

        When I get "/disruptions/7ffab230-3d48-4eea-aa2c-22f8680230b6?depth=2"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.impacts.impacts" should have a size of 6

    Scenario: Retrieve just published impacts

        Given I have the following contributors in my database:
            | contributor_code   | created_at          | updated_at          | id                                   |
            | contrib1           | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following disruptions in my database:
            | reference | note  | created_at          | updated_at          | status    | id                                   | client_id                            | contributor_id                       | start_publication_date | end_publication_date |
            | foo       | hello | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | published | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | 2014-04-02T23:52:12    | 2014-04-03T23:55:12  |

        Given I have the following severities in my database:
                | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
                | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

        Given I have the following impacts in my database:
            | created_at          | updated_at          | status    | id                                   | disruption_id                        |severity_id                          |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab232-3d47-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | published | 7ffab234-3d49-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | archived | 7ffab234-3d49-4eec-aa2c-22f8680230b1 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |
            | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | archived | 7ffab232-3d47-4eea-aa2c-22f8680230b2 | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab232-3d48-4eea-aa2c-22f8680230b6 |

        When I get "/disruptions?depth=2"
        Then the status code should be "200"
        And the header "Content-Type" should be "application/json"
        And the field "disruptions" should have a size of 1
        And the field "disruptions.0.impacts.impacts" should have a size of 2
