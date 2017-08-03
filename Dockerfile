FROM ubuntu:16.04
MAINTAINER Enrique Cornejo <enrique.cornejo@vizzuality.com>

# TODO:
# - Set rasdaman log dir and tomcat log dir to shared folder

ENV CATALINA_HOME /opt/tomcat6
ENV WEBAPPS_HOME $CATALINA_HOME/webapps
ENV RMANHOME /opt/rasdaman/
ENV HOSTNAME rasdaman-dev1
ENV R_LIBS /home/rasdaman/R
ENV RASDATA ${RMANHOME}data
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
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
postgresql \
postgresql-contrib \
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
r-base-dev

RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
tomcat8 sudo

COPY rasdaman_9.4.0-3_amd64.deb rasdaman.deb
RUN dpkg -i rasdaman.deb