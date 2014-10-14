# encoding: utf-8

#  Copyright (c) 2001-2014, Canal TP and/or its affiliates. All rights reserved.
#
# This file is part of Navitia,
#     the software to build cool stuff with public transport.
#
# Hope you'll enjoy and contribute to this project,
#     powered by Canal TP (www.canaltp.fr).
# Help us simplify mobility and open public transport:
#     a non ending quest to the responsive locomotion way of traveling!
#
# LICENCE: This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Stay tuned using
# twitter @navitia
# IRC #navitia on freenode
# https://groups.google.com/d/forum/navitia
# www.navitia.io

from sqlalchemy import Column, Integer, ForeignKey, DateTime, Text
from connectors.database.database import Base
from sqlalchemy.orm import relationship
from sqlalchemy.orm.exc import NoResultFound


class DisruptionEvent(Base):
    __tablename__ = 'disruption_event'
    # Chaos.disruption.id
    disruption_id = Column(Text, primary_key=True)
    # Chaos.disruption.updated_at
    chaos_updated_at = Column(DateTime, unique=False, nullable=True)
    # Adjustit.event.impacts
    impacts = relationship('Impact', backref='disruption_event', lazy='joined')

    def __init__(self, disruption_id=None, chaos_updated_at=None):
        self.disruption_id = disruption_id
        self.chaos_updated_at = chaos_updated_at

    def __repr__(self):
        return '<DisruptionEvent %r>' % (self.disruption_id)

    @classmethod
    def get(cls, disruption_id):
        try:
            return cls.query.filter_by(disruption_id=disruption_id).one()
        except NoResultFound:
            raise


class Impact(Base):
    __tablename__ = 'impact'
    # Chaos.disruption.id
    disruption_id = Column(Text, ForeignKey(DisruptionEvent.disruption_id))

    adjustit_impact_id = Column(Integer, unique=False)
    # chaos.ptobject.uri + chaos.impact.id
    chaos_new_id = Column(Text, primary_key=True)
    #chaos.impact.updated_at
    chaos_updated_at = Column(DateTime, unique=False, nullable=True)

    def __init__(self, disruption_id=None, chaos_new_id=None, adjustit_impact_id=None, chaos_updated_at=None):
        self.disruption_id = disruption_id
        self.chaos_updated_at = chaos_updated_at
        self.adjustit_impact_id = adjustit_impact_id
        self.chaos_new_id = chaos_new_id

    def __repr__(self):
        return '<Impact %r>' % (self.adjustit_impact_id)
