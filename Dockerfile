FROM ubuntu:16.04
MAINTAINER Enrique Cornejo <enrique.cornejo@vizzuality.com>

# TODO:
# - Set rasdaman log dir and tomcat log dir to shared folder

ENV CATALINA_HOME /opt/tomcat6
ENV WEBAPPS_HOME $CATALINA_HOME/webapps
ENV RMANHOME /opt/rasdaman/
ENV HOSTNAME rasdaman-dev1
ENV R_LIBS /home/rasdaman/R
ENV RASDATA /opt/rasdaman/data
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $RMANHOME/bin:$PATH
ENV container docker

ENV LANG C.UTF-8
RUN env

# Install required software 
RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \ 
make \
libtool \
gawk \
autoconf \
bison \
flex \
git \
g++ \
unzip \
libboost-all-dev \
libtiff-dev \
libgdal-dev \
zlib1g-dev \
libffi-dev \
libnetcdf-cxx-legacy-dev \
libedit-dev \
libecpg-dev \
libsqlite3-dev \
libgrib-api-dev \
libgrib2c-dev \
curl \
cmake \
ccache \
automake \
autotools-dev \
m4 \
openjdk-8-jdk \
maven \
ant \
sqlite3 \
zlib1g \
gdal-bin \
python-dev \
debianutils \
python-dateutil \
python-lxml \
python-grib \
python-pip \
python-gdal \
netcdf-bin \
libnetcdf-c++4 \
libecpg6 \
libboost-all-dev \
libedit-dev \
python-netcdf4 \
openjdk-8-jre \
bc \
vim-common \
ruby-dev \
ruby \
ssh \
r-base \
r-base-dev \
tomcat8 \
postgresql \
postgresql-contrib

COPY rasdaman_9.4.0-3_amd64.deb rasdaman.deb
RUN dpkg -i --force-all rasdaman.deb

RUN useradd -r -d /opt/rasdaman rasdaman && \
    echo "rasdaman:rasdaman" | chpasswd 

RUN pip install --upgrade pip && \
    pip install setuptools

RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
    libhdf5-dev libhdf5-serial-dev libnetcdf-dev python-netcdf4

RUN ln -s /usr/include/hdf5/serial /usr/include/hdf5/include

RUN pip install --upgrade pip && \
    pip install glob2

RUN mkdir -p /opt/rasdaman && \
    mkdir -p /opt/rasdaman/third_party

RUN chmod +x /opt/rasdaman && \
    chmod +x /opt/ && \
    chmod +x /

RUN ldconfig

RUN mkdir -p /var/lib/tomcat8/webapps/secoredb
RUN chmod 777 /var/lib/tomcat8/webapps/secoredb
RUN cp /opt/rasdaman/share/rasdaman/war/def.war /var/lib/tomcat8/webapps/def.war
RUN cp /opt/rasdaman/share/rasdaman/war/rasdaman.war /var/lib/tomcat8/webapps/rasdaman.war

RUN mkdir -p /opt/rasdaman/data
RUN chown -R rasdaman /opt/rasdaman/data/

RUN echo "local   all             postgres                                trust" >>  /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "local   all             all                                     trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host    all             all             127.0.0.1/32            md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host    all             all             ::1/128                 md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

RUN /etc/init.d/postgresql start \
    && su - postgres -c"psql -c\"CREATE ROLE rasdaman SUPERUSER LOGIN CREATEROLE CREATEDB UNENCRYPTED PASSWORD 'rasdaman';\"" \
    && su - rasdaman -c"$RMANHOME/bin/create_db.sh" && su - rasdaman -c"$RMANHOME/bin/update_petascopedb.sh"

CMD ["/sbin/init"]