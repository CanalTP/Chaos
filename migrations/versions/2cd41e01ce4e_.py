"""Create a table pattern and time_slot

Revision ID: 2cd41e01ce4e
Revises: 15efa48238d6
Create Date: 2015-01-27 14:59:08.791014

"""

# revision identifiers, used by Alembic.
revision = '2cd41e01ce4e'
down_revision = '15efa48238d6'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table('pattern',
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.Column('id', postgresql.UUID(), nullable=False),
    sa.Column('start_date', sa.DateTime(), nullable=True),
    sa.Column('end_date', sa.DateTime(), nullable=True),
    sa.Column('weekly_pattern', sa.Text(), nullable=False),
    sa.Column('impact_id', postgresql.UUID(), nullable=True),
    sa.ForeignKeyConstraint(['impact_id'], [u'impact.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_pattern_impact_id', 'pattern', ['impact_id'], unique=False)
    op.create_table('time_slot',
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.Column('id', postgresql.UUID(), nullable=False),
    sa.Column('begin', sa.Time(), nullable=True),
    sa.Column('end', sa.Time(), nullable=True),
    sa.Column('pattern_id', postgresql.UUID(), nullable=True),
    sa.ForeignKeyConstraint(['pattern_id'], [u'pattern.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_time_slot_pattern_id', 'time_slot', ['pattern_id'], unique=False)
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_index('ix_time_slot_pattern_id', 'time_slot')
    op.drop_table('time_slot')
    op.drop_index('ix_pattern_impact_id', 'pattern')
    op.drop_table('pattern')
    ### end Alembic commands ###