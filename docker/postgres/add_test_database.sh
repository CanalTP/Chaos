#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
    CREATE database "chaos_testing";
EOSQL
