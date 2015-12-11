FROM ubuntu:15.10

MAINTAINER CANALTP

RUN apt-get update -y

# Install PostgreSQL

RUN createdb -O navitia chaos

RUN createdb -O navitia chaos_testing

# Install python dependencies and rabbitmq

RUN apt-get install python python-dev python-pip libpq-dev rabbitmq-server

RUN pip install virtualenv

WORKDIR /tmp

RUN wget https://protobuf.googlecode.com/svn/rc/protobuf-2.6.0.tar.gz

# Build protobuf

RUN tar zxvf protobuf-2.6.0.tar.gz

RUN cd protobuf-2.6.0

RUN ./configure

RUN make

RUN make check

RUN make install

RUN ldconfig

RUN rm -rf /tmp/protobuf-2.6.0

RUN mkdir -p /var/www/chaos

WORKDIR /var/www/chaos

VOLUME /var/www/chaos

EXPOSE 5000

ENTRYPOINT ["/bin/bash"]

CMD ["/var/www/chaos/run-server.sh"]
