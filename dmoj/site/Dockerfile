FROM ghcr.io/mcpt/wlmoj-base:latest

RUN groupadd uwsgi && useradd -rm -s /bin/bash -g root -G uwsgi -u 1001 uwsgi
USER uwsgi

EXPOSE 8000

COPY --chown=uwsgi:uwsgi ../../uwsgi.ini /uwsgi.ini

ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
