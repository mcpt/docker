FROM node:alpine
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"
RUN apk add --no-cache git
WORKDIR /app/
RUN npm install qu ws simplesets

EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

ENTRYPOINT node /app/site/websocket/daemon.js
