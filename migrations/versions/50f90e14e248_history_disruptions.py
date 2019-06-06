"""History disruptions

Revision ID: 50f90e14e248
Revises: d57921a3453
Create Date: 2019-05-23 12:12:07.972665

"""

# revision identifiers, used by Alembic.
revision = '50f90e14e248'
down_revision = 'd57921a3453'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


def upgrade():
    op.execute('DROP SCHEMA IF EXISTS history CASCADE')
    op.execute('DROP TRIGGER IF EXISTS last_disruption_changes on public.disruption')
    op.execute('DROP FUNCTION IF EXISTS log_disruption_update()')
    op.execute('CREATE SCHEMA history')

    op.create_table('disruption',
                    sa.Column('id', postgresql.UUID(), nullable=False),
                    sa.Column('disruption_id', postgresql.UUID(), nullable=False),
                    sa.Column('data', sa.Text(), nullable=False),
                    sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.current_timestamp()),
                    sa.PrimaryKeyConstraint('id'),
                    schema='history'
                    )


def downgrade():
    op.drop_table('disruption', schema='history')

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
    op.create_table('associate_disruption_tag',
                    sa.Column('tag_id', postgresql.UUID(), nullable=False),
                    sa.Column('disruption_id', postgresql.UUID(), nullable=False),
                    sa.Column('version', sa.Integer(), nullable=False),
                    sa.PrimaryKeyConstraint('tag_id', 'disruption_id', 'version'),
                    schema='history'
                    )
    op.create_table('associate_disruption_pt_object',
                    sa.Column('disruption_id', postgresql.UUID(), nullable=False),
                    sa.Column('pt_object_id', postgresql.UUID(), nullable=False),
                    sa.Column('version', sa.Integer(), nullable=False),
                    sa.PrimaryKeyConstraint('disruption_id', 'pt_object_id', 'version'),
                    schema='history'
                    )
    op.create_table('associate_disruption_property',
                    sa.Column('value', sa.Text(), nullable=False),
                    sa.Column('disruption_id', postgresql.UUID(), nullable=False),
                    sa.Column('property_id', postgresql.UUID(), nullable=False),
                    sa.Column('version', sa.Integer(), nullable=False),
                    sa.PrimaryKeyConstraint('disruption_id', 'property_id', 'value', 'version'),
                    schema='history'
                    )

    op.execute('CREATE OR REPLACE FUNCTION log_disruption_update() \
                      RETURNS trigger AS \
                    $BODY$ \
                    BEGIN \
                     INSERT INTO history.disruption(created_at,updated_at,disruption_id,reference,note,\
                        start_publication_date,end_publication_date,version,client_id,contributor_id,\
                        cause_id,status) \
                     VALUES(OLD.created_at,OLD.updated_at,OLD.id,OLD.reference,OLD.note,OLD.start_publication_date,\
                        OLD.end_publication_date,OLD.version,OLD.client_id,OLD.contributor_id,\
                        OLD.cause_id,OLD.status); \
                     INSERT INTO history.associate_disruption_tag(tag_id,disruption_id,version) \
                     SELECT tag_id,disruption_id,OLD.version FROM public.associate_disruption_tag WHERE disruption_id = OLD.id; \
                     INSERT INTO history.associate_disruption_pt_object(disruption_id,pt_object_id,version) \
                     SELECT disruption_id,pt_object_id,OLD.version FROM public.associate_disruption_pt_object WHERE disruption_id = OLD.id; \
                     INSERT INTO history.associate_disruption_property(value,disruption_id,property_id,version) \
                     SELECT value,disruption_id,property_id,OLD.version FROM public.associate_disruption_property WHERE disruption_id = OLD.id; \
                     RETURN NEW; \
                    END; \
                    $BODY$\
                    LANGUAGE plpgsql VOLATILE')

    op.execute('CREATE TRIGGER last_disruption_changes \
                  BEFORE UPDATE \
                  ON public.disruption \
                  FOR EACH ROW \
                  EXECUTE PROCEDURE log_disruption_update();')