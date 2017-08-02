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
ruby 

RUN apt-get -qq update && apt-get install --no-install-recommends --fix-missing -y --force-yes \
ssh \
r-base \
r-base-dev

RUN echo $(ls /usr/lib/jvm)

# Install Tomcat6
ADD https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.tar.gz apache-tomcat-6.0.53.tar.gz
RUN tar -xzf apache-tomcat-6.0.53.tar.gz
RUN mv apache-tomcat-6.0.53 /opt/tomcat6

# create rasdaman user with credentials: rasdaman:rasdaman
RUN adduser --gecos "" --disabled-login --home /home/rasdaman rasdaman \
   && echo  "rasdaman:rasdaman" | chpasswd \
   && adduser rasdaman sudo # add to sudo group
   
# change login credentials for root and postgres users
RUN echo 'root:xxxx.xxxx.xxxx' | chpasswd && echo 'postgres:xxxx.xxxx.xxxx' | chpasswd

# Configure SSH
RUN mkdir /var/run/sshd 
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config



# Download and build rasdaman
RUN mkdir /home/rasdaman/install && git clone -q git://rasdaman.org/rasdaman.git /home/rasdaman/install
WORKDIR /home/rasdaman/install

# Dependencies of rasnet protocol # TODO
#RUN apt-get install --fix-missing -y --force-yes --no-install-recommends libprotobuf-dev libzmq-dev protobuf-compiler libboost-all-dev



## 2015-01-29: BUGFIX WITH libsqlite3 (make fails because -lsqlite3 is set before objects)
RUN cp /usr/lib/x86_64-linux-gnu/libsqlite* /usr/lib/ # is this really neccessary?
RUN sed -i 's!LDFLAGS="$LDFLAGS $SQLITE3_LDFLAGS"!LDADD="$LDADD $SQLITE3_LDFLAGS"!' configure.ac
####


#RUN git checkout v9.0.5 # uncomment this if you want a tagged rasdaman version
RUN autoreconf -fi  && LIBS="-lsqlite3" ./configure --prefix=$RMANHOME --with-netcdf --with-hdf4 --with-wardir=$WEBAPPS_HOME --with-default-basedb=sqlite --enable-r --with-filedatadir=${RMANHOME}data

#--enable-rasnet # TODO

RUN make && make install
# RUN make --directory=applications/RRasdaman/ && make install --directory=applications/RRasdaman/

RUN mkdir $RASDATA && chown rasdaman $RASDATA 

# Adjust PostgreSQL configuration
RUN echo "host all  all    127.0.0.1/32   trust" >> /etc/postgresql/9.5/main/pg_hba.conf
#RUN echo "host all  all    0.0.0.0/0   trust" >> /etc/postgresql/9.5/main/pg_hba.conf # only for debugging!!!
RUN echo "local all  all      peer" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf # should be replaced with localhost in production
RUN /etc/init.d/postgresql start \
	&& su - postgres -c"psql -c\"CREATE ROLE rasdaman SUPERUSER LOGIN CREATEROLE CREATEDB UNENCRYPTED PASSWORD 'rasdaman';\"" \
	&& su - rasdaman -c"$RMANHOME/bin/create_db.sh" && su - rasdaman -c"$RMANHOME/bin/update_petascopedb.sh"

# Add persistent environment variables to container 
RUN echo "export RMANHOME=$RMANHOME" >> /etc/profile \
	&& echo "export CATALINA_HOME=$CATALINA_HOME" >> /etc/profile \
	&& echo "export PATH=\$PATH:$RMANHOME/bin" >> /etc/profile \
	&& echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile 
	
# SETUP RASGEO EXTENSTION # 

RUN mkdir /home/rasdaman/.rasdaman 
COPY ./rasconnect /home/rasdaman/.rasdaman/

# COPY SOME UTILITIES AND DEMONSTRATIONS
COPY ./demo.sh /home/rasdaman/
RUN chmod 0777 /home/rasdaman/demo.sh
COPY ./container_startup.sh /opt/
RUN chmod 0777 /opt/container_startup.sh
COPY ./rasmgr.conf $RMANHOME/etc/
COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./pgconfig.sh  /home/rasdaman/pgconfig.sh
RUN chmod 0777 /home/rasdaman/pgconfig.sh
COPY examples /home/rasdaman/examples
RUN find /home/rasdaman/examples -type d -exec chmod 0777 {} + && find /home/rasdaman/examples -type f -name "*.sh" -exec chmod 0777 {} + # Make all example scripts executable

RUN mkdir $R_LIBS

RUN chown -R rasdaman $RMANHOME
RUN chown -R rasdaman /home/rasdaman
RUN mkdir /opt/shared /opt/modisdata # TODO: Add environment variable for shared folder
RUN chmod -R 0777 /opt/shared /opt/modisdata # Allow all users writing to shared folder # This does not work yet, maybe rights for volumes are reset during docker run?

EXPOSE 7001 8080 22 5432 8787

CMD ["/usr/bin/supervisord"]