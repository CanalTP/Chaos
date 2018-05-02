"""Add indexes

Revision ID: 261846ff6570
Revises: 458134a1e5ea
Create Date: 2018-04-10 17:04:08.393359

"""

# revision identifiers, used by Alembic.
revision = '261846ff6570'
down_revision = '458134a1e5ea'

from alembic import op


def upgrade():
    op.create_index('ix_application_periods_start_date', 'application_periods', ['start_date'])
    op.create_index('ix_application_periods_end_date', 'application_periods', ['end_date'])
    op.create_index('ix_associate_impact_impact_id', 'associate_impact_pt_object', ['impact_id'])
    op.create_index('ix_associate_impact_pt_object_id', 'associate_impact_pt_object', ['pt_object_id'])
    op.create_index('ix_pt_object_uri', 'pt_object', ['uri'])
    op.create_index('ix_disruption_contributor_id', 'disruption', ['contributor_id'])
    op.create_index('ix_impact_disruption_id', 'impact', ['disruption_id'])
    op.create_index('ix_impact_severity_id', 'impact', ['severity_id'])
    op.create_index('ix_line_section_start_object_id', 'line_section', ['start_object_id'])
    op.create_index('ix_line_section_end_object_id', 'line_section', ['end_object_id'])
    op.create_index('ix_line_section_line_object_id', 'line_section', ['line_object_id'])
    op.create_index('ix_associate_line_section_route_line_section_id', 'associate_line_section_route_object', ['line_section_id'])
    op.create_index('ix_associate_line_section_route_route_object_id', 'associate_line_section_route_object', ['route_object_id'])
    op.create_index('ix_message_channel_id', 'message', ['channel_id'])
    op.create_index('ix_associate_wording_cause_wording_id', 'associate_wording_cause', ['wording_id'])
    op.create_index('ix_associate_wording_cause_cause_id', 'associate_wording_cause', ['cause_id'])


def downgrade():
    op.drop_index('ix_application_periods_start_date')
    op.drop_index('ix_application_periods_end_date')
    op.drop_index('ix_associate_impact_impact_id')
    op.drop_index('ix_associate_impact_pt_object_id')
    op.drop_index('ix_pt_object_uri')
    op.drop_index('ix_disruption_contributor_id')
    op.drop_index('ix_impact_disruption_id')
    op.drop_index('ix_impact_severity_id')
    op.drop_index('ix_line_section_start_object_id')
    op.drop_index('ix_line_section_end_object_id')
    op.drop_index('ix_line_section_line_object_id')
    op.drop_index('ix_associate_line_section_route_line_section_id')
    op.drop_index('ix_associate_line_section_route_route_object_id')
    op.drop_index('ix_message_channel_id')
    op.drop_index('ix_associate_wording_cause_wording_id')
    op.drop_index('ix_associate_wording_cause_cause_id')
