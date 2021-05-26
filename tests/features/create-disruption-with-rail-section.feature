Feature: Create Disruption with rail section
    Background:
        I fill in header "X-Customer-Id" with "5"
        I fill in header "X-Coverage" with "jdr"
        I fill navitia authorization in header

        Given I have the following clients in my database:
            | client_code   | created_at          | updated_at          | id                                   |
            | 5             | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | 7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following causes in my database:
            | wording   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | weather   | 2014-04-02T23:52:12 | 2014-04-02T23:55:12 | True       | 7ffab230-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |
        Given I have the following severities in my database:
            | wording   | color   | created_at          | updated_at          | is_visible | id                                   |client_id                            |
            | good news | #654321 | 2014-04-04T23:52:12 | 2014-04-06T22:52:12 | True       | 7ffab232-3d48-4eea-aa2c-22f8680230b6 |7ffab229-3d48-4eea-aa2c-22f8680230b6 |

    Scenario: creation of disruption with one impact and ptobject rail_section with line without routes
        When I post to "/disruptions" with:
        """
        {"reference":"foo","contributor":"contrib1","cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts":[{"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"},{"begin":"2014-04-29T16:52:00Z","end":"2014-05-22T02:15:00Z"}],"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"line":{"id":"line:JDR:M5","type":"line"},"start_point":{"id":"stop_area:JDR:BASTI","type":"stop_area"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"},"blocked_stop_areas":[{"id":"stop_area:1","order":0}]}}]}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"
        And the field "disruption.impacts.pagination.total_result" should be 1
        And the field "disruption.version" should be 1
        And the field "disruption.impacts.impacts" should not exist

    Scenario: creation of disruption with one impact and ptobject rail_section with line with routes
        When I post to "/disruptions" with:
        """
        {"reference":"foo","contributor":"contrib1","cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts":[{"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"},{"begin":"2014-04-29T16:52:00Z","end":"2014-05-22T02:15:00Z"}],"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"line":{"id":"line:JDR:M5","type":"line"},"start_point":{"id":"stop_area:JDR:BASTI","type":"stop_area"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"},"blocked_stop_areas":[{"id":"stop_area:1","order":0}],"routes":[{"id":"route:FLY:D_MRS","type":"route"},{"id":"route:FLY:D_VCE","type":"route"}]}}]}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"

    Scenario: creation of disruption with one impact and ptobject rail_section without line with routes
        When I post to "/disruptions" with:
        """
        {"reference":"foo","contributor":"contrib1","cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts":[{"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"},{"begin":"2014-04-29T16:52:00Z","end":"2014-05-22T02:15:00Z"}],"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"start_point":{"id":"stop_area:JDR:BASTI","type":"stop_area"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"},"blocked_stop_areas":[{"id":"stop_area:1","order":0}],"routes":[{"id":"route:FLY:D_MRS","type":"route"},{"id":"route:FLY:D_VCE","type":"route"}]}}]}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"


    Scenario: creation of disruption with one impact and ptobject rail_section without blocked_stop_areas
        When I post to "/disruptions" with:
        """
        {"reference":"foo","contributor":"contrib1","cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts":[{"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"},{"begin":"2014-04-29T16:52:00Z","end":"2014-05-22T02:15:00Z"}],"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"line":{"id":"line:JDR:M5","type":"line"},"start_point":{"id":"stop_area:JDR:BASTI","type":"stop_area"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"}}}]}]}
        """
        Then the status code should be "201"
        And the header "Content-Type" should be "application/json"

    Scenario: creation of disruption with one impact and ptobject rail_section without start_point
        When I post to "/disruptions" with:
        """
        {"reference":"foo","contributor":"contrib1","cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts":[{"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"},{"begin":"2014-04-29T16:52:00Z","end":"2014-05-22T02:15:00Z"}],"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"line":{"id":"line:JDR:M5","type":"line"},"end_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"}}}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'start_point' is a required property"

    Scenario: creation of disruption with one impact and ptobject rail_section without end_point
        When I post to "/disruptions" with:
        """
        {"reference":"foo","contributor":"contrib1","cause":{"id":"7ffab230-3d48-4eea-aa2c-22f8680230b6"},"publication_period":{"begin":"2018-09-11T13:50:00Z","end":"2018-12-31T16:50:00Z"},"impacts":[{"severity":{"id":"7ffab232-3d48-4eea-aa2c-22f8680230b6"},"application_periods":[{"begin":"2014-04-29T16:52:00Z","end":"2014-06-22T02:15:00Z"},{"begin":"2014-04-29T16:52:00Z","end":"2014-05-22T02:15:00Z"}],"objects":[{"id":"stop_area:JDR:BASTI:stop_area:JDR:CHVIN:1","type":"rail_section","rail_section":{"line":{"id":"line:JDR:M5","type":"line"},"start_point":{"id":"stop_area:JDR:CHVIN","type":"stop_area"}}}]}]}
        """
        Then the status code should be "400"
        And the header "Content-Type" should be "application/json"
        And the field "error.message" should be "'end_point' is a required property"

