"""Adding disruption version in history

Revision ID: 192476718432
Revises: 50f90e14e248
Create Date: 2019-06-04 16:58:11.378712

"""

# revision identifiers, used by Alembic.
revision = '192476718432'
down_revision = '50f90e14e248'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('disruption', sa.Column('version', sa.Integer(), nullable=False, server_default='1'), schema='history')


def downgrade():
    op.drop_column('disruption', 'version', schema='history')
