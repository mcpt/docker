FROM nginx:1.31.8

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"

COPY ./nginx.conf /etc/nginx/nginx.conf

ARG homeshare_id=9889
RUN groupmod -g $homeshare_id -o nginx
