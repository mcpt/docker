FROM ghcr.io/mcpt/wlmoj-base:latest

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"

RUN groupadd uwsgi && useradd -rm -s /bin/bash -g root -G uwsgi -u 1000 uwsgi
USER uwsgi

EXPOSE 8000

COPY ./scripts/copy_static ./scripts/make_style.sh /scripts/
COPY --chown=uwsgi:uwsgi ./site/uwsgi.ini /

ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
