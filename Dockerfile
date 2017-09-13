FROM ubuntu:16.04
MAINTAINER Enrique Cornejo <enrique.cornejo@vizzuality.com>

# Environment definitions
ENV RMANHOME /opt/rasdaman/
ENV RASDATA /opt/rasdaman/data
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH $RMANHOME/bin:$PATH
ENV CATALINA_HOME /opt/tomcat
ENV CATALINA_BASE /opt/tomcat
ENV CATALINA_OPTS -Xms512M -Xmx1024M -server -XX:+UseParallelGC
ENV CATALINA_PID /opt/tomcat/temp/tomcat.pid
ENV container docker
ENV LANG C.UTF-8

ENV NAME rasdaman
ENV USER rasdaman

RUN env

# Install required software 
RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \ 
    make libtool gawk autoconf bison flex git g++ unzip libboost-all-dev libtiff-dev libgdal-dev zlib1g-dev libffi-dev libnetcdf-cxx-legacy-dev libedit-dev libecpg-dev libsqlite3-dev libgrib-api-dev libgrib2c-dev curl cmake ccache automake autotools-dev m4 openjdk-8-jdk maven ant sqlite3 zlib1g gdal-bin python-dev debianutils python-dateutil python-lxml python-grib python-pip python-gdal netcdf-bin libnetcdf-c++4 libecpg6 libboost-all-dev libedit-dev python-netcdf4 openjdk-8-jre bc vim-common ruby-dev ruby ssh r-base r-base-dev tomcat8 postgresql postgresql-contrib

# APT repo doesn't work right now
COPY rasdaman_9.4.0-3_amd64.deb rasdaman.deb
RUN dpkg -i --force-all rasdaman.deb

# Adding user to run rasdaman
RUN adduser --gecos "" --disabled-login --home /home/rasdaman rasdaman \
   && echo  "rasdaman:rasdaman" | chpasswd

# Installing pip packages
RUN pip install --upgrade pip && \
    pip install setuptools
RUN pip install --upgrade pip && \
    pip install glob2

# Netcdf4 support
RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
    libhdf5-dev libhdf5-serial-dev libnetcdf-dev python-netcdf4

# Tithe to the dark lords
RUN ln -s /usr/include/hdf5/serial /usr/include/hdf5/include

# Linking modules
RUN ldconfig

# Folder config
RUN mkdir -p /opt/rasdaman/data
RUN chown -R rasdaman /opt/rasdaman/data/
RUN chown -R rasdaman /opt/rasdaman/log

# Postgres config
RUN echo "local   all             all                                     peer" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host    all             all             127.0.0.1/32            trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

USER rasdaman
RUN touch ~/.pgpass
RUN echo "localhost:*:*:rasdaman:rasdaman" > ~/.pgpass
RUN chmod 600 ~/.pgpass
USER root
RUN chmod 644 /opt/rasdaman/share/rasdaman/petascope/update8.sh
RUN chmod +x /opt/rasdaman/share/rasdaman/petascope/update8.sh
RUN chmod 644 /opt/rasdaman/share/rasdaman/petascope/update8-sqlite.sh
RUN chmod 644 /opt/rasdaman/share/rasdaman/petascope/update8/*
RUN chmod 644 /opt/rasdaman/share/rasdaman/petascope/update8-hsqldb/*
RUN chmod 644 /opt/rasdaman/share/rasdaman/petascope/update8-sqlite/*

# Starting and updating DB
COPY global_const.sql /opt/rasdaman/share/rasdaman/petascope/update8/global_const.sql
COPY update14.sql /opt/rasdaman/share/rasdaman/petascope/update14.sql
RUN /etc/init.d/postgresql start \
    && su - postgres -c"psql -c\"CREATE ROLE rasdaman SUPERUSER LOGIN CREATEROLE CREATEDB UNENCRYPTED PASSWORD 'rasdaman';\"" \
    && su - rasdaman -c"$RMANHOME/bin/create_db.sh" && su - rasdaman -c"$RMANHOME/bin/update_petascopedb.sh"

# Tomcat and petascope
WORKDIR /tmp
#RUN curl -O http://apache.uvigo.es/tomcat/tomcat-8/v8.5.16/bin/apache-tomcat-8.5.16.tar.gz
COPY apache-tomcat-8.5.16.tar.gz apache-tomcat-8.5.16.tar.gz
RUN mkdir /opt/tomcat
RUN tar zxvf apache-tomcat-8.5.16.tar.gz -C /opt/tomcat --strip-components=1
RUN groupadd tomcat
RUN useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
RUN chgrp -R tomcat /opt/tomcat && chmod -R g+r /opt/tomcat/conf && chmod g+x /opt/tomcat/conf
WORKDIR /opt/tomcat
RUN chown -R tomcat webapps work temp logs
RUN mkdir -p $CATALINA_HOME/webapps/secoredb && chmod 777 $CATALINA_HOME/webapps/secoredb
RUN cp /opt/rasdaman/share/rasdaman/war/def.war $CATALINA_HOME/webapps/def.war
RUN cp /opt/rasdaman/share/rasdaman/war/rasdaman.war $CATALINA_HOME/webapps/rasdaman.war
RUN mkdir  $CATALINA_HOME/tmp

# Moving some config files to the container
COPY petascope.properties /opt/rasdaman/etc/petascope.properties

# Exposing ports
EXPOSE 7001 8080 5432 8787

# Installing supervisord
RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
    supervisor
COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./container_startup.sh /opt/
RUN chmod +x /opt/container_startup.sh

# Copying microservice

# RUN groupadd $USER && useradd -g $USER $USER -s /bin/bash

RUN easy_install pip && pip install --upgrade pip
RUN pip install virtualenv gunicorn gevent numpy

RUN mkdir -p /opt/$NAME
RUN cd /opt/$NAME && virtualenv venv && /bin/bash -c "source venv/bin/activate"
COPY requirements.txt /opt/$NAME/requirements.txt
RUN cd /opt/$NAME && pip install -r requirements.txt
#
COPY entrypoint.sh /opt/$NAME/entrypoint.sh
COPY main.py /opt/$NAME/main.py
COPY gunicorn.py /opt/$NAME/gunicorn.py

# Copy the application folder inside the container
WORKDIR /opt/$NAME

COPY ./microservice/ /opt/$NAME/$NAME
COPY ./microservice/microservice /opt/$NAME/microservice
RUN chown $USER:$USER /opt/$NAME

# Running services
USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
# CMD ["/sbin/init"]
