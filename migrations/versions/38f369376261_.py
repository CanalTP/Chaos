"""Add impacts to history

Revision ID: 38f369376261
Revises: d57921a3453
Create Date: 2019-05-02 10:42:00.011749

"""

# revision identifiers, used by Alembic.
revision = '38f369376261'
down_revision = 'd57921a3453'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    op.create_table('impact',
        sa.Column('id', sa.Integer(), nullable=False, autoincrement=True),
        sa.Column('disruption_id', sa.Integer(), nullable=False),
        sa.Column('impact_id', postgresql.UUID(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.Column('disruption_uuid', postgresql.UUID(), nullable=False),
        sa.Column('status', sa.Text(), nullable=False),
        sa.Column('severity_id', postgresql.UUID(), nullable=False),
        sa.Column('send_notifications', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('version', sa.Integer(), nullable=False),
        sa.Column('notification_date', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['disruption_id'], ['disruption.id']),
        schema='history'
    )
    op.create_table('associate_impact_pt_object',
        sa.Column('impact_id', postgresql.UUID(), nullable=True),
        sa.Column('pt_object_id', postgresql.UUID(), nullable=True),
        sa.Column('version', sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint('impact_id', 'pt_object_id', 'version'),
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
    op.execute('DROP TRIGGER IF EXISTS last_disruption_changes ON public.disruption; \
                    CREATE TRIGGER last_disruption_changes \
                    BEFORE UPDATE \
                    ON public.disruption \
                    FOR EACH ROW \
                    EXECUTE PROCEDURE log_disruption_update();')

def downgrade():
    op.drop_table('associate_impact_pt_object', schema='history'),
    op.drop_table('associate_disruption_impact', schema='history'),
    op.drop_table('impact', schema='history')
