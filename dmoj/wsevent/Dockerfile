FROM node:alpine
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"
WORKDIR /app/
RUN npm install qu ws simplesets

WORKDIR /app/site
RUN git clone https://github.com/mcpt/wlmoj .

EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

ENTRYPOINT node /app/site/websocket/daemon.js
