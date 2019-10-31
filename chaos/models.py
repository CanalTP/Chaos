# encoding: utf-8

# Copyright (c) 2001-2014, Canal TP and/or its affiliates. All rights reserved.
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

import uuid
from chaos import db, utils, exceptions
from utils import paginate, get_current_time, uri_is_not_in_pt_object_filter
from sqlalchemy.dialects.postgresql import UUID, BIT
from datetime import datetime
from formats import publication_status_values, application_status_values
from sqlalchemy import or_, and_, between, bindparam, desc
from sqlalchemy.orm import aliased
from sqlalchemy.sql import text, func

#force the server to use UTC time for each connection checkouted from the pool
import sqlalchemy

@sqlalchemy.event.listens_for(sqlalchemy.pool.Pool, 'checkout')
def set_utc_on_connect(dbapi_con, connection_record, connection_proxy):
    c = dbapi_con.cursor()
    c.execute("SET timezone='utc'")
    c.close()


class TimestampMixin(object):
    created_at = db.Column(
        db.DateTime(),
        default=get_current_time,
        nullable=False
    )
    updated_at = db.Column(
        db.DateTime(),
        default=None,
        onupdate=get_current_time
    )


DisruptionStatus = db.Enum(
    'published',
    'archived',
    'draft',
    name='disruption_status'
)

SeverityEffect = db.Enum(
    'no_service',
    'reduced_service',
    'significant_delays',
    'detour',
    'additional_service',
    'modified_service',
    'other_effect',
    'unknown_effect',
    'stop_moved',
    name='severity_effect'
)

ImpactStatus = db.Enum('published', 'archived', name='impact_status')

PtObjectType = db.Enum(
    'network',
    'stop_area',
    'line',
    'line_section',
    'route',
    'stop_point',
    name='pt_object_type'
)

ChannelTypeEnum = db.Enum(
    'web',
    'sms',
    'email',
    'mobile',
    'notification',
    'twitter',
    'facebook',
    'title',
    'beacon'
)

ExportStatusEnum = db.Enum('waiting', 'handling', 'error', 'done')


class Client(TimestampMixin, db.Model):
    __tablename__ = 'client'
    id = db.Column(UUID, primary_key=True)
    client_code = db.Column(db.Text, unique=True, nullable=False)

    def __init__(self, code=None):
        self.id = str(uuid.uuid1())
        self.client_code = code

    @classmethod
    def get_by_code(cls, code):
        return cls.query.filter_by(client_code=code).first()

    @classmethod
    def get_or_create(cls, code):
        client = cls.query.filter_by(client_code=code).first()
        if not client:
            client = Client(code)
        return client


class Contributor(TimestampMixin, db.Model):
    __tablename__ = 'contributor'
    id = db.Column(UUID, primary_key=True)
    contributor_code = db.Column(db.Text, unique=True, nullable=False)

    def __init__(self, code=None):
        self.id = str(uuid.uuid1())
        self.contributor_code = code

    @classmethod
    def get_by_code(cls, code):
        return cls.query.filter_by(contributor_code=code).first()

    @classmethod
    def get_or_create(cls, code):
        contributor = cls.query.filter_by(contributor_code=code).first()
        if not contributor:
            contributor = Contributor(code)
        return contributor


associate_wording_severity = db.Table(
    'associate_wording_severity',
    db.metadata,
    db.Column('wording_id', UUID, db.ForeignKey('wording.id')),
    db.Column('severity_id', UUID, db.ForeignKey('severity.id')),
    db.PrimaryKeyConstraint(
        'wording_id',
        'severity_id',
        name='wording_severity_pk'
    )
)


class Severity(TimestampMixin, db.Model):
    """
    represent the severity of an impact
    """
    id = db.Column(UUID, primary_key=True)
    wording = db.Column(db.Text, unique=False, nullable=False)
    color = db.Column(db.Text, unique=False, nullable=True)
    is_visible = db.Column(
        db.Boolean, unique=False, nullable=False, default=True
    )
    priority = db.Column(db.Integer, unique=False, nullable=True)
    effect = db.Column(SeverityEffect, nullable=True)
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='severity')
    wordings = db.relationship(
        "Wording", secondary=associate_wording_severity, backref="severities"
    )

    def delete_wordings(self):
        index = len(self.wordings) - 1
        while index >= 0:
            wording = self.wordings[index]
            self.wordings.remove(wording)
            db.session.delete(wording)
            index -= 1

    def __init__(self):
        self.id = str(uuid.uuid1())
        self.effect = 'unknown_effect'

    def __repr__(self):
        return '<Severity %r>' % self.id

    @classmethod
    def all(cls, client_id):
        return cls.query.filter_by(
            client_id=client_id,
            is_visible=True
        ).order_by(cls.priority).all()

    @classmethod
    def get(cls, id, client_id):
        severity = cls.query.filter_by(
            id=id,
            client_id=client_id,
            is_visible=True
        ).first()

        if severity is None:
            raise exceptions.ObjectUnknown('The severty with id {} does not exist for this client'.format(id))

        return severity


class Category(TimestampMixin, db.Model):
    """
    represent the category of a cause
    """
    __tablename__ = 'category'
    id = db.Column(UUID, primary_key=True)
    name = db.Column(db.Text, unique=False, nullable=False)
    is_visible = db.Column(
        db.Boolean, unique=False, nullable=False, default=True
    )
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='categories')
    __table_args__ = (db.UniqueConstraint(
        'name', 'client_id', name='category_name_client_id_key'
    ),)

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Category %r>' % self.id

    @classmethod
    def all(cls, client_id):
        return cls.query.filter_by(
            client_id=client_id,
            is_visible=True
        ).order_by(cls.name).all()

    @classmethod
    def get(cls, id, client_id):
        return cls.query.filter_by(
            id=id,
            client_id=client_id,
            is_visible=True
        ).first_or_404()

    @classmethod
    def get_archived_by_name(cls, name, client_id):
        return cls.query.filter_by(
            name=name,
            client_id=client_id,
            is_visible=False
        ).first()


class Wording(TimestampMixin, db.Model):
    """
    represent the Wording of a cause
    """
    id = db.Column(UUID, primary_key=True)
    key = db.Column(db.Text, unique=False, nullable=False)
    value = db.Column(db.Text, unique=False, nullable=False)

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Wording %r>' % self.id


associate_wording_cause = db.Table(
    'associate_wording_cause',
    db.metadata,
    db.Column('wording_id', UUID, db.ForeignKey('wording.id')),
    db.Column('cause_id', UUID, db.ForeignKey('cause.id')),
    db.PrimaryKeyConstraint('wording_id', 'cause_id', name='wording_cause_pk')
)


class Cause(TimestampMixin, db.Model):
    """
    represent the cause of a disruption
    """
    id = db.Column(UUID, primary_key=True)
    # TODO A supprimer plus tard
    wording = db.Column(db.Text, unique=False, nullable=False)
    is_visible = db.Column(db.Boolean, unique=False, nullable=False, default=True)
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='causes')
    category_id = db.Column(UUID, db.ForeignKey(Category.id), nullable=True)
    category = db.relationship('Category', backref='causes', lazy='joined')
    wordings = db.relationship("Wording", secondary=associate_wording_cause, backref="causes")

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Cause %r>' % self.id

    @classmethod
    def all(cls, client_id, category_id=None):
        kargs = {"client_id": client_id,
                 "is_visible": True}
        if category_id:
            kargs["category_id"] = category_id
        return cls.query.filter_by(**kargs).all()

    @classmethod
    def get(cls, id, client_id, category_id=None):
        kargs = {"client_id": client_id,
                 "is_visible": True,
                 "id": id}
        if category_id:
            kargs["category_id"] = category_id
        return cls.query.filter_by(**kargs).first_or_404()

    def delete_wordings(self):
        index = len(self.wordings) - 1
        while index >= 0:
            wording = self.wordings[index]
            self.wordings.remove(wording)
            db.session.delete(wording)
            index -= 1


associate_disruption_tag = db.Table(
    'associate_disruption_tag',
    db.metadata,
    db.Column('tag_id', UUID, db.ForeignKey('tag.id')),
    db.Column('disruption_id', UUID, db.ForeignKey('disruption.id')),
    db.PrimaryKeyConstraint(
        'tag_id',
        'disruption_id',
        name='tag_disruption_pk'
    )
)


class Tag(TimestampMixin, db.Model):
    """
    represent the tag of a disruption
    """
    __tablename__ = 'tag'
    id = db.Column(UUID, primary_key=True)
    name = db.Column(db.Text, unique=False, nullable=False)
    is_visible = db.Column(db.Boolean, unique=False, nullable=False, default=True)
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='tags')
    __table_args__ = (db.UniqueConstraint('name', 'client_id', name='tag_name_client_id_key'),)

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Tag %r>' % self.id

    @classmethod
    def all(cls, client_id):
        return cls.query.filter_by(client_id=client_id, is_visible=True).all()

    @classmethod
    def get(cls, id, client_id):
        return cls.query.filter_by(id=id, client_id=client_id, is_visible=True).first_or_404()

    @classmethod
    def get_archived_by_name(cls, name, client_id):
        return cls.query.filter_by(name=name, client_id=client_id, is_visible=False).first()


associate_disruption_pt_object = db.Table(
    'associate_disruption_pt_object',
    db.metadata,
    db.Column('disruption_id', UUID, db.ForeignKey('disruption.id')),
    db.Column('pt_object_id', UUID, db.ForeignKey('pt_object.id')),
    db.PrimaryKeyConstraint(
        'disruption_id',
        'pt_object_id',
        name='disruption_pt_object_pk'
    )
)


class AssociateDisruptionProperty(db.Model):
    """
    links disruptions to properties
    """
    __tablename__ = 'associate_disruption_property'
    value = db.Column(db.Text, primary_key=True)
    disruption_id = db.Column(
        UUID,
        db.ForeignKey('disruption.id'),
        primary_key=True
    )
    property_id = db.Column(
        UUID,
        db.ForeignKey('property.id'),
        primary_key=True
    )
    property = db.relationship('Property', back_populates='disruptions')
    disruption = db.relationship('Disruption', back_populates='properties')

    @classmethod
    def get(cls, property_id, disruption_id, value):
        return cls.query.filter_by(
            property_id=property_id,
            disruption_id=disruption_id,
            value=value
        ).first()

    @classmethod
    def get_by_disruption(cls, disruption_id):
        return cls.query.filter_by(
            disruption_id=disruption_id
        ).all()

    def __repr__(self):
        return '<%s: %s %s %s>' % (
            self.__class__.__name__,
            self.property_id,
            self.disruption_id,
            self.value
        )


class Disruption(TimestampMixin, db.Model):
    __tablename__ = 'disruption'
    id = db.Column(UUID, primary_key=True)
    reference = db.Column(db.Text, unique=False, nullable=True)
    note = db.Column(db.Text, unique=False, nullable=True)
    status = db.Column(
        DisruptionStatus, nullable=False, default='published', index=True
    )
    start_publication_date = db.Column(db.DateTime(), nullable=True)
    end_publication_date = db.Column(db.DateTime(), nullable=True)
    impacts = db.relationship('Impact', backref='disruption', lazy='joined', cascade='delete')
    cause_id = db.Column(UUID, db.ForeignKey(Cause.id))
    cause = db.relationship('Cause', backref='disruption', lazy='joined')
    tags = db.relationship("Tag", secondary=associate_disruption_tag, backref="disruptions", lazy='joined')
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='disruptions')
    contributor_id = db.Column(UUID, db.ForeignKey(Contributor.id), nullable=False)
    contributor = db.relationship('Contributor', backref='disruptions', lazy='joined')
    version = db.Column(db.Integer, nullable=False, default=1)
    localizations = db.relationship("PTobject", secondary=associate_disruption_pt_object,
                                    backref="disruptions", lazy='joined')
    properties = db.relationship(
        'AssociateDisruptionProperty',
        lazy='joined',
        back_populates='disruption',
        cascade='delete'
    )
    author = db.Column(db.Text, unique=False, nullable=True)

    def __repr__(self):
        return '<Disruption %r>' % self.id

    def __init__(self):
        self.id = str(uuid.uuid1())

    def upgrade_version(self):
        self.version = self.version + 1

    def archive(self):
        """
        archive the disruption, it will not be visible on any media
        """
        self.status = 'archived'
        for impact in self.impacts:
            impact.archive()

    def is_published(self):
        return self.status == 'published'

    def is_draft(self):
        return self.status == 'draft'

    def is_last_impact(self, impact_id):
        nb_impacts = list(filter(lambda x: x.status != 'archived', self.impacts))
        return len(nb_impacts) == 1 and nb_impacts[0].id == impact_id

    @classmethod
    def get(cls, id, contributor_id):
        return cls.query.filter(
            (cls.id == id) and
            (cls.contributor == contributor_id) and
            (cls.status != 'archived')
        ).first_or_404()

    @classmethod
    def get_query_with_args(
            cls,
            contributor_id,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses,
            application_status=application_status_values,
            query=None,
            cause_category_id=None,
            current_time=None):
        if current_time is None: current_time = get_current_time()
        if (query is None):
            query = cls.query

        query = query.filter(and_(
            cls.contributor_id == contributor_id,
            cls.status.in_(statuses)
        ))

        if cause_category_id:
            query = query.join(cls.cause)
            query = query.filter(Cause.category_id == cause_category_id)

        if ends_after_date:
            query = query.filter(cls.end_publication_date >= ends_after_date)

        if ends_before_date:
            query = query.filter(cls.end_publication_date <= ends_before_date)

        if tags:
            query = query.filter(cls.tags.any(Tag.id.in_(tags)))

        if uri:
            query = query.join(cls.impacts)
            query = query.filter(Impact.status == 'published')
            query = query.join(Impact.objects)

            # Here add a new query to find impacts with line_section having uri as line
            if line_section:
                query_line_section = query
                query_line_section = query_line_section.filter(
                    and_(PTobject.type == "line_section", PTobject.uri.like(uri + ":%")))

            query = query.filter(PTobject.uri == uri)

        publication_availlable_filters = {
            'past': and_(cls.end_publication_date != None, cls.end_publication_date < current_time),
            'ongoing': and_(cls.start_publication_date <= current_time,
                            or_(cls.end_publication_date == None, cls.end_publication_date >= current_time)),
            'coming': Disruption.start_publication_date > current_time
        }
        publication_status = set(publication_status)
        if len(publication_status) == len(publication_status_values):
            # For a query by uri use union with the query for line_section
            if uri and line_section:
                query = query.union(query_line_section)

        else:
            filters = [publication_availlable_filters[status] for status in publication_status]
            query = query.filter(or_(*filters))

            # For a query by uri use union with the query for line_section
            if uri and line_section:
                query_line_section = query_line_section.filter(or_(*filters))
                query = query.union(query_line_section)

        application_status = set(application_status)
        if len(application_status) != len(application_status_values):
            query = query.join(cls.impacts)
            query = query.filter(Impact.status == 'published')
            query = query.join(Impact.application_periods)
            application_availlable_filters = {
                'past': ApplicationPeriods.end_date < current_time,
                'ongoing': and_(ApplicationPeriods.start_date <= current_time, ApplicationPeriods.end_date >= current_time),
                'coming': ApplicationPeriods.start_date > current_time
            }
            filters = [application_availlable_filters[status] for status in application_status]
            query = query.filter(or_(*filters))
        return query.order_by(cls.end_publication_date, cls.id)

    @classmethod
    @paginate()
    def all_with_post_filter(
            cls,
            contributor_id,
            application_status,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):
        if current_time is None: current_time = get_current_time()
        query = cls.query
        object_types = []
        uris = []
        line_section_uris = []
        if uri_is_not_in_pt_object_filter(uri=uri, pt_object_filter=ptObjectFilter):
            return cls.query.filter('1=0')
        if ptObjectFilter is not None:
            for key, objectIds in ptObjectFilter.iteritems():
                object_type = key[:-1]
                object_types.append(object_type)
                uris = uris + objectIds
                if object_type == 'line':
                    line_section_uris = [objectId + ':%' for objectId in objectIds]
                    line_section = False

            uris_filter = and_(
                cls.impacts.any(Impact.objects.any(PTobject.type.in_(object_types))),
                cls.impacts.any(Impact.objects.any(PTobject.uri.in_(uris)))
            )
            if len(line_section_uris):
                query = cls.query.filter(
                    or_(
                        uris_filter,
                        cls.impacts.any(Impact.objects.any(
                            or_(*[PTobject.uri.like(objectId) for objectId in line_section_uris])
                        ))
                    )
                )
            else:
                query = cls.query.filter(uris_filter)
        if application_period is not None:
            query = cls.query.filter(
                cls.impacts.any(Impact.application_periods.any(
                or_(
                    and_(
                        ApplicationPeriods.start_date >= application_period['begin'],
                        ApplicationPeriods.start_date <= application_period['end']
                    ),
                    and_(
                        ApplicationPeriods.end_date >= application_period['begin'],
                        ApplicationPeriods.end_date <= application_period['end']
                    ),
                    and_(
                        ApplicationPeriods.start_date <= application_period['begin'],
                        ApplicationPeriods.end_date >= application_period['end']
                    )
                )
            )))
        return cls.get_query_with_args(
            contributor_id=contributor_id,
            application_status=application_status,
            publication_status=publication_status,
            ends_after_date=ends_after_date,
            ends_before_date=ends_before_date,
            tags=tags,
            uri=uri,
            line_section=line_section,
            statuses=statuses,
            query=query,
            cause_category_id=cause_category_id,
            current_time=current_time
        )

    @classmethod
    def generate_disruption_search_query_args(cls,
                                              contributor_id,
                                              application_status,
                                              publication_status,
                                              ends_after_date,
                                              ends_before_date,
                                              tags,
                                              uri,
                                              line_section,
                                              statuses,
                                              ptObjectFilter,
                                              cause_category_id,
                                              application_period,
                                              current_time=None):
        if current_time is None: current_time = get_current_time()

        andwheres = []
        vars = {}
        bindparams = {}

        andwheres.append('d.contributor_id = :contributor_id')
        vars['contributor_id'] = contributor_id
        bindparams['contributor_id'] = db.String

        andwheres.append('d.status IN :disruption_status')
        vars['disruption_status'] = tuple(statuses)
        bindparams['disruption_status'] = db.String

        andwheres.append('i.status = :impact_status')
        vars['impact_status'] = 'published'
        bindparams['impact_status'] = db.String

        andwheres.append('c.is_visible = :cause_is_visisble')
        vars['cause_is_visisble'] = True
        bindparams['cause_is_visisble'] = db.Boolean

        if isinstance(uri, basestring) and uri:
            uri_filters = []
            uri_filters.append('po.uri = :uri')
            bindparams['uri'] = db.String
            vars['uri'] = uri
            if line_section:
                uri_filters.append('po.type = :po_type_line_section AND po.uri LIKE :uri_like')
                bindparams['po_type_line_section'] = db.String
                bindparams['uri_like'] = db.String
                vars['po_type_line_section'] = 'line_section'
                vars['uri_like'] = uri + ':%'
            andwheres.append('(' + ' OR '.join(uri_filters) + ')')
        elif ptObjectFilter is not None:
            uri_filters = []
            uri_filters.append('po.uri IN :pt_objects_uris')
            bindparams['pt_objects_uris'] = db.String
            vars['pt_objects_uris'] = tuple([id for ids in ptObjectFilter.itervalues() for id in ids])

            if line_section and 'lines' in ptObjectFilter:
                uri_filters.append('(po.type = :po_type_line_section AND po_line.uri IN :po_line_section_lines)')
                bindparams['po_type_line_section'] = db.String
                bindparams['po_line_section_lines'] = db.String
                vars['po_type_line_section'] = 'line_section'
                vars['po_line_section_lines'] = tuple(ptObjectFilter['lines'])
            andwheres.append('(' + ' OR '.join(uri_filters) + ')')

        if isinstance(cause_category_id, basestring) and cause_category_id:
            andwheres.append('c.category_id = :cause_category_id')
            bindparams['cause_category_id'] = db.String
            vars['cause_category_id'] = cause_category_id

        if isinstance(tags, list) and tags:
            andwheres.append('t.id IN :tag_ids')
            bindparams['tag_ids'] = db.String
            vars['tag_ids'] = tuple(tags)

        if ends_after_date:
            andwheres.append('d.end_publication_date >=:ends_after_date')
            bindparams['ends_after_date'] = db.Date
            vars['ends_after_date'] = ends_after_date

        if ends_before_date:
            andwheres.append('d.end_publication_date <=:ends_before_date')
            bindparams['ends_before_date'] = db.Date
            vars['ends_before_date'] = ends_before_date

        application_status = set(application_status)
        if len(application_status) != len(application_status_values):
            application_availlable_filters = {
                'past': 'ap.end_date < :current_time ',
                'ongoing': '(ap.start_date <= :current_time AND ap.end_date >= :current_time) ',
                'coming': 'ap.start_date > :current_time '
            }
            app_status_filters = [application_availlable_filters[status] for status in application_status]
            andwheres.append('(' + ' OR '.join(app_status_filters) + ')')
            bindparams['current_time'] = db.Date
            vars['current_time'] = current_time

        publication_status = set(publication_status)
        if len(publication_status) != len(publication_status_values):
            publication_availlable_filters = {
                'past': 'd.end_publication_date IS NOT NULL AND d.end_publication_date < :current_time',
                'ongoing': '(d.start_publication_date <= :current_time AND (d.end_publication_date IS NULL OR d.end_publication_date >= :current_time)) ',
                'coming': 'd.start_publication_date > :current_time',
            }
            publicationFilters = [publication_availlable_filters[status] for status in publication_status]
            andwheres.append('(' + ' OR '.join(publicationFilters) + ')')
            bindparams['current_time'] = db.Date
            vars['current_time'] = current_time

        if isinstance(application_period, dict) and 'begin' in application_period and 'end' in application_period:
            app_period_filters = []
            app_period_filters.append('(ap.start_date >= :ap_start_date AND ap.start_date <= :ap_end_date)')
            app_period_filters.append('(ap.end_date >= :ap_start_date AND ap.end_date <= :ap_end_date)')
            app_period_filters.append('(ap.start_date <= :ap_start_date AND ap.end_date >= :ap_end_date)')
            apDateFilter = ' OR '.join(app_period_filters)
            andwheres.append('(' + apDateFilter + ')')
            bindparams['ap_start_date'] = db.Date
            bindparams['ap_end_date'] = db.Date
            vars['ap_start_date'] = application_period['begin']
            vars['ap_end_date'] = application_period['end']

        return {
            'and_wheres': andwheres,
            'bindparams': bindparams,
            'vars': vars
        }

    @classmethod
    def get_disruption_search_native_query(cls, query_parts = []):

        join_tables = []
        join_tables.append('disruption AS d')
        join_tables.append('LEFT JOIN impact i ON (i.disruption_id = d.id)')
        join_tables.append('LEFT JOIN cause c ON (d.cause_id = c.id)')
        join_tables.append('LEFT JOIN category ctg ON (c.category_id = ctg.id)')
        join_tables.append('LEFT JOIN associate_wording_cause awc ON (c.id = awc.cause_id)')
        join_tables.append('LEFT JOIN severity AS s ON (s.id = i.severity_id)')
        join_tables.append('LEFT JOIN wording AS cw ON (awc.wording_id = cw.id)')
        join_tables.append('LEFT JOIN associate_wording_severity aws ON (s.id = aws.severity_id)')
        join_tables.append('LEFT JOIN wording AS sw ON (aws.wording_id = sw.id)')
        join_tables.append('LEFT JOIN contributor AS contrib ON (contrib.id = d.contributor_id)')
        join_tables.append('LEFT JOIN associate_disruption_tag adt ON (d.id = adt.disruption_id)')
        join_tables.append('LEFT JOIN tag t ON (t.id = adt.tag_id)')
        join_tables.append('LEFT JOIN associate_disruption_property AS adp ON (d.id = adp.disruption_id)')
        join_tables.append('LEFT JOIN property AS p ON (p.id = adp.property_id)')
        join_tables.append('LEFT JOIN associate_disruption_pt_object AS adpo ON (adpo.disruption_id = d.id)')
        join_tables.append('LEFT JOIN pt_object AS localization ON (localization.id = adpo.pt_object_id)')
        join_tables.append('LEFT JOIN associate_impact_pt_object AS aipto ON (aipto.impact_id = i.id)')
        join_tables.append('LEFT JOIN pt_object AS po ON (po.id = aipto.pt_object_id)')
        join_tables.append('LEFT JOIN application_periods AS ap ON (ap.impact_id = i.id)')
        join_tables.append('LEFT JOIN message AS m ON (m.impact_id = i.id)')
        join_tables.append('LEFT JOIN channel AS ch ON (m.channel_id = ch.id)')
        join_tables.append('LEFT JOIN channel_type AS cht ON (cht.channel_id = ch.id)')
        join_tables.append('LEFT JOIN associate_message_meta AS amm ON (amm.message_id = m.id)')
        join_tables.append('LEFT JOIN meta AS me ON (amm.meta_id = me.id)')
        join_tables.append('LEFT JOIN pattern AS pa ON (pa.impact_id = i.id)')
        join_tables.append('LEFT JOIN time_slot AS ts ON (ts.pattern_id = pa.id)')
        join_tables.append('LEFT JOIN line_section AS ls ON (po.id = ls.object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_line ON (po_line.id = ls.line_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_start ON (po_start.id = ls.start_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_end ON (po_end.id = ls.end_object_id)')
        join_tables.append('LEFT JOIN associate_line_section_route_object AS alsro ON (alsro.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_route ON (alsro.route_object_id = po_route.id)')
        join_tables.append('LEFT JOIN associate_line_section_via_object AS alsvo ON (alsvo.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_via ON (alsvo.stop_area_object_id = po_via.id)')
        join_tables.append('LEFT JOIN associate_wording_line_section AS awls ON (awls.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN wording AS awlsw ON (awls.wording_id = awlsw.id)')

        andwheres = [] if 'and_wheres' not in query_parts else query_parts['and_wheres']

        columns = ','.join(query_parts['select_columns'])
        tables = ' '.join(join_tables)
        wheres = ' AND '.join(andwheres)

        query = []
        query.append('SELECT %s FROM %s WHERE %s' % (columns, tables, wheres))

        if 'group_by' in query_parts:
            query.append('GROUP BY %s' % (','.join(query_parts['group_by'])))

        if 'order_by' in query_parts:
            query.append('ORDER BY %s' % (','.join(query_parts['order_by'])))

        if 'limit' in query_parts:
            query.append('LIMIT %s' % (query_parts['limit']))

        if 'offset' in query_parts:
            query.append('OFFSET %s' % (query_parts['offset']))

        return ' '.join(query)

    @classmethod
    def count_all_with_post_filter(
            cls,
            contributor_id,
            application_status,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):
        if uri_is_not_in_pt_object_filter(uri=uri, pt_object_filter=ptObjectFilter):
            return 0

        query_parts = cls.generate_disruption_search_query_args(
            contributor_id = contributor_id,
            application_status = application_status,
            publication_status = publication_status,
            ends_after_date = ends_after_date,
            ends_before_date = ends_before_date,
            tags = tags,
            uri = uri,
            line_section = line_section,
            statuses = statuses,
            ptObjectFilter = ptObjectFilter,
            cause_category_id = cause_category_id,
            application_period = application_period,
            current_time = current_time
        )

        query_parts['select_columns'] = ['COUNT(DISTINCT d.id) AS cnt']
        query = cls.get_disruption_search_native_query(query_parts)

        if not query:
            return 0

        stmt = text(query)

        for param_name, param_type in query_parts['bindparams'].iteritems():
            stmt = stmt.bindparams(bindparam(param_name, type_=param_type))

        result = db.engine.execute(stmt, query_parts['vars']).fetchone()

        return result['cnt']

    @classmethod
    def get_disruption_ids_with_post_filter_native(
            cls,
            page_index,
            items_per_page,
            contributor_id,
            application_status,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):
        query_parts = cls.generate_disruption_search_query_args(
            contributor_id = contributor_id,
            application_status = application_status,
            publication_status = publication_status,
            ends_after_date = ends_after_date,
            ends_before_date = ends_before_date,
            tags = tags,
            uri = uri,
            line_section = line_section,
            statuses = statuses,
            ptObjectFilter = ptObjectFilter,
            cause_category_id = cause_category_id,
            application_period = application_period,
            current_time = current_time
        )
        query_parts['select_columns'] = ['DISTINCT d.id, d.end_publication_date']
        query_parts['order_by'] = ['d.end_publication_date','d.id']
        query_parts['limit'] = ':limit'
        query_parts['offset'] = ':offset'

        query = cls.get_disruption_search_native_query(query_parts)

        if not query:
            return []

        stmt = text(query)

        for param_name, param_type in query_parts['bindparams'].iteritems():
            stmt = stmt.bindparams(bindparam(param_name, type_=param_type))

        stmt = stmt.bindparams(bindparam('limit', type_=db.Integer),
                               bindparam('offset', type_=db.Integer)
                               )

        vars = query_parts['vars']
        offset = (max(1, page_index) - 1) * items_per_page
        vars['limit'] = items_per_page
        vars['offset'] = offset

        return db.engine.execute(stmt, vars).fetchall()


    @classmethod
    def all_with_post_filter_native(
            cls,
            page_index,
            items_per_page,
            contributor_id,
            application_status,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):

        disruption_ids = cls.get_disruption_ids_with_post_filter_native(page_index,
            items_per_page,
            contributor_id,
            application_status,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time)

        if not disruption_ids :
            return []

        query_parts = cls.generate_disruption_search_query_args(
            contributor_id = contributor_id,
            application_status = application_status,
            publication_status = publication_status,
            ends_after_date = ends_after_date,
            ends_before_date = ends_before_date,
            tags = tags,
            uri = uri,
            line_section = line_section,
            statuses = statuses,
            ptObjectFilter = ptObjectFilter,
            cause_category_id = cause_category_id,
            application_period = application_period,
            current_time = current_time
        )

        query_parts['select_columns'] = [
                'd.id', 'd.reference', 'd.note', 'd.status', 'd.version', 'd.created_at', 'd.updated_at',
                'd.start_publication_date', 'd.end_publication_date', 'd.author',
                'i.id AS impact_id', 'i.created_at AS impact_created_at', 'i.updated_at AS impact_updated_at',
                'i.send_notifications AS impact_send_notifications', 'i.notification_date AS impact_notification_date',
                'c.id AS cause_id', 'c.created_at AS cause_created_at', 'c.updated_at AS cause_updated_at',
                'ctg.id AS cause_category_id', 'ctg.name AS cause_category_name', 'ctg.created_at AS cause_category_created_at',
                'ctg.updated_at AS cause_category_updated_at', 'cw.id AS cause_wording_id', 'cw.key AS cause_wording_key',
                'cw.value AS cause_wording_value', 's.created_at AS severity_created_at', 's.updated_at AS severity_updated_at',
                's.id AS severity_id', 's.wording AS severity_wording', 's.color AS severity_color', 's.is_visible AS severity_is_visible',
                's.priority AS severity_priority', 's.effect AS severity_effect', 's.client_id AS severity_client_id',
                'sw.id AS severity_wording_id', 'sw.key AS severity_wording_key', 'sw.value AS severity_wording_value',
                'contrib.contributor_code AS contributor_code', 't.id AS tag_id', 't.name AS tag_name', 't.created_at AS tag_created_at',
                't.updated_at AS tag_updated_at', 'p.id AS property_id', 'p.key AS property_key', 'p.type AS property_type',
                'adp.value AS property_value', 'p.created_at AS property_created_at', 'p.updated_at AS property_updated_at',
                'localization.uri AS localization_uri', 'localization.type AS localization_type', 'localization.id AS localization_id',
                'po.id AS pt_object_id', 'po.type AS pt_object_type', 'po.uri AS pt_object_uri', 'ap.id AS application_period_id',
                'ap.start_date AS application_period_start_date', 'ap.end_date AS application_period_end_date',
                'm.id AS message_id', 'm.created_at AS message_created_at', 'm.updated_at AS message_updated_at',
                'm.text AS message_text', 'ch.id AS channel_id', 'ch.content_type AS channel_content_type',
                'ch.created_at AS channel_created_at', 'ch.updated_at AS channel_updated_at', 'ch.max_size AS channel_max_size',
                'ch.name AS channel_name', 'ch.required AS channel_required', 'cht.id AS channel_type_id', 'cht.name AS channel_type_name',
                'me.id AS meta_id', 'me.key AS meta_key', 'me.value AS meta_value',
                'pa.id AS pattern_id, pa.start_date AS pattern_start_date, pa.end_date AS pattern_end_date, pa.weekly_pattern AS pattern_weekly_pattern',
                'ts.id AS time_slot_id, ts.begin AS time_slot_begin, ts.end AS time_slot_end',
                'ls.id AS line_section_id, ls.sens AS line_section_sens',
                'po_line.uri AS line_section_line_uri, po_line.type AS line_section_line_type',
                'po_start.uri AS line_section_start_uri, po_start.type AS line_section_start_type',
                'po_end.uri AS line_section_end_uri, po_end.type AS line_section_end_type',
                'po_route.id AS po_route_id, po_route.uri AS po_route_uri, po_route.type AS po_route_type',
                'awlsw.id AS awlsw_id, awlsw.key AS awlsw_key, awlsw.value AS awlsw_value',
                'po_via.id AS po_via_id, po_via.uri AS po_via_uri, po_via.type AS po_via_type'
            ]
        query_parts['and_wheres'].append('d.id IN :disruption_ids')
        query_parts['order_by'] = ['d.end_publication_date','d.id', 'po.type','po.uri']

        query = cls.get_disruption_search_native_query(query_parts)

        stmt = text(query)
        stmt = stmt.bindparams(bindparam('disruption_ids', type_=db.String))

        vars = query_parts['vars']
        vars['disruption_ids'] = tuple([d[0] for d in disruption_ids])

        return db.engine.execute(stmt, vars).fetchall()

    @classmethod
    def __get_history_query_parts(cls):
        query_parts = {}
        query_parts['select_columns'] = [
            'd.id', 'd.reference', 'd.note', 'd.status', 'd.version', 'd.created_at', 'd.updated_at',
            'd.start_publication_date', 'd.end_publication_date, d.author,',
            'i.id AS impact_id', 'i.created_at AS impact_created_at', 'i.updated_at AS impact_updated_at',
            'i.send_notifications AS impact_send_notifications', 'i.notification_date AS impact_notification_date',
            'c.id AS cause_id', 'c.created_at AS cause_created_at', 'c.updated_at AS cause_updated_at',
            'ctg.id AS cause_category_id', 'ctg.name AS cause_category_name',
            'ctg.created_at AS cause_category_created_at',
            'ctg.updated_at AS cause_category_updated_at', 'cw.id AS cause_wording_id', 'cw.key AS cause_wording_key',
            'cw.value AS cause_wording_value', 's.created_at AS severity_created_at',
            's.updated_at AS severity_updated_at',
            's.id AS severity_id', 's.wording AS severity_wording', 's.color AS severity_color',
            's.is_visible AS severity_is_visible',
            's.priority AS severity_priority', 's.effect AS severity_effect', 's.client_id AS severity_client_id',
            'sw.id AS severity_wording_id', 'sw.key AS severity_wording_key', 'sw.value AS severity_wording_value',
            'contrib.contributor_code AS contributor_code', 't.id AS tag_id', 't.name AS tag_name',
            't.created_at AS tag_created_at',
            't.updated_at AS tag_updated_at', 'p.id AS property_id', 'p.key AS property_key', 'p.type AS property_type',
            'adp.value AS property_value', 'p.created_at AS property_created_at', 'p.updated_at AS property_updated_at',
            'localization.uri AS localization_uri', 'localization.type AS localization_type',
            'localization.id AS localization_id',
            'po.id AS pt_object_id', 'po.type AS pt_object_type', 'po.uri AS pt_object_uri',
            'ap.id AS application_period_id',
            'ap.start_date AS application_period_start_date', 'ap.end_date AS application_period_end_date',
            'm.id AS message_id', 'm.created_at AS message_created_at', 'm.updated_at AS message_updated_at',
            'm.text AS message_text', 'ch.id AS channel_id', 'ch.content_type AS channel_content_type',
            'ch.created_at AS channel_created_at', 'ch.updated_at AS channel_updated_at',
            'ch.max_size AS channel_max_size',
            'ch.name AS channel_name', 'ch.required AS channel_required', 'cht.id AS channel_type_id',
            'cht.name AS channel_type_name',
            'me.id AS meta_id', 'me.key AS meta_key', 'me.value AS meta_value',
            'pa.id AS pattern_id, pa.start_date AS pattern_start_date, pa.end_date AS pattern_end_date, pa.weekly_pattern AS pattern_weekly_pattern',
            'ts.id AS time_slot_id, ts.begin AS time_slot_begin, ts.end AS time_slot_end',
            'ls.id AS line_section_id, ls.sens AS line_section_sens',
            'po_line.uri AS line_section_line_uri, po_line.type AS line_section_line_type',
            'po_start.uri AS line_section_start_uri, po_start.type AS line_section_start_type',
            'po_end.uri AS line_section_end_uri, po_end.type AS line_section_end_type',
            'po_route.id AS po_route_id, po_route.uri AS po_route_uri, po_route.type AS po_route_type',
            'awlsw.id AS awlsw_id, awlsw.key AS awlsw_key, awlsw.value AS awlsw_value',
            'po_via.id AS po_via_id, po_via.uri AS po_via_uri, po_via.type AS po_via_type'
        ]
        query_parts['order_by'] = ['d.version']
        return query_parts

    @classmethod
    def __get_history_join_tables(cls):
        join_tables = []
        join_tables.append('(SELECT * FROM (' \
                           ' SELECT created_at, updated_at,id,reference,note,start_publication_date,end_publication_date,version,client_id,contributor_id,cause_id,status::text,author FROM public.disruption WHERE public.disruption.id = :disruption_id UNION' \
                           ' SELECT created_at, updated_at,disruption_id as id,reference,note,start_publication_date,end_publication_date,version,client_id,contributor_id,cause_id,status,author FROM history.disruption WHERE history.disruption.disruption_id = :disruption_id'\
                           ') AS disruption_union ORDER BY version, updated_at) AS d')
        join_tables.append('LEFT JOIN impact i ON (i.disruption_id = d.id)')
        join_tables.append('LEFT JOIN cause c ON (d.cause_id = c.id)')
        join_tables.append('LEFT JOIN category ctg ON (c.category_id = ctg.id)')
        join_tables.append('LEFT JOIN associate_wording_cause awc ON (c.id = awc.cause_id)')
        join_tables.append('LEFT JOIN severity AS s ON (s.id = i.severity_id)')
        join_tables.append('LEFT JOIN wording AS cw ON (awc.wording_id = cw.id)')
        join_tables.append('LEFT JOIN associate_wording_severity aws ON (s.id = aws.severity_id)')
        join_tables.append('LEFT JOIN wording AS sw ON (aws.wording_id = sw.id)')
        join_tables.append('LEFT JOIN contributor AS contrib ON (contrib.id = d.contributor_id)')
        join_tables.append('LEFT JOIN (SELECT * FROM (' \
                           ' SELECT tag_id, disruption_id, version FROM public.associate_disruption_tag INNER JOIN public.disruption ON (public.associate_disruption_tag.disruption_id = :disruption_id AND' \
                           ' public.associate_disruption_tag.disruption_id = public.disruption.id) UNION' \
                           ' SELECT tag_id, disruption_id, version FROM history.associate_disruption_tag where history.associate_disruption_tag.disruption_id = :disruption_id) AS disruption_tag_union' \
                           ') AS adt ON (d.id = adt.disruption_id AND d.version=adt.version)')
        join_tables.append('LEFT JOIN tag t ON (t.id = adt.tag_id)')
        join_tables.append('LEFT JOIN (SELECT * FROM (' \
                           ' SELECT value, disruption_id, property_id, version FROM public.associate_disruption_property INNER JOIN public.disruption ON (public.associate_disruption_property.disruption_id = :disruption_id AND' \
                           ' public.associate_disruption_property.disruption_id = public.disruption.id) UNION' \
                           ' SELECT value, disruption_id, property_id, version FROM history.associate_disruption_property where history.associate_disruption_property.disruption_id = :disruption_id) AS disruption_tag_union' \
                           ') AS adp ON (d.id = adp.disruption_id AND d.version=adp.version)')
        join_tables.append('LEFT JOIN property AS p ON (p.id = adp.property_id)')
        join_tables.append('LEFT JOIN (SELECT * FROM (' \
                           ' SELECT disruption_id, pt_object_id, version FROM public.associate_disruption_pt_object INNER JOIN public.disruption ON (public.associate_disruption_pt_object.disruption_id = :disruption_id AND' \
                           ' public.associate_disruption_pt_object.disruption_id = public.disruption.id) UNION' \
                           ' SELECT disruption_id, pt_object_id, version FROM history.associate_disruption_pt_object where history.associate_disruption_pt_object.disruption_id = :disruption_id) AS disruption_pt_object_union' \
                           ') AS adpo ON (adpo.disruption_id = d.id AND d.version=adpo.version)')
        join_tables.append('LEFT JOIN pt_object AS localization ON (localization.id = adpo.pt_object_id)')
        join_tables.append('LEFT JOIN associate_impact_pt_object AS aipto ON (aipto.impact_id = i.id)')
        join_tables.append('LEFT JOIN pt_object AS po ON (po.id = aipto.pt_object_id)')
        join_tables.append('LEFT JOIN application_periods AS ap ON (ap.impact_id = i.id)')
        join_tables.append('LEFT JOIN message AS m ON (m.impact_id = i.id)')
        join_tables.append('LEFT JOIN channel AS ch ON (m.channel_id = ch.id)')
        join_tables.append('LEFT JOIN channel_type AS cht ON (cht.channel_id = ch.id)')
        join_tables.append('LEFT JOIN associate_message_meta AS amm ON (amm.message_id = m.id)')
        join_tables.append('LEFT JOIN meta AS me ON (amm.meta_id = me.id)')
        join_tables.append('LEFT JOIN pattern AS pa ON (pa.impact_id = i.id)')
        join_tables.append('LEFT JOIN time_slot AS ts ON (ts.pattern_id = pa.id)')
        join_tables.append('LEFT JOIN line_section AS ls ON (po.id = ls.object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_line ON (po_line.id = ls.line_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_start ON (po_start.id = ls.start_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_end ON (po_end.id = ls.end_object_id)')
        join_tables.append('LEFT JOIN associate_line_section_route_object AS alsro ON (alsro.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_route ON (alsro.route_object_id = po_route.id)')
        join_tables.append('LEFT JOIN associate_line_section_via_object AS alsvo ON (alsvo.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_via ON (alsvo.stop_area_object_id = po_via.id)')
        join_tables.append('LEFT JOIN associate_wording_line_section AS awls ON (awls.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN wording AS awlsw ON (awls.wording_id = awlsw.id)')
        return join_tables

    @classmethod
    def get_history_by_id(cls, disruption_id):
        query_parts = cls.__get_history_query_parts()
        join_tables = cls.__get_history_join_tables()
        columns = ','.join(query_parts['select_columns'])
        tables = ' '.join(join_tables)
        order = ','.join(query_parts['order_by'])

        query = 'SELECT %s FROM %s ORDER BY %s' % (columns, tables, order)

        stmt = text(query)
        stmt = stmt.bindparams(bindparam('disruption_id', type_=db.String))
        vars = {}
        vars['disruption_id'] = disruption_id

        return db.engine.execute(stmt, vars)


    @classmethod
    @paginate()
    def all_with_filter(
            cls,
            contributor_id,
            publication_status,
            ends_after_date,
            ends_before_date,
            tags,
            uri,
            line_section,
            statuses):

        return cls.get_query_with_args(
            contributor_id=contributor_id,
            publication_status=publication_status,
            ends_after_date=ends_after_date,
            ends_before_date=ends_before_date,
            tags=tags,
            uri=uri,
            line_section=line_section,
            statuses=statuses
        )

    @property
    def publication_status(self):
        current_time = utils.get_current_time()
        # Past
        if (self.end_publication_date != None) and (self.end_publication_date < current_time):
            return "past"
        # ongoing
        if self.start_publication_date <= current_time\
                and (self.end_publication_date == None or self.end_publication_date >= current_time):
            return "ongoing"
        # Coming
        if self.start_publication_date > current_time:
            return "coming"

    @classmethod
    def traffic_report_filter(cls, contributor_id):
        query = cls.query.filter(cls.status == 'published')
        query = query.filter(cls.contributor_id == contributor_id)
        query = query.filter(
            between(get_current_time(), cls.start_publication_date, cls.end_publication_date))
        return query.all()


associate_impact_pt_object = db.Table(
    'associate_impact_pt_object',
    db.metadata,
    db.Column('impact_id', UUID, db.ForeignKey('impact.id')),
    db.Column('pt_object_id', UUID, db.ForeignKey('pt_object.id')),
    db.PrimaryKeyConstraint(
        'impact_id',
        'pt_object_id',
        name='impact_pt_object_pk'
    )
)


class Impact(TimestampMixin, db.Model):
    id = db.Column(UUID, primary_key=True)
    status = db.Column(ImpactStatus, nullable=False, default='published', index=True)
    disruption_id = db.Column(UUID, db.ForeignKey(Disruption.id))
    severity_id = db.Column(UUID, db.ForeignKey(Severity.id))
    messages = db.relationship('Message', backref='impact', lazy='joined', cascade='delete')
    application_periods = db.relationship('ApplicationPeriods', backref='impact', lazy='joined', cascade='delete')
    severity = db.relationship('Severity', backref='impacts', lazy='joined')
    objects = db.relationship("PTobject", secondary=associate_impact_pt_object,
                              lazy='joined', order_by="PTobject.type, PTobject.uri")
    patterns = db.relationship('Pattern', backref='impact', lazy='joined', cascade='delete')
    send_notifications = db.Column(db.Boolean, unique=False, nullable=False, default=False)
    version = db.Column(db.Integer, nullable=False, default=1)
    notification_date = db.Column(db.DateTime(), default=None, nullable=True)

    def __repr__(self):
        return '<Impact %r>' % self.id

    def __marshallable__(self):
        '''
        This method is added to solve the problem of impact without instance during creation of response json for Post..
        API post cannot fill url for impact and disruption in impact_fields
        When we have either one of them present in impact_fields, it works.
        '''
        d = {}
        d['id'] = self.id
        d['status'] = self.status
        d['disruption_id'] = self.disruption_id
        d['severity_id'] = self.severity_id
        d['objects'] = self.objects
        d['application_periods'] = self.application_periods
        d['severity'] = self.severity
        d['messages'] = self.messages
        d['application_period_patterns'] = self.patterns
        d['send_notifications'] = self.send_notifications
        d['notification_date'] = self.notification_date
        return d

    def __init__(self, objects=None):
        self.id = str(uuid.uuid1())

    def archive(self):
        """
        archive the impact, it will not be visible on any media
        """
        self.status = 'archived'

    def insert_object(self, object):
        """
        Adds an objectTC in a imapct.
        """
        self.objects.append(object)
        db.session.add(object)

    def upgrade_version(self):
        self.version = self.version + 1

    def insert_message(self, message):
        """
        Adds an message in a imapct.
        """
        self.messages.append(message)
        db.session.add(message)

    def delete_message(self, message):
        """
        delete a message in an impact.
        """
        self.messages.remove(message)
        db.session.delete(message)

    def delete_app_periods(self):
        for app_per in self.application_periods:
            db.session.delete(app_per)

    def delete_line_section(self):
        for pt_object in self.objects:
            if pt_object.type == 'line_section':
                line_section = LineSection.get_by_object_id(pt_object.id)
                if line_section:
                    db.session.delete(line_section)
                self.delete(pt_object)
                db.session.delete(pt_object)

    def insert_app_period(self, application_period):
        """
        Adds an ApplicationPeriods in a impact.
        """
        self.application_periods.append(application_period)
        db.session.add(application_period)

    def delete_patterns(self):
        for i in range(len(self.patterns), 0, -1):
            pattern = self.patterns[i - 1]
            pattern.delete_time_slots()
            self.patterns.remove(pattern)
            db.session.delete(pattern)

    def insert_pattern(self, pattern):
        """
        Adds a pattern of ApplicationPeriods in a impact.
        """
        self.patterns.append(pattern)
        db.session.add(pattern)

    @classmethod
    def get(cls, id, contributor_id):
        query = cls.query.filter_by(id=id, status='published')
        query = query.join(Disruption)
        query = query.filter(Disruption.contributor_id == contributor_id)
        return query.first_or_404()

    @classmethod
    @paginate()
    def all(cls, disruption_id, contributor_id):
        alias = aliased(Severity)
        query = cls.query.filter_by(status='published')
        query = query.filter(and_(cls.disruption_id == disruption_id))
        query = query.join(Disruption)
        query = query.filter(Disruption.contributor_id == contributor_id)
        return query.join(alias, Impact.severity).order_by(alias.priority)

    @classmethod
    def all_with_filter(cls, start_date, end_date, pt_object_type, uris, contributor_id):
        filter_with_line_section = True
        pt_object_alias = aliased(PTobject)
        query = cls.query.filter(cls.status == 'published')
        query = query.join(Disruption)
        query = query.join(ApplicationPeriods)
        query = query.join(pt_object_alias, cls.objects)
        query = query.filter(Disruption.contributor_id == contributor_id)
        query = query.filter(and_(ApplicationPeriods.start_date <= end_date, ApplicationPeriods.end_date >= start_date))
        query_line_section = query
        if pt_object_type or uris:
            alias_line = aliased(PTobject)
            alias_start_point = aliased(PTobject)
            alias_end_point = aliased(PTobject)
            alias_route = aliased(PTobject)
            alias_via = aliased(PTobject)

            query_line_section = query_line_section.filter(pt_object_alias.type == 'line_section')
            query_line_section = query_line_section.join(pt_object_alias.line_section)
            query_line_section = query_line_section.join(alias_line, LineSection.line_object_id == alias_line.id)
            query_line_section = query_line_section.join(
                alias_start_point, LineSection.start_object_id == alias_start_point.id)
            query_line_section = query_line_section.join(
                alias_end_point, LineSection.end_object_id == alias_end_point.id)
            query_line_section = query_line_section.outerjoin(alias_route, LineSection.routes)
            query_line_section = query_line_section.outerjoin(alias_via, LineSection.via)
        else:
            filter_with_line_section = False

        if pt_object_type:
            query = query.filter(pt_object_alias.type == pt_object_type)
            if pt_object_type == 'route':
                query_line_section = query_line_section.filter(alias_route.type == pt_object_type)
            elif pt_object_type not in ['line_section', 'line', 'stop_area']:
                filter_with_line_section = False

        if uris:
            query = query.filter(pt_object_alias.uri.in_(uris))
            uri_filters = []
            uri_filters.append(alias_line.uri.in_(uris))
            uri_filters.append(alias_start_point.uri.in_(uris))
            uri_filters.append(alias_end_point.uri.in_(uris))
            uri_filters.append(alias_route.uri.in_(uris))
            uri_filters.append(alias_via.uri.in_(uris))
            query_line_section = query_line_section.filter(or_(*uri_filters))

        if filter_with_line_section:
            query = query.union_all(query_line_section)
        query = query.order_by("application_periods_1.start_date")
        return query.all()

    @classmethod
    def generate_impacts_search_query_args(cls,
                                              contributor_id,
                                              application_status,
                                              ptObjectFilter,
                                              cause_category_id,
                                              application_period,
                                              current_time=None):
        if current_time is None: current_time = get_current_time()

        andwheres = []
        vars = {}
        bindparams = {}

        andwheres.append('d.contributor_id = :contributor_id')
        vars['contributor_id'] = contributor_id
        bindparams['contributor_id'] = db.String

        andwheres.append('i.status = :impact_status')
        vars['impact_status'] = 'published'
        bindparams['impact_status'] = db.String

        andwheres.append('c.is_visible = :cause_is_visisble')
        vars['cause_is_visisble'] = True
        bindparams['cause_is_visisble'] = db.Boolean

        if ptObjectFilter is not None:
            uri_filters = []
            uri_filters.append('po.uri IN :pt_objects_uris')
            bindparams['pt_objects_uris'] = db.String
            vars['pt_objects_uris'] = tuple([id for ids in ptObjectFilter.itervalues() for id in ids])

            if 'lines' in ptObjectFilter:
                uri_filters.append('(po.type = :po_type_line_section AND po_line.uri IN :po_line_section_lines)')
                bindparams['po_type_line_section'] = db.String
                bindparams['po_line_section_lines'] = db.String
                vars['po_type_line_section'] = 'line_section'
                vars['po_line_section_lines'] = tuple(ptObjectFilter['lines'])
            andwheres.append('(' + ' OR '.join(uri_filters) + ')')

        if isinstance(cause_category_id, basestring) and cause_category_id:
            andwheres.append('c.category_id = :cause_category_id')
            bindparams['cause_category_id'] = db.String
            vars['cause_category_id'] = cause_category_id

        application_status = set(application_status)
        if len(application_status) != len(application_status_values):
            application_availlable_filters = {
                'past': 'ap.end_date < :current_time ',
                'ongoing': '(ap.start_date <= :current_time AND ap.end_date >= :current_time) ',
                'coming': 'ap.start_date > :current_time '
            }
            app_status_filters = [application_availlable_filters[status] for status in application_status]
            andwheres.append('(' + ' OR '.join(app_status_filters) + ')')
            bindparams['current_time'] = db.Date
            vars['current_time'] = current_time

        if isinstance(application_period, dict) and 'begin' in application_period and 'end' in application_period:
            app_period_filters = []
            app_period_filters.append('(ap.start_date >= :ap_start_date AND ap.start_date <= :ap_end_date)')
            app_period_filters.append('(ap.end_date >= :ap_start_date AND ap.end_date <= :ap_end_date)')
            app_period_filters.append('(ap.start_date <= :ap_start_date AND ap.end_date >= :ap_end_date)')
            apDateFilter = ' OR '.join(app_period_filters)
            andwheres.append('(' + apDateFilter + ')')
            bindparams['ap_start_date'] = db.Date
            bindparams['ap_end_date'] = db.Date
            vars['ap_start_date'] = application_period['begin']
            vars['ap_end_date'] = application_period['end']

        return {
            'and_wheres': andwheres,
            'bindparams': bindparams,
            'vars': vars
        }

    @classmethod
    def get_impacts_search_native_query(cls, query_parts=[]):

        join_tables = []
        join_tables.append('disruption AS d')
        join_tables.append('LEFT JOIN impact i ON (i.disruption_id = d.id)')
        join_tables.append('LEFT JOIN cause c ON (d.cause_id = c.id)')
        join_tables.append('LEFT JOIN category ctg ON (c.category_id = ctg.id)')
        join_tables.append('LEFT JOIN associate_wording_cause awc ON (c.id = awc.cause_id)')
        join_tables.append('LEFT JOIN severity AS s ON (s.id = i.severity_id)')
        join_tables.append('LEFT JOIN wording AS cw ON (awc.wording_id = cw.id)')
        join_tables.append('LEFT JOIN associate_wording_severity aws ON (s.id = aws.severity_id)')
        join_tables.append('LEFT JOIN wording AS sw ON (aws.wording_id = sw.id)')
        join_tables.append('LEFT JOIN contributor AS contrib ON (contrib.id = d.contributor_id)')
        join_tables.append('LEFT JOIN associate_impact_pt_object AS aipto ON (aipto.impact_id = i.id)')
        join_tables.append('LEFT JOIN pt_object AS po ON (po.id = aipto.pt_object_id)')
        join_tables.append('LEFT JOIN application_periods AS ap ON (ap.impact_id = i.id)')
        join_tables.append('LEFT JOIN message AS m ON (m.impact_id = i.id)')
        join_tables.append('LEFT JOIN channel AS ch ON (m.channel_id = ch.id)')
        join_tables.append('LEFT JOIN channel_type AS cht ON (cht.channel_id = ch.id)')
        join_tables.append('LEFT JOIN associate_message_meta AS amm ON (amm.message_id = m.id)')
        join_tables.append('LEFT JOIN meta AS me ON (amm.meta_id = me.id)')
        join_tables.append('LEFT JOIN pattern AS pa ON (pa.impact_id = i.id)')
        join_tables.append('LEFT JOIN time_slot AS ts ON (ts.pattern_id = pa.id)')
        join_tables.append('LEFT JOIN line_section AS ls ON (po.id = ls.object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_line ON (po_line.id = ls.line_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_start ON (po_start.id = ls.start_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_end ON (po_end.id = ls.end_object_id)')
        join_tables.append('LEFT JOIN associate_line_section_route_object AS alsro ON (alsro.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_route ON (alsro.route_object_id = po_route.id)')
        join_tables.append('LEFT JOIN associate_line_section_via_object AS alsvo ON (alsvo.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_via ON (alsvo.stop_area_object_id = po_via.id)')
        join_tables.append('LEFT JOIN associate_wording_line_section AS awls ON (awls.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN wording AS awlsw ON (awls.wording_id = awlsw.id)')

        andwheres = [] if 'and_wheres' not in query_parts else query_parts['and_wheres']

        columns = ','.join(query_parts['select_columns'])
        tables = ' '.join(join_tables)
        wheres = ' AND '.join(andwheres)

        query = []
        query.append('SELECT %s FROM %s WHERE %s' % (columns, tables, wheres))

        if 'group_by' in query_parts:
            query.append('GROUP BY %s' % (','.join(query_parts['group_by'])))

        if 'order_by' in query_parts:
            query.append('ORDER BY %s' % (','.join(query_parts['order_by'])))

        if 'limit' in query_parts:
            query.append('LIMIT %s' % (query_parts['limit']))

        if 'offset' in query_parts:
            query.append('OFFSET %s' % (query_parts['offset']))

        return ' '.join(query)

    @classmethod
    def count_all_with_post_filter(
            cls,
            contributor_id,
            application_status,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):

        query_parts = cls.generate_impacts_search_query_args(
            contributor_id = contributor_id,
            application_status = application_status,
            ptObjectFilter = ptObjectFilter,
            cause_category_id = cause_category_id,
            application_period = application_period,
            current_time = current_time
        )

        query_parts['select_columns'] = ['COUNT(DISTINCT i.id) AS cnt']
        query = cls.get_impacts_search_native_query(query_parts)

        if not query:
            return 0

        stmt = text(query)

        for param_name, param_type in query_parts['bindparams'].iteritems():
            stmt = stmt.bindparams(bindparam(param_name, type_=param_type))

        result = db.engine.execute(stmt, query_parts['vars']).fetchone()

        return result['cnt']

    @classmethod
    def get_impact_ids_with_post_filter_native(
            cls,
            page_index,
            items_per_page,
            contributor_id,
            application_status,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):
        query_parts = cls.generate_impacts_search_query_args(
            contributor_id=contributor_id,
            application_status=application_status,
            ptObjectFilter=ptObjectFilter,
            cause_category_id=cause_category_id,
            application_period=application_period,
            current_time=current_time
        )
        query_parts['select_columns'] = ['DISTINCT i.id', 'MIN(ap.end_date)']
        query_parts['group_by'] = ['i.id']
        query_parts['order_by'] = ['MIN(ap.end_date)', 'i.id']
        query_parts['limit'] = ':limit'
        query_parts['offset'] = ':offset'

        query = cls.get_impacts_search_native_query(query_parts)

        if not query:
            return []

        stmt = text(query)

        for param_name, param_type in query_parts['bindparams'].iteritems():
            stmt = stmt.bindparams(bindparam(param_name, type_=param_type))

        stmt = stmt.bindparams(bindparam('limit', type_=db.Integer),
                               bindparam('offset', type_=db.Integer)
                               )

        vars = query_parts['vars']
        offset = (max(1, page_index) - 1) * items_per_page
        vars['limit'] = items_per_page
        vars['offset'] = offset
        return db.engine.execute(stmt, vars).fetchall()

    @classmethod
    def get_impacts_search_native_query(cls, query_parts = []):

        join_tables = []
        join_tables.append('disruption AS d')
        join_tables.append('LEFT JOIN impact i ON (i.disruption_id = d.id)')
        join_tables.append('LEFT JOIN cause c ON (d.cause_id = c.id)')
        join_tables.append('LEFT JOIN category ctg ON (c.category_id = ctg.id)')
        join_tables.append('LEFT JOIN associate_wording_cause awc ON (c.id = awc.cause_id)')
        join_tables.append('LEFT JOIN severity AS s ON (s.id = i.severity_id)')
        join_tables.append('LEFT JOIN wording AS cw ON (awc.wording_id = cw.id)')
        join_tables.append('LEFT JOIN associate_wording_severity aws ON (s.id = aws.severity_id)')
        join_tables.append('LEFT JOIN wording AS sw ON (aws.wording_id = sw.id)')
        join_tables.append('LEFT JOIN contributor AS contrib ON (contrib.id = d.contributor_id)')
        join_tables.append('LEFT JOIN associate_disruption_pt_object AS adpo ON (adpo.disruption_id = d.id)')
        join_tables.append('LEFT JOIN pt_object AS localization ON (localization.id = adpo.pt_object_id)')
        join_tables.append('LEFT JOIN associate_impact_pt_object AS aipto ON (aipto.impact_id = i.id)')
        join_tables.append('LEFT JOIN pt_object AS po ON (po.id = aipto.pt_object_id)')
        join_tables.append('LEFT JOIN application_periods AS ap ON (ap.impact_id = i.id)')
        join_tables.append('LEFT JOIN message AS m ON (m.impact_id = i.id)')
        join_tables.append('LEFT JOIN channel AS ch ON (m.channel_id = ch.id)')
        join_tables.append('LEFT JOIN channel_type AS cht ON (cht.channel_id = ch.id)')
        join_tables.append('LEFT JOIN associate_message_meta AS amm ON (amm.message_id = m.id)')
        join_tables.append('LEFT JOIN meta AS me ON (amm.meta_id = me.id)')
        join_tables.append('LEFT JOIN pattern AS pa ON (pa.impact_id = i.id)')
        join_tables.append('LEFT JOIN time_slot AS ts ON (ts.pattern_id = pa.id)')
        join_tables.append('LEFT JOIN line_section AS ls ON (po.id = ls.object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_line ON (po_line.id = ls.line_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_start ON (po_start.id = ls.start_object_id)')
        join_tables.append('LEFT JOIN pt_object AS po_end ON (po_end.id = ls.end_object_id)')
        join_tables.append('LEFT JOIN associate_line_section_route_object AS alsro ON (alsro.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_route ON (alsro.route_object_id = po_route.id)')
        join_tables.append('LEFT JOIN associate_line_section_via_object AS alsvo ON (alsvo.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN pt_object AS po_via ON (alsvo.stop_area_object_id = po_via.id)')
        join_tables.append('LEFT JOIN associate_wording_line_section AS awls ON (awls.line_section_id = ls.id)')
        join_tables.append('LEFT JOIN wording AS awlsw ON (awls.wording_id = awlsw.id)')

        andwheres = [] if 'and_wheres' not in query_parts else query_parts['and_wheres']

        columns = ','.join(query_parts['select_columns'])
        tables = ' '.join(join_tables)
        wheres = ' AND '.join(andwheres)

        query = []
        query.append('SELECT %s FROM %s WHERE %s' % (columns, tables, wheres))

        if 'group_by' in query_parts:
            query.append('GROUP BY %s' % (','.join(query_parts['group_by'])))

        if 'order_by' in query_parts:
            query.append('ORDER BY %s' % (','.join(query_parts['order_by'])))

        if 'limit' in query_parts:
            query.append('LIMIT %s' % (query_parts['limit']))

        if 'offset' in query_parts:
            query.append('OFFSET %s' % (query_parts['offset']))

        return ' '.join(query)

    @classmethod
    def all_with_post_filter_native(
            cls,
            page_index,
            items_per_page,
            contributor_id,
            application_status,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time=None):

        impact_ids = cls.get_impact_ids_with_post_filter_native(page_index,
            items_per_page,
            contributor_id,
            application_status,
            ptObjectFilter,
            cause_category_id,
            application_period,
            current_time)

        if not impact_ids :
            return []

        query_parts = cls.generate_impacts_search_query_args(
            contributor_id = contributor_id,
            application_status = application_status,
            ptObjectFilter = None,
            cause_category_id = cause_category_id,
            application_period = application_period,
            current_time = current_time
        )

        query_parts['select_columns'] = [
                'd.id', 'd.reference', 'd.note', 'd.status', 'd.version', 'd.created_at', 'd.updated_at',
                'd.start_publication_date', 'd.end_publication_date', 'd.author',
                'i.id AS impact_id', 'i.created_at AS impact_created_at', 'i.updated_at AS impact_updated_at',
                'i.send_notifications AS impact_send_notifications', 'i.notification_date AS impact_notification_date',
                'c.id AS cause_id', 'c.created_at AS cause_created_at', 'c.updated_at AS cause_updated_at',
                'ctg.id AS cause_category_id', 'ctg.name AS cause_category_name', 'ctg.created_at AS cause_category_created_at',
                'ctg.updated_at AS cause_category_updated_at', 'cw.id AS cause_wording_id', 'cw.key AS cause_wording_key',
                'cw.value AS cause_wording_value', 's.created_at AS severity_created_at', 's.updated_at AS severity_updated_at',
                's.id AS severity_id', 's.wording AS severity_wording', 's.color AS severity_color', 's.is_visible AS severity_is_visible',
                's.priority AS severity_priority', 's.effect AS severity_effect', 's.client_id AS severity_client_id',
                'sw.id AS severity_wording_id', 'sw.key AS severity_wording_key', 'sw.value AS severity_wording_value',
                'contrib.contributor_code AS contributor_code',
                'po.id AS pt_object_id', 'po.type AS pt_object_type', 'po.uri AS pt_object_uri', 'ap.id AS application_period_id',
                'ap.start_date AS application_period_start_date', 'ap.end_date AS application_period_end_date',
                'm.id AS message_id', 'm.created_at AS message_created_at', 'm.updated_at AS message_updated_at',
                'm.text AS message_text', 'ch.id AS channel_id', 'ch.content_type AS channel_content_type',
                'ch.created_at AS channel_created_at', 'ch.updated_at AS channel_updated_at', 'ch.max_size AS channel_max_size',
                'ch.name AS channel_name', 'ch.required AS channel_required', 'cht.id AS channel_type_id', 'cht.name AS channel_type_name',
                'me.id AS meta_id', 'me.key AS meta_key', 'me.value AS meta_value',
                'pa.id AS pattern_id, pa.start_date AS pattern_start_date, pa.end_date AS pattern_end_date, pa.weekly_pattern AS pattern_weekly_pattern',
                'ts.id AS time_slot_id, ts.begin AS time_slot_begin, ts.end AS time_slot_end',
                'ls.id AS line_section_id, ls.sens AS line_section_sens',
                'po_line.uri AS line_section_line_uri, po_line.type AS line_section_line_type',
                'po_start.uri AS line_section_start_uri, po_start.type AS line_section_start_type',
                'po_end.uri AS line_section_end_uri, po_end.type AS line_section_end_type',
                'po_route.id AS po_route_id, po_route.uri AS po_route_uri, po_route.type AS po_route_type',
                'awlsw.id AS awlsw_id, awlsw.key AS awlsw_key, awlsw.value AS awlsw_value',
                'po_via.id AS po_via_id, po_via.uri AS po_via_uri, po_via.type AS po_via_type'
            ]
        query_parts['and_wheres'].append('i.id IN :impact_ids')
        query_parts['order_by'] = ['ap.end_date','i.id', 'po.type','po.uri']

        query = cls.get_impacts_search_native_query(query_parts)

        stmt = text(query)
        stmt = stmt.bindparams(bindparam('impact_ids', type_=db.String))

        vars = query_parts['vars']
        vars['impact_ids'] = tuple([d[0] for d in impact_ids])

        return db.engine.execute(stmt, vars).fetchall()

associate_line_section_route_object = db.Table(
    'associate_line_section_route_object',
    db.metadata,
    db.Column('line_section_id', UUID, db.ForeignKey('line_section.id')),
    db.Column('route_object_id', UUID, db.ForeignKey('pt_object.id')),
    db.PrimaryKeyConstraint(
        'line_section_id',
        'route_object_id',
        name='line_section_route_object_pk'
    )
)


associate_line_section_via_object = db.Table(
    'associate_line_section_via_object',
    db.metadata,
    db.Column('line_section_id', UUID, db.ForeignKey('line_section.id')),
    db.Column('stop_area_object_id', UUID, db.ForeignKey('pt_object.id')),
    db.PrimaryKeyConstraint(
        'line_section_id',
        'stop_area_object_id',
        name='line_section_stop_area_object_pk'
    )
)


class PTobject(TimestampMixin, db.Model):
    __tablename__ = 'pt_object'
    id = db.Column(UUID, primary_key=True)
    type = db.Column(PtObjectType, nullable=False, default='network', index=True)
    uri = db.Column(db.Text, primary_key=True)
    line_section = db.relationship('LineSection',
                                   foreign_keys='LineSection.object_id',
                                   backref='pt_object',
                                   uselist=False)

    def __repr__(self):
        return '<PTobject %r>' % self.id

    def __init__(self, type=None, code=None):
        self.id = str(uuid.uuid1())
        self.type = type
        self.uri = code

    def insert_line_section(self, line_section):
        """
        Adds a line_section in an object.
        """
        self.line_section = line_section
        db.session.add(line_section)

    @classmethod
    def get(cls, id):
        return cls.query.filter_by(id=id).first_or_404()

    @classmethod
    def get_pt_object_by_uri(cls, uri):
        return cls.query.filter_by(uri=uri).first()


class ApplicationPeriods(TimestampMixin, db.Model):
    """
    represents the application periods of an impact
    """
    id = db.Column(UUID, primary_key=True)
    start_date = db.Column(db.DateTime(), nullable=True)
    end_date = db.Column(db.DateTime(), nullable=True)
    impact_id = db.Column(UUID, db.ForeignKey(Impact.id), index=True)

    def __init__(self, impact_id=None):
        self.id = str(uuid.uuid1())
        self.impact_id = impact_id

    def __repr__(self):
        return '<ApplicationPeriods %r>' % self.id


class Channel(TimestampMixin, db.Model):
    """
    represent the channel for the message of an impact
    """
    id = db.Column(UUID, primary_key=True)
    name = db.Column(db.Text, unique=False, nullable=False)
    max_size = db.Column(db.Integer, unique=False, nullable=True)
    content_type = db.Column(db.Text, unique=False, nullable=True)
    is_visible = db.Column(db.Boolean, unique=False, nullable=False, default=True)
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='channels')
    channel_types = db.relationship('ChannelType', backref='channel', lazy='joined')
    required = db.Column(db.Boolean, unique=False, nullable=False, default=False)

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Channel %r>' % self.id

    def delete_channel_types(self):
        """
        Deletes a channel_type in the channel
        """
        index = len(self.channel_types) - 1
        while index >= 0:
            type = self.channel_types[index]
            self.channel_types.remove(type)
            db.session.delete(type)
            index -= 1

    def insert_channel_type(self, channel_type):
        """
        Adds a channel_type in the channel
        """
        self.channel_types.append(channel_type)
        db.session.add(channel_type)

    @classmethod
    def all(cls, client_id):
        return cls.query.filter_by(client_id=client_id, is_visible=True).order_by(cls.name).all()

    @classmethod
    def get(cls, id, client_id):
        return cls.query.filter_by(id=id, client_id=client_id, is_visible=True).first_or_404()

    @classmethod
    def get_channels_required(cls, client_id):
        return cls.query.filter_by(client_id=client_id, is_visible=True, required=True).all()

associate_message_meta = db.Table(
    'associate_message_meta',
    db.metadata,
    db.Column('message_id', UUID, db.ForeignKey('message.id')),
    db.Column('meta_id', UUID, db.ForeignKey('meta.id')),
    db.PrimaryKeyConstraint(
        'message_id',
        'meta_id',
        name='message_meta_pk'
    )
)

class Message(TimestampMixin, db.Model):
    """
    represent the message of an impact
    """
    id = db.Column(UUID, primary_key=True)
    text = db.Column(db.Text, unique=False, nullable=False)
    impact_id = db.Column(UUID, db.ForeignKey(Impact.id))
    channel_id = db.Column(UUID, db.ForeignKey(Channel.id))
    channel = db.relationship('Channel', backref='message', lazy='select')
    meta = db.relationship("Meta", secondary=associate_message_meta, lazy="joined")

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Message %r>' % self.id

    @classmethod
    def all(cls):
        return cls.query.all()

    @classmethod
    def get(cls, id):
        return cls.query.filter_by(id=id).first_or_404()

    def insert_meta(self, meta):
        """
        Adds an meta in a message.
        """
        self.meta.append(meta)
        db.session.add(meta)

    def delete_meta(self, meta):
        """
        delete a meta in a message.
        """
        self.meta.remove(meta)
        db.session.delete(meta)

associate_wording_line_section = db.Table(
    'associate_wording_line_section',
    db.metadata,
    db.Column('wording_id', UUID, db.ForeignKey('wording.id')),
    db.Column('line_section_id', UUID, db.ForeignKey('line_section.id')),
    db.PrimaryKeyConstraint(
        'wording_id',
        'line_section_id',
        name='wording_line_section_pk'
    )
)

class Meta(db.Model):
    """
    represent the channel for the message of an impact
    """
    id = db.Column(UUID, primary_key=True)
    key = db.Column(db.Text, unique=False, nullable=False)
    value = db.Column(db.Text, unique=False, nullable=False)

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<Meta %r>' % self.id

class LineSection(TimestampMixin, db.Model):
    __tablename__ = 'line_section'
    id = db.Column(UUID, primary_key=True)
    line_object_id = db.Column(UUID, db.ForeignKey(PTobject.id), nullable=False)
    start_object_id = db.Column(UUID, db.ForeignKey(PTobject.id), nullable=False)
    end_object_id = db.Column(UUID, db.ForeignKey(PTobject.id), nullable=False)
    sens = db.Column(db.Integer, unique=False, nullable=True)
    object_id = db.Column(UUID, db.ForeignKey(PTobject.id))
    line = db.relationship('PTobject', foreign_keys=line_object_id)
    start_point = db.relationship('PTobject', foreign_keys=start_object_id, lazy="joined")
    end_point = db.relationship('PTobject', foreign_keys=end_object_id, lazy="joined")
    routes = db.relationship("PTobject", secondary=associate_line_section_route_object, lazy="joined")
    via = db.relationship("PTobject", secondary=associate_line_section_via_object, lazy="joined")
    wordings = db.relationship(
        "Wording",
        secondary=associate_wording_line_section,
        backref="linesections",
        lazy="joined")

    def delete_wordings(self):
        index = len(self.wordings) - 1
        while index >= 0:
            wording = self.wordings[index]
            self.wordings.remove(wording)
            db.session.delete(wording)
            index -= 1

    def __repr__(self):
        return '<LineSection %r>' % self.id

    def __init__(self, object_id=None):
        self.id = str(uuid.uuid1())
        self.object_id = object_id

    @classmethod
    def get(cls, id):
        return cls.query.filter_by(id=id).first_or_404()

    @classmethod
    def get_by_object_id(cls, object_id):
        return cls.query.filter_by(object_id=object_id).first()

    @classmethod
    def get_by_ids(cls, ids):
        return cls.query.filter(cls.object_id.in_(ids)).all()


class Pattern(TimestampMixin, db.Model):
    """
    represents the patterns of application periods of an impact
    """
    __tablename__ = 'pattern'
    id = db.Column(UUID, primary_key=True)
    start_date = db.Column(db.Date(), nullable=True)
    end_date = db.Column(db.Date(), nullable=True)
    weekly_pattern = db.Column(BIT(7), unique=False, nullable=False)
    impact_id = db.Column(UUID, db.ForeignKey(Impact.id), index=True)
    time_slots = db.relationship('TimeSlot', backref='pattern', lazy='joined', cascade='delete')

    def __init__(self, impact_id=None):
        self.id = str(uuid.uuid1())
        self.impact_id = impact_id

    def __repr__(self):
        return '<Pattern %r>' % self.id

    def delete_time_slots(self):
        for time_slot in self.time_slots:
            db.session.delete(time_slot)

    def insert_time_slot(self, time_slot):
        """
        Adds a time slot in the pattern
        """
        self.time_slots.append(time_slot)
        db.session.add(time_slot)


class TimeSlot(TimestampMixin, db.Model):
    """
    represents the time slots of a pattern
    """
    __tablename__ = 'time_slot'
    id = db.Column(UUID, primary_key=True)
    begin = db.Column(db.Time(), nullable=True)
    end = db.Column(db.Time(), nullable=True)
    pattern_id = db.Column(UUID, db.ForeignKey(Pattern.id), index=True)

    def __init__(self, pattern_id=None):
        self.id = str(uuid.uuid1())
        self.pattern_id = pattern_id

    def __repr__(self):
        return '<TimeSlot %r>' % self.id


class ChannelType(TimestampMixin, db.Model):
    """
    represents the types of a channel
    """
    __tablename__ = 'channel_type'
    id = db.Column(UUID, primary_key=True)
    channel_id = db.Column(UUID, db.ForeignKey(Channel.id), index=True)
    name = db.Column(ChannelTypeEnum, nullable=False, default='web')

    def __init__(self, channel_id=None):
        self.id = str(uuid.uuid1())
        self.channel_id = channel_id

    def __repr__(self):
        return '<ChannelType %r>' % self.id


class Property(TimestampMixin, db.Model):
    """
    represents the types of properties
    """
    __tablename__ = 'property'
    __table_args__ = (
        db.UniqueConstraint(
            'type',
            'key',
            'client_id',
            name='property_type_key_client_id_uc'
        ),
    )
    id = db.Column(UUID, primary_key=True)
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='properties')
    key = db.Column(db.Text, nullable=False)
    type = db.Column(db.Text, nullable=False)
    disruptions = db.relationship(
        'AssociateDisruptionProperty',
        lazy='dynamic',
        back_populates='property',
        cascade='delete'
    )

    def __init__(self):
        self.id = str(uuid.uuid1())

    def __repr__(self):
        return '<%s: %s %s %s>' % (
            self.__class__.__name__, self.id, self.type, self.key
        )

    @classmethod
    def prepare_request(cls, client_id, key=None, type=None, id=None):
        request = {'client_id': client_id}
        if id:
            request['id'] = id
        if key:
            request['key'] = key
        if type:
            request['type'] = type

        return request

    @classmethod
    def all(cls, client_id, key=None, type=None):
        kargs = cls.prepare_request(client_id, key, type)

        return cls.query.filter_by(**kargs).all()

    @classmethod
    def get(cls, client_id, id=None, key=None, type=None):
        kargs = cls.prepare_request(client_id, key, type, id)

        return cls.query.filter_by(**kargs).first()


class Export(TimestampMixin, db.Model):
    """
        represents the list of exports
        """
    __tablename__ = 'export'
    id = db.Column(UUID, primary_key=True, nullable=False)
    client_id = db.Column(UUID, db.ForeignKey(Client.id), nullable=False)
    client = db.relationship('Client', backref='exports')
    status = db.Column(ExportStatusEnum, nullable=False, default='waiting')
    process_start_date = db.Column(db.DateTime(), default=None, nullable=True)
    start_date = db.Column(db.DateTime(), nullable=False)
    end_date = db.Column(db.DateTime(), nullable=False)
    time_zone = db.Column(db.Text, nullable=False, default='UTC')
    file_path = db.Column(db.Text, default=None, nullable=True)

    def __init__(self, client_id=None):
        self.id = str(uuid.uuid1())
        self.client_id = client_id

    def __repr__(self):
        return '<Export %r>' % self.id

    @classmethod
    def all(cls, client_id):
        return cls.query.filter_by(
            client_id=client_id
        ).order_by(cls.created_at).all()

    @classmethod
    def get(cls, client_id, id):
        return cls.query.filter_by(client_id=client_id, id=id).first_or_404()

    @classmethod
    def exist_without_error(cls, client_id, start_date, end_date):
        return cls.query.filter(
            cls.client_id==client_id,
            cls.start_date==start_date,
            cls.end_date==end_date,
            cls.status!='error'
            ).first()

    @classmethod
    def get_oldest_waiting_export(cls, clientId):
        return cls.query.filter_by(client_id=clientId, status='waiting').order_by(cls.created_at).first()

    @classmethod
    def find_finished_export(cls, id):
        return cls.query.filter_by(id=id, status='done').first()

    @classmethod
    def get_client_impacts_between_application_dates(cls, client_id, app_start_date, app_end_date):

        client_channels=Channel.all(client_id)

        channel_columns = ''
        for chanel in client_channels:
            channel_columns += "(CASE WHEN ch.name='{}' THEN m.text END) \"{}\",".format(chanel.name, chanel.name)

        query = 'SELECT DISTINCT '\
                + channel_columns + \
                ' d.reference' \
                ', tag.name AS tag_name' \
                ', c.wording AS cause' \
                ', d.start_publication_date AS publication_start_date' \
                ', d.end_publication_date AS publication_end_date' \
                ', po.type AS pt_object_type' \
                ', po.uri AS pt_object_uri' \
                ', po.uri AS pt_object_name' \
                ', s.wording AS severity' \
                ', (CASE WHEN cht.name=\'title\' THEN m.text ELSE \'\' END) as impact_title' \
                ', i.status' \
                ', app.start_date AS application_start_date' \
                ', app.end_date AS application_end_date' \
                ', (CASE WHEN (SELECT COUNT(1) FROM application_periods app_period WHERE app_period.impact_id = i.id) > 1 THEN True ELSE False END) AS periodicity' \
                ', i.created_at AS created_at' \
                ', i.updated_at AS updated_at' \
                ' FROM ' \
                ' disruption d' \
                ' LEFT JOIN impact i ON (i.disruption_id = d.id)' \
                ' LEFT JOIN message m ON (i.id = m.impact_id)' \
                ' JOIN channel ch ON (m.channel_id = ch.id AND ch.client_id = :client_id)' \
                ' LEFT JOIN channel_type cht ON (cht.channel_id = ch.id)' \
                ' LEFT JOIN associate_disruption_tag adt ON (d.id = adt.disruption_id)' \
                ' LEFT JOIN tag ON (tag.id = adt.tag_id)' \
                ' LEFT JOIN application_periods app ON (app.impact_id = i.id)' \
                ' LEFT JOIN cause c ON (c.id = d.cause_id)' \
                ' LEFT JOIN associate_impact_pt_object aipto ON (i.id = aipto.impact_id)' \
                ' LEFT JOIN pt_object po ON (aipto.pt_object_id = po.id)' \
                ' LEFT JOIN severity s ON (i.severity_id = s.id)' \
                ' WHERE' \
                ' d.client_id = :client_id' \
                ' AND app.start_date >= :app_start_date' \
                ' AND app.end_date <= :app_end_date' \
                ' AND c.is_visible = :is_visible' \
                ' AND ch.is_visible = :is_visible'

        stmt = text(query)
        stmt = stmt.bindparams(bindparam('client_id', type_=db.String))
        stmt = stmt.bindparams(bindparam('app_start_date', type_=db.Date))
        stmt = stmt.bindparams(bindparam('app_end_date', type_=db.Date))
        stmt = stmt.bindparams(bindparam('is_visible', type_=db.Boolean))
        vars = {}
        vars['client_id'] = client_id
        vars['app_start_date'] = app_start_date
        vars['app_end_date'] = app_end_date
        vars['is_visible'] = True

        return db.engine.execute(stmt, vars)

class HistoryDisruption(db.Model):
    __tablename__ = 'disruption'
    __table_args__ = {"schema": "history"}

    id = db.Column(UUID, primary_key=True)
    created_at = db.Column(db.DateTime(), server_default=func.now(), nullable=False)
    disruption_id = db.Column(UUID, db.ForeignKey(Disruption.id))
    data = db.Column(db.Text, unique=False, nullable=False)

    def __repr__(self):
        return '<HistoryDisruption %r>' % self.id

    def __init__(self):
        self.id = str(uuid.uuid4())

    @classmethod
    def get_by_disruption_id(cls, disruption_id):
        return cls.query.filter_by(disruption_id=disruption_id).order_by(desc(cls.created_at))