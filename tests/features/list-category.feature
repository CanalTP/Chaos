Feature: list category

    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill navitia authorization in header

    Scenario: Call without client in the header fails
          I remove header "X-Customer-Id"
          When I get "/categories"
          Then the status code should be "400"

    Scenario: if there is no category the list is empty
          Given I have the following clients in my database:
          | client_code   | created_at          | updated_at          | id                                   |
          | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

          When I get "/categories"
          Then the status code should be "200"
          And the header "Content-Type" should be "application/json"
          and "categories" should be empty

    Scenario: list of two category
          Given I have the following clients in my database:
          | client_code   | created_at          | updated_at          | id                                   |
          | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

          Given I have the following categories in my database:
              | name      |  created_at          | updated_at          | is_visible | id                                   |client_id                            |
              | weather   |  2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | strike    |  2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
          When I get "/categories"
          Then the status code should be "200"
          And the header "Content-Type" should be "application/json"
          And the field "categories" should have a size of 2

    Scenario: only visible categories have to be return
          Given I have the following clients in my database:
          | client_code   | created_at          | updated_at          | id                                   |
          | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

          Given I have the following categories in my database:
              | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
              | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | invisible | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
          When I get "/categories"
          Then the status code should be "200"
          And the header "Content-Type" should be "application/json"
          And the field "categories" should have a size of 2

    Scenario: I can view one category
          Given I have the following clients in my database:
          | client_code   | created_at          | updated_at          | id                                   |
          | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

          Given I have the following categories in my database:
              | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
              | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
          When I get "/categories/7ffab230-3d48-4eea-aa2c-22f8680230b6"
          Then the status code should be "200"
          And the header "Content-Type" should be "application/json"
          And the field "category.name" should be "weather"

    Scenario: I have a 400 if the id doesn't have the correct format
          Given I have the following clients in my database:
          | client_code   | created_at          | updated_at          | id                                   |
          | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

          Given I have the following categories in my database:
              | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
              | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
          When I get "/categories/7ffab230-3d48a-a2c-22f8680230b6"
          Then the status code should be "400"


    Scenario: The client in the header must exist in database
          Given I have the following clients in my database:
          | client_code   | created_at          | updated_at          | id                                   |
          | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |

          Given I have the following categories in my database:
              | name      | created_at          | updated_at          | is_visible | id                                   |client_id                            |
              | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | strike    | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
              | invisible | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | False      | 7ffab233-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
          I fill in header "X-Customer-Id" with "6"
          When I get "/categories"
          Then the status code should be "404"
