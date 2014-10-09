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

from sqlalchemy import Column,  String, Integer, ForeignKey
from connectors.database.database import Base
from sqlalchemy.orm import relationship


class DisruptionEvent(Base):
    __tablename__ = 'disruptionevent'
    disruption_id = Column(String(50), primary_key=True)
    updated_at = Column(String(120), unique=False, nullable=True)
    impacts = relationship('Impact', backref='disruptionevent', lazy='joined')

    def __init__(self, disruption_id=None, updated_at=None):
        self.disruption_id = disruption_id
        self.updated_at = updated_at

    def __repr__(self):
        return '<DisruptionEvent %r>' % (self.disruption_id)

    @classmethod
    def get(cls, disruption_id):
        return cls.query.filter_by(disruption_id=disruption_id).first_or_404()


class Impact(Base):
    __tablename__ = 'impact'
    disruption_id = Column(String(50), ForeignKey(DisruptionEvent.disruption_id))
    id = Column(Integer, unique=False)
    chaos_id = Column(String(120), primary_key=True)
    updated_at = Column(String(120), unique=False, nullable=True)

    def __init__(self, disruption_id=None, updated_at=None, id=None, chaos_id=None):
        self.name = disruption_id
        self.updated_at = updated_at
        self.id = id
        self.chaos_id = chaos_id

    def __repr__(self):
        return '<Impact %r>' % (self.id)