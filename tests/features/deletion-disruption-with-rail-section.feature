Feature: Delete disruption with rail section
    Background:
        I fill navitia authorization in header
        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Coverage" with "jdr"
        I fill in header "X-Contributors" with "contrib1"

    Scenario: Delete an disruption and impact with rail_section

    Given I have the following clients in my database:
        | id                                   | client_code   | created_at          | updated_at          |
        | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 5             | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 |
    Given I have the following contributors in my database:
        | id                                   |contributor_code   | created_at          | updated_at          |
        | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | contrib1          | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 |
    Given I have the following severities in my database:
        |id                                   |client_id                                | wording   | color   | created_at          | updated_at          | is_visible |
        | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6    | good news | #654321 | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 | True       |
    Given I have the following categories in my database:
        | id                                    | client_id                             | name      | is_visible    | created_at          | updated_at          |
        | 7ffab230-3d48-4eea-aa2c-23f8680230b6  | 7ffab229-3d48-4eea-aa2c-22f8680230b6  | foo       | True          | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 |
    Given I have the following causes in my database:
        | id                                   | client_id                            | category_id                          | wording   | created_at          | updated_at          | is_visible |
        | 7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab230-3d48-4eea-aa2c-23f8680230b6 | weather   | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 | True       |


    Given I have the following disruptions in my database:
        | id                                   |  cause_id                             | client_id                            | contributor_id                       | reference | note  | created_at          | updated_at          | status    | start_publication_date | end_publication_date    |
        | e0732642-ba46-11eb-9d19-907841ddb058 |  7ffab230-3d48-4eea-aa2c-22f8680230b6 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 | 7ffab555-3d48-4eea-aa2c-22f8680230b6 | test      |       | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 | published | 2021-05-21T00:00:00    | 2021-05-21T23:55:12     |
    Given I have the following impacts in my database:
        | id                                   | disruption_id                        | severity_id                         | created_at          | updated_at          | status    | send_notifications | version |
        | e0732643-ba46-11eb-9d19-907841ddb058 | e0732642-ba46-11eb-9d19-907841ddb058 |7ffab232-3d48-4eea-aa2c-22f8680230b6 | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 | published | False              | 1       |
    Given I have the following ptobject in my database:
        | created_at         | id                                    | type             | uri |
        | 2021-05-21T00:00:00 | e0732644-ba46-11eb-9d19-907841ddb058   | rail_section   | stop_area:DUA:SA:8768603:stop_area:DUA:SA:8775810:e0732644-ba46-11eb-9d19-907841ddb058    |
        | 2021-05-21T00:00:00 | e0732646-ba46-11eb-9d19-907841ddb058   | line           | line:DUA:100110001                                                                        |
        | 2021-05-21T00:00:00 | e0732647-ba46-11eb-9d19-907841ddb058   | stop_area      | stop_area:DUA:SA:8768603                                                                  |
        | 2021-05-21T00:00:00 | e0732648-ba46-11eb-9d19-907841ddb058   | stop_area      | stop_area:DUA:SA:8775810                                                                  |
        | 2021-05-21T00:00:00 | e0732649-ba46-11eb-9d19-907841ddb058   | route          | route:DUA:10011000100010                                                                  |
        | 2021-05-21T00:00:00 | e073264a-ba46-11eb-9d19-907841ddb058   | route          | route:DUA:10011000100011                                                                  |
    Given I have the following rail_section in my database:
        | id                                     | created_at          | updated_at            | line_object_id                          | start_object_id                      | end_object_id                        | blocked_stop_areas                                                                                 | object_id                            |
        | e0732645-ba46-11eb-9d19-907841ddb058   | 2021-05-21T00:00:00 | 2021-05-21T00:00:00   | e0732646-ba46-11eb-9d19-907841ddb058    | e0732647-ba46-11eb-9d19-907841ddb058 | e0732648-ba46-11eb-9d19-907841ddb058 | [{"id": "stop_area:DUA:SA:8775810", "order": 1}, {"id": "stop_area:DUA:SA:8768603", "order": 2}] | e0732644-ba46-11eb-9d19-907841ddb058 |
    Given I have the following applicationperiods in my database:
        | id                                   | impact_id                            |start_date            |end_date               | created_at          | updated_at          |
        | e073264b-ba46-11eb-9d19-907841ddb058 | e0732643-ba46-11eb-9d19-907841ddb058 |2021-05-21T00:00:00   |2021-05-21T23:59:59    | 2021-05-21T00:00:00 | 2021-05-21T00:00:00 |
    Given I have the relation associate_impact_pt_object in my database:
        | pt_object_id                               | impact_id                            |
        | e0732644-ba46-11eb-9d19-907841ddb058       | e0732643-ba46-11eb-9d19-907841ddb058 |
    Given I have the relation associate_rail_section_route_object in my database:
        | rail_section_id                       | route_object_id                       |
        | e0732645-ba46-11eb-9d19-907841ddb058  | e0732649-ba46-11eb-9d19-907841ddb058  |
        | e0732645-ba46-11eb-9d19-907841ddb058  | e073264a-ba46-11eb-9d19-907841ddb058


    When I get "/disruptions/e0732642-ba46-11eb-9d19-907841ddb058"
    Then the status code should be "200"
    And the header "Content-Type" should be "application/json"

    When I delete "/disruptions/e0732642-ba46-11eb-9d19-907841ddb058"
    Then the status code should be "204"

