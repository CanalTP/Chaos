"""Add rail section table

Revision ID: 5bf2d2bc5cb
Revises: 2d8031cd6452
Create Date: 2021-01-22 13:59:47.907869

"""

# revision identifiers, used by Alembic.
revision = '5bf2d2bc5cb'
down_revision = '2d8031cd6452'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    op.create_table('rail_section',
    sa.Column('id', postgresql.UUID(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.Column('line_object_id', postgresql.UUID(), nullable=True),
    sa.Column('start_object_id', postgresql.UUID(), nullable=False),
    sa.Column('end_object_id', postgresql.UUID(), nullable=False),
    sa.Column('blocked_stop_areas', sa.Text(), nullable=True),
    sa.Column('object_id', postgresql.UUID(), nullable=True),
    sa.ForeignKeyConstraint(['line_object_id'], [u'pt_object.id'], ),
    sa.ForeignKeyConstraint(['object_id'], [u'pt_object.id'], ),
    sa.ForeignKeyConstraint(['start_object_id'], [u'pt_object.id'], ),
    sa.ForeignKeyConstraint(['end_object_id'], [u'pt_object.id'], ),
    sa.PrimaryKeyConstraint('id')
    )

    op.create_table('associate_rail_section_route_object',
    sa.Column('rail_section_id', postgresql.UUID(), nullable=True),
    sa.Column('route_object_id', postgresql.UUID(), nullable=True),
    sa.ForeignKeyConstraint(['rail_section_id'], ['rail_section.id'], ),
    sa.ForeignKeyConstraint(['route_object_id'], ['pt_object.id'], ),
    sa.PrimaryKeyConstraint('rail_section_id', 'route_object_id', name='rail_section_route_object_pk')
    )

    op.execute("COMMIT")
    op.execute("ALTER TYPE pt_object_type ADD VALUE 'rail_section'")


def downgrade():
    op.drop_table('associate_rail_section_route_object')
    op.drop_table('rail_section')
    op.execute("ALTER TABLE pt_object ALTER COLUMN type TYPE text")
    op.execute("DELETE FROM associate_impact_pt_object WHERE pt_object_id IN (SELECT id FROM pt_object WHERE type='rail_section')")
    op.execute("DELETE FROM pt_object WHERE type='rail_section'")
    op.execute("DROP TYPE pt_object_type")
    op.execute("CREATE TYPE pt_object_type AS ENUM ('network', 'stop_area', 'line', 'line_section','route', 'stop_point')")
    op.execute("ALTER TABLE pt_object ALTER COLUMN type TYPE pt_object_type USING type::pt_object_type")
