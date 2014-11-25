"""Add a new column client_id

Revision ID: 3775ac5a659f
Revises: 2868b11faee4
Create Date: 2014-11-24 15:12:56.906818

"""

# revision identifiers, used by Alembic.
revision = '3775ac5a659f'
down_revision = '2868b11faee4'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table('client',
    sa.Column('created_at', sa.DateTime(), nullable=False),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.Column('id', postgresql.UUID(), nullable=False),
    sa.Column('client_code', sa.Text(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.add_column('severity', sa.Column('client_id', postgresql.UUID(), sa.ForeignKey('client.id')))
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('severity', 'client_id')
    op.drop_table('client')
    ### end Alembic commands ###
