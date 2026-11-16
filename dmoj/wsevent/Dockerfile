FROM node:26.13.0-alpine3.24
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"
RUN apk add --no-cache git
WORKDIR /app/
# todo: Reduce the size of the image by only importing the websocket dir
RUN npm install qu@0.1.0 ws@8.22.1 simplesets@1.2.0

EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

COPY --chmod="770" ./config.js ./entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
