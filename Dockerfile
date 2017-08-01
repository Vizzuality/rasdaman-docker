FROM debian:jessie
MAINTAINER Enrique Cornejo <enrique@cornejo.me>

# Installs dependencies

RUN apt-get -qq update && apt-get install --fix-missing -y --force-yes \
    wget \
    unzip \
    sudo \
    python


ADD http://download.rasdaman.org/installer/install.sh install.sh
RUN chmod +x install.sh

COPY vizzuality.json /tmp/rasdaman-installer/profiles/installer/vizzuality.json

RUN ./install.sh -p vizzuality