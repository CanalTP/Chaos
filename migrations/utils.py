from alembic import op

def index_exists(name):
    connection = op.get_bind()
    result = connection.execute(
        "SELECT exists(SELECT 1 from pg_indexes where indexname = '{}') as ix_exists;"
            .format(name)
    ).first()
    return result.ix_exists

def table_exists(table_name):
    connection = op.get_bind()
    result = connection.execute(
        "SELECT EXISTS( \
            SELECT * \
            FROM information_schema.tables \
            WHERE \
            table_schema = 'public' AND \
            table_name = '{}' \
        ) as ix_exists;".format(table_name)
            .format(table_name)
    ).first()
    return result.ix_exists

def column_exists(table_name, column_name):
    connection = op.get_bind()
    result = connection.execute(
        "SELECT EXISTS ( \
            SELECT 1  \
            FROM information_schema.columns \
            WHERE table_schema='public' \
            AND table_name='{}' \
            AND column_name='{}') as ix_exists;".format(table_name, column_name).format(table_name)
    ).first()
    return result.ix_exists
