"""Impact historization

Revision ID: 2b51c35f9879
Revises: d57921a3453
Create Date: 2019-05-07 15:23:52.884849

"""

# revision identifiers, used by Alembic.
revision = '2b51c35f9879'
down_revision = 'd57921a3453'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID


def upgrade():
    op.execute('DROP TRIGGER IF EXISTS last_disruption_changes on public.disruption')
    create_disruption_trigger = (
        'CREATE TRIGGER last_disruption_changes '
        '   AFTER UPDATE ON public.disruption '
        '       FOR EACH ROW EXECUTE PROCEDURE log_disruption_update()'
    )
    op.execute(create_disruption_trigger)

    op.create_table('impact',
                    sa.Column('created_at',                 sa.DateTime(),  nullable=False),
                    sa.Column('id',                         sa.Integer(),   nullable=False, autoincrement=True),
                    sa.Column('disruption_id',              sa.Integer(),   nullable=False),
                    sa.Column('public_created_at',          sa.DateTime(),  nullable=False),
                    sa.Column('public_updated_at',          sa.DateTime(),  nullable=True),
                    sa.Column('public_id',                  UUID(),         nullable=False),
                    sa.Column('public_disruption_id',       UUID(),         nullable=False),
                    sa.Column('public_status',              sa.Text(),      nullable=False),
                    sa.Column('public_severity_id',         UUID(),         nullable=True),
                    sa.Column('public_send_notifications',  sa.Boolean(),   nullable=False),
                    sa.Column('public_version',             sa.Integer(),   nullable=False),
                    sa.Column('public_notification_date',   sa.DateTime(),  nullable=True),
                    sa.PrimaryKeyConstraint('id'),
                    sa.ForeignKeyConstraint(['disruption_id'], ['history.disruption.id']),
                    schema='history'
                    )
    op.create_table('associate_impact_pt_object',
                    sa.Column('public_impact_id', UUID(), nullable=True),
                    sa.Column('public_pt_object_id', UUID(), nullable=True),
                    sa.Column('public_impact_version', sa.Integer(), nullable=False),
                    sa.PrimaryKeyConstraint('public_impact_id', 'public_pt_object_id', 'public_impact_version'),
                    schema='history'
                    )
    create_disruption_history_function = (
        'CREATE OR REPLACE FUNCTION history.handle_disruption_history_change_for_impacts() RETURNS TRIGGER '
        'AS $data$ '
        '   DECLARE '
        '       public_disruption_id uuid; '
        '   BEGIN '
        '   public_disruption_id = new.disruption_id; '
        '   INSERT INTO history.impact ('
        '            created_at,'
        '            disruption_id,'
        '            public_created_at,'
        '            public_updated_at,'
        '            public_id,'
        '            public_disruption_id,'
        '            public_status,'
        '            public_severity_id,'
        '            public_send_notifications,'
        '            public_version,'
        '            public_notification_date'
        '        ) '
        '            SELECT '
        '                NOW(),'
        '                NEW.id,'
        '                created_at,'
        '                updated_at,'
        '                id,'
        '                disruption_id,'
        '                status,'
        '                severity_id,'
        '                send_notifications,'
        '                version,'
        '                notification_date'
        '            FROM'
        '                public.impact'
        '            WHERE'
        '                public.impact.disruption_id = public_disruption_id'
        '        ;'
        '   RETURN NULL;'
        ' END;'
        ' $data$ LANGUAGE plpgsql;'
    )

    op.execute(create_disruption_history_function)

    create_disruption_history_trigger = (
        'CREATE TRIGGER handle_disruption_history_change_for_impacts '
        '   AFTER INSERT OR UPDATE ON history.disruption '
        '       FOR EACH ROW EXECUTE PROCEDURE history.handle_disruption_history_change_for_impacts()'
    )
    op.execute(create_disruption_history_trigger)


def downgrade():
    op.execute('DROP TRIGGER IF EXISTS last_disruption_changes on public.disruption')
    create_disruption_trigger = (
        'CREATE TRIGGER last_disruption_changes '
        '   BEFORE UPDATE ON public.disruption '
        '       FOR EACH ROW EXECUTE PROCEDURE log_disruption_update()'
    )
    op.execute(create_disruption_trigger)

    op.execute('DROP TRIGGER IF EXISTS handle_disruption_history_change_for_impacts ON history.disruption')
    op.execute('DROP FUNCTION IF EXISTS history.handle_disruption_history_change_for_impacts()')
    op.drop_table('impact', schema='history')
    op.drop_table('associate_impact_pt_object', schema='history')
