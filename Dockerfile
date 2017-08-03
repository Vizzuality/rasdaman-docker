FROM debian:jessie
LABEL maintainer="enrique.cornejo@vizzuality.com"

ENV HDF5_DIR /usr/include/hdf5

RUN echo "deb [arch=amd64] http://download.rasdaman.org/packages/deb jessie stable" | tee /etc/apt/sources.list.d/rasdaman.list

RUN apt-get -qq update && apt-get install --fix-missing -y --force-yes \
    make  libtool  gawk  autoconf bison  flex  git  g++  unzip  libboost-all-dev libtiff-dev  libgdal-dev  zlib1g-dev  libffi-dev libnetcdf-dev  libedit-dev  libreadline-dev  libecpg-dev libsqlite3-dev  libgrib-api-dev  libgrib2c-dev  curl libnetcdf-dev python python-pip libhdf5-dev postgresql  postgresql-contrib  sqlite3  zlib1g gdal-bin  python-dev  debianutils python-dateutil  python-lxml  python-grib  python-pip python-gdal  libnetcdf-dev  netcdf-bin  libnetcdfc++4  libecpg6 libboost-all-dev  libedit-dev  python-netcdf  libreadline-dev cmake ccache automake autotools-dev m4 openjdk-7-jre

RUN ln -s /usr/include/hdf5/serial /usr/include/hdf5/include

# COPY osinstaller.py /opt/rasdaman/share/rasdaman/installer/tpinstaller/osinstaller.py
# RUN python /opt/rasdaman/share/rasdaman/installer/main.py /opt/rasdaman/share/rasdaman/installer/profiles/package/deb/default.json

# Creating user rasdaman
RUN useradd -r -d /opt/rasdaman/ rasdaman

# Installing pip packages
RUN pip install --upgrade pip && \
    pip install glob2 netcdf

# Creating directory structure
RUN mkdir -p /opt/rasdaman && \
    chown -R rasdaman /opt/rasdaman && \
    chmod +x /opt/rasdaman && \
    chmod +x /opt && \
    chmod +x && \
    mkdir -p /opt/rasdaman/third_party

# Setting the profile
RUN chmod -R +x /etc/profile.d/rasdaman.sh

# Linking
RUN ldconfig

