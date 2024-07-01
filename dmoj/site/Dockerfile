FROM ghcr.io/mcpt/wlmoj-base:latest

EXPOSE 8000

ADD https://raw.githubusercontent.com/mcpt/docker/master/uwsgi.ini ./uwsgi.ini

ENTRYPOINT ["uwsgi", "--ini", "uwsgi.ini"]
