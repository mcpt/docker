FROM python:3.11-slim-bookworm
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"
RUN apt-get update && \
    apt-get install -y \
        git gcc g++ make curl gettext wget \
        libxml2-dev libxslt1-dev zlib1g-dev \
        mariadb-client libmariadb-dev \
        libjpeg-dev debconf-utils pkg-config \
        uwsgi-plugin-python3 && \
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g sass@1.108.1 postcss-cli@12.0.0 postcss@8.5.32 autoprefixer@10.6.2
RUN pip3 install \
        pymysql==1.2.4 mysqlclient==2.3.1 websocket-client==1.9.2 uwsgi==2.0.31 django-redis==7.0.0 redis==8.1.0 \
        django-discord-integration==1.3.0 django[argon2,bcrypt]==4.2.30 argon2-cffi==25.1.0 bcrypt==5.0.0



ADD https://raw.githubusercontent.com/mcpt/wlmoj/revamp/requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt
