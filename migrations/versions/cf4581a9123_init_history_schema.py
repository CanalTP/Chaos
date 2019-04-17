"""Init history schema

Revision ID: cf4581a9123
Revises: bf4581a9122
Create Date: 2019-04-17 16:59:47.907869

"""

# revision identifiers, used by Alembic.
revision = 'cf4581a9123'
down_revision = 'bf4581a9122'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    connection = op.get_bind()
    result = connection.execute('select count(*) as nb from information_schema.schemata where schema_name = \'history\'')
    for row in result:
        # Schema history not exist in database
        if row['nb'] == 0:
            op.execute('CREATE SCHEMA history')
    op.create_table('disruption',
                    sa.Column('created_at', sa.DateTime(), nullable=False),
                    sa.Column('updated_at', sa.DateTime(), nullable=True),
                    sa.Column('id', sa.Integer(), nullable=False, autoincrement=True),
                    sa.Column('disruption_id', postgresql.UUID(), nullable=False),
                    sa.Column('reference', sa.Text(), nullable=True),
                    sa.Column('note', sa.Text(), nullable=True),
                    sa.Column('start_publication_date', sa.DateTime(), nullable=True),
                    sa.Column('end_publication_date', sa.DateTime(), nullable=True),
                    sa.Column('version', sa.Integer(), nullable=False),
                    sa.Column('client_id', postgresql.UUID(), nullable=False),
                    sa.Column('contributor_id', postgresql.UUID(), nullable=False),
                    sa.Column('cause_id', postgresql.UUID(), nullable=False),
                    sa.Column('status', sa.Text(), nullable=False),
                    sa.PrimaryKeyConstraint('id'),
                    schema='history'
                    )
    op.execute('CREATE OR REPLACE FUNCTION log_disruption_update() \
                  RETURNS trigger AS \
                $BODY$ \
                BEGIN \
                 IF NEW.reference <> OLD.reference OR NEW.note <> OLD.note \
                    OR NEW.start_publication_date <> OLD.start_publication_date \
                    OR NEW.end_publication_date <> OLD.end_publication_date \
                    OR NEW.client_id <> OLD.client_id OR NEW.contributor_id <> OLD.contributor_id \
                    OR NEW.cause_id <> OLD.cause_id OR NEW.status <> OLD.status \
                    THEN \
                 INSERT INTO history.disruption(created_at,updated_at,disruption_id,reference,note,\
                    start_publication_date,end_publication_date,version,client_id,contributor_id,\
                    cause_id,status) \
                 VALUES(OLD.created_at,OLD.updated_at,OLD.id,OLD.reference,OLD.note,OLD.start_publication_date,\
                    OLD.end_publication_date,OLD.version,OLD.client_id,OLD.contributor_id,\
                    OLD.cause_id,OLD.status); \
                 END IF; \
                 RETURN NEW; \
                END; \
                $BODY$\
                LANGUAGE plpgsql VOLATILE')
    op.execute('CREATE TRIGGER last_disruption_changes \
              BEFORE UPDATE \
              ON public.disruption \
              FOR EACH ROW \
              EXECUTE PROCEDURE log_disruption_update();')


def downgrade():
    op.execute('DROP TRIGGER last_disruption_changes on public.disruption')
    op.execute('DROP FUNCTION IF EXISTS log_disruption_update()')
    op.execute('DROP SCHEMA IF EXISTS history CASCADE')
