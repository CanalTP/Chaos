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
        sa.Column('impact_id', postgresql.UUID(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.Column('disruption_id', postgresql.UUID(), nullable=False),
        sa.Column('status', sa.Text(), nullable=False),
        sa.Column('severity_id', postgresql.UUID(), nullable=False),
        sa.Column('send_notifications', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('version', sa.Integer(), nullable=False),
        sa.Column('notification_date', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        schema='history'
    )
    op.create_table('associate_disruption_impact',
        sa.Column('disruption_id', sa.Integer(), nullable=False),
        sa.Column('impact_id', sa.Integer(), nullable=False),
        schema='history'
    )
    op.create_table('associate_impact_pt_object',
        sa.Column('impact_id', sa.Integer(), nullable=True),
        sa.Column('pt_object_id', postgresql.UUID(), nullable=True),
        sa.Column('version', sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint('impact_id', 'pt_object_id', 'version'),
        schema='history'
    )

def downgrade():
    op.drop_table('history.associate_impact_pt_object'),
    op.drop_table('history.associate_disruption_impact'),
    op.drop_table('history.impact')