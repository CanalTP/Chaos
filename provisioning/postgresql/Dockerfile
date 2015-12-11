FROM tutum/postgresql

ADD scripts /scripts

RUN chmod -R 755 /scripts

# make backup of original database
RUN cp -R /var/lib/postgresql /var/lib/_postgresql

WORKDIR /

EXPOSE 5432

CMD ["/scripts/run-postgresql.sh"]
