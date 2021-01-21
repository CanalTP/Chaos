"""Add timezone in pattern

Revision ID: 2d8031cd6452
Revises: 6b24727c1bb
Create Date: 2021-01-19 10:34:03.311940

"""

# revision identifiers, used by Alembic.
revision = '2d8031cd6452'
down_revision = '6b24727c1bb'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('pattern', sa.Column('timezone', sa.String(255), nullable=True))


def downgrade():
    op.drop_column('pattern', 'timezone')
