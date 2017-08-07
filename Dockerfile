FROM ubuntu:16.04
MAINTAINER Enrique Cornejo <enrique.cornejo@vizzuality.com>

ENV RMANHOME /opt/rasdaman/
ENV RASDATA /opt/rasdaman/data
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $RMANHOME/bin:$PATH
ENV CATALINA_HOME /usr/share/tomcat8
ENV container docker

ENV LANG C.UTF-8
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

RUN mkdir -p /opt/rasdaman/data
RUN chown -R rasdaman /opt/rasdaman/data/
RUN chown -R rasdaman /opt/rasdaman/log

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

RUN /etc/init.d/postgresql start \
    && su - postgres -c"psql -c\"CREATE ROLE rasdaman SUPERUSER LOGIN CREATEROLE CREATEDB UNENCRYPTED PASSWORD 'rasdaman';\"" \
    && su - rasdaman -c"$RMANHOME/bin/create_db.sh" && su - rasdaman -c"$RMANHOME/bin/update_petascopedb.sh"

# Tomcat and petascope
RUN mkdir -p $CATALINA_HOME-root/secoredb && chmod 777 $CATALINA_HOME-root/secoredb
RUN cp /opt/rasdaman/share/rasdaman/war/def.war $CATALINA_HOME-root/def.war
RUN cp /opt/rasdaman/share/rasdaman/war/rasdaman.war $CATALINA_HOME-root/rasdaman.war

RUN mkdir $CATALINA_HOME/conf && mkdir  $CATALINA_HOME/tmp
RUN mv /etc/tomcat8/server.xml $CATALINA_HOME/conf/


# Ports

EXPOSE 7001 8080 5432 8787

# Installing supervisord

RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
    supervisor

COPY ./supervisord.conf /etc/supervisor/conf.d/
# CMD ["/usr/bin/supervisord"]


USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
