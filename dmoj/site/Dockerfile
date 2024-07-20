FROM ghcr.io/mcpt/wlmoj-base:latest

RUN addgroup uwsgi && adduser -DH -G uwsgi uwsgi
USER uwsgi
EXPOSE 8000

ADD https://raw.githubusercontent.com/mcpt/docker/master/uwsgi.ini /uwsgi.ini

ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
