FROM ghcr.io/mcpt/wlmoj-base:latest

RUN groupadd uwsgi && useradd -rm -s /bin/bash -g root -G uwsgi -u 1001 uwsgi
USER uwsgi

EXPOSE 8000

COPY ./scripts/copy_static ./scripts/make_style.sh /scripts/
COPY --chown=uwsgi:uwsgi ./site/uwsgi.ini ./site/entrypoint.sh /

ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
