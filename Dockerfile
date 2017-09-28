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

ENV NAME importer
ENV USER importer

RUN env

# Install required software 
RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \ 
    make libtool gawk autoconf bison flex git g++ unzip libboost-all-dev libtiff-dev libgdal-dev zlib1g-dev libffi-dev libnetcdf-cxx-legacy-dev libedit-dev libecpg-dev libsqlite3-dev libgrib-api-dev libgrib2c-dev curl cmake ccache automake autotools-dev m4 openjdk-8-jdk maven ant sqlite3 zlib1g gdal-bin python-dev debianutils python-dateutil python-lxml python-grib python-pip python-gdal netcdf-bin libnetcdf-c++4 libecpg6 libboost-all-dev libedit-dev python-netcdf4 openjdk-8-jre bc vim-common ruby-dev ruby ssh r-base r-base-dev tomcat8 postgresql postgresql-contrib supervisor python-meld3

RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
    libnetcdf-c++4 net-tools mlocate

# APT repo doesn't work right now
COPY rasdaman_9.4.2-1_amd64.deb rasdaman.deb
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
# RUN apt-get -qq update && apt-get install --no-install-recommends -y --force-yes \
#     libhdf5-serial-dev
# RUN chmod 777 /var/lib/update-notifier/package-data-downloads/partial
# RUN apt-get download libhdf5-serial-dev
COPY libhdf5-serial-dev_1.10.0-patch1+docs-4_all.deb libhdf5-serial-dev_1.10.0-patch1+docs-4_all.deb
RUN dpkg -i --force-all  libhdf5-serial-dev_1.10.0-patch1+docs-4_all.deb

# RUN apt-get -qq update && apt-get install --no-install-recommends -y --force-yes \
#      libgrib-api0

COPY libgrib-api-dev_1.14.4-5_amd64.deb libgrib-api-dev_1.14.4-5_amd64.deb
RUN dpkg -i --force-all libgrib-api-dev_1.14.4-5_amd64.deb

# Tithe to the dark lords
RUN ln -s /usr/lib/x86_64-linux-gnu/libnetcdf.so /usr/lib/x86_64-linux-gnu/libnetcdf.so.7
RUN ln -s /usr/include/hdf5/serial /usr/include/hdf5/include
RUN ln -s /usr/lib/libgrib_api.so.0 /usr/lib/libgrib_api-1.10.4.so
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0 /usr/lib/x86_64-linux-gnu/libboost_system.so.1.55.0
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_thread.so.1.58.0 /usr/lib/x86_64-linux-gnu/libboost_thread.so.1.55.0

# Linking modules
RUN ldconfig

# Folder config
RUN mkdir -p /opt/rasdaman/data
RUN chown -R rasdaman /opt/rasdaman/data/
RUN chown -R rasdaman /opt/rasdaman/log

# Postgres config
RUN echo "local   all             all                                     trust" >> /etc/postgresql/9.5/main/pg_hba.conf
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
EXPOSE 7001 8080 5432 8787 5700

# Installing supervisord

# RUN apt-get -qq update && apt-get autoclean && apt-get install --no-install-recommends -y --force-yes \
#     supervisor python-meld3

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

COPY ./$NAME/ /opt/$NAME/
COPY ./$NAME/microservice /opt/$NAME/microservice

RUN adduser --gecos "" --disabled-login --home /home/$USER importer \
   && echo  "$USER:$USER" | chpasswd
# RUN addgroup $USER && adduser -s /bin/bash -D -G $USER $USER
RUN chown $USER:$USER /opt/$NAME

#
COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./rasmgr.conf /opt/rasdaman/etc/rasmgr.conf
COPY ./container_startup.sh /opt/
RUN chmod +x /opt/container_startup.sh


# Running services
USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
# CMD ["/sbin/init"]
