FROM python:3.6
MAINTAINER Sergio Gordillo sergio.gordillo@vizzuality.com

ENV NAME ps
ENV USER ps

RUN apt-get update && apt-get install -yq \
    gcc \
    bash \
    git \
    build-essential \
    libcurl4-openssl-dev \
    libffi-dev \
    libjpeg-dev \
    libmysqlclient-dev \
    libpng12-dev \
    libpq-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libgdal-dev

RUN groupadd $USER && useradd -g $USER $USER -s /bin/bash

RUN easy_install pip && pip install --upgrade pip
RUN pip install virtualenv gunicorn gevent numpy

RUN mkdir -p /opt/$NAME
RUN cd /opt/$NAME && virtualenv venv && /bin/bash -c "source venv/bin/activate"
COPY requirements.txt /opt/$NAME/requirements.txt
RUN cd /opt/$NAME && pip install -r requirements.txt

COPY entrypoint.sh /opt/$NAME/entrypoint.sh
COPY main.py /opt/$NAME/main.py
COPY gunicorn.py /opt/$NAME/gunicorn.py

# Copy the application folder inside the container
WORKDIR /opt/$NAME

COPY ./$NAME /opt/$NAME/$NAME
COPY ./microservice /opt/$NAME/microservice
COPY ./tests /opt/$NAME/tests
RUN chown $USER:$USER /opt/$NAME

# Tell Docker we are going to use this ports
EXPOSE 5700
USER $USER

# Launch script
ENTRYPOINT ["./entrypoint.sh"]
