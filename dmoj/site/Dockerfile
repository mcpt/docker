FROM ghcr.io/mcpt/wlmoj-base:latest

RUN useradd -rm -s /bin/bash -g root -G uwsgi -u 1001 uwsgi
USER uwsgi

EXPOSE 8000

ADD https://raw.githubusercontent.com/mcpt/docker/master/uwsgi.ini /uwsgi.ini

ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
