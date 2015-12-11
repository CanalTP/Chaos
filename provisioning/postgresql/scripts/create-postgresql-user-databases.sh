#!/bin/bash

# Create navitia user
echo "CREATE ROLE navitia WITH PASSWORD 'AGPXSnTFHmXknK'" | psql -U postgres

# Create chaos databases ("chaos" and "chaos_testing") with navitia user as their respective owners
createdb -O navitia chaos
createdb -O navitia chaos_testing
