FROM debian:jessie
MAINTAINER Enrique Cornejo <enrique@cornejo.me>

# The rasdaman installer likes to `source` stuff
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Nightly might not be ideal for production, but
# stable fails as of Feb. 2016.
RUN echo "deb [arch=amd64] http://download.rasdaman.org/packages/deb jessie nightly" | tee /etc/apt/sources.list.d/rasdaman.list

RUN apt-get -qq update && apt-get install --fix-missing -y --force-yes python-pip sudo
RUN pip install --upgrade pip
RUN pip install 'requests[security]'
RUN apt-get -qq update && apt-get install --fix-missing -y --force-yes \
    rasdaman && \
    rm -rf /var/lib/apt/lists/
RUN source /etc/profile.d/rasdaman.sh
RUN /opt/rasdaman/bin/start_rasdaman.sh
