FROM node:alpine
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"
RUN apk add --no-cache git
WORKDIR /app/
# todo: Reduce the size of the image by only importing the websocket dir
RUN npm install qu ws simplesets

EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

COPY --chmod="770" ./config.js /app/site/websocket/

ENTRYPOINT ["node", "/app/site/websocket/daemon.js"]
