FROM python:3.11-slim-bookworm
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"
RUN apt-get update && \
    apt-get install -y \
        git gcc g++ make curl gettext wget \
        libxml2-dev libxslt1-dev zlib1g-dev \
        mariadb-client libmariadb-dev \
        libjpeg-dev debconf-utils pkg-config \
        uwsgi-plugin-python3 && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g sass postcss-cli postcss autoprefixer
RUN pip3 install \
        pymysql mysqlclient websocket-client uwsgi django-redis redis django-discord-integration



ADD https://raw.githubusercontent.com/mcpt/wlmoj/revamp/requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt
