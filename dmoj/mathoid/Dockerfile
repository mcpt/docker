FROM node:10.21.0
LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"

RUN npm install mathoid && \
    ln -sfv /node_modules/mathoid/app.js /node_modules/app.js

EXPOSE 10044
WORKDIR /node_modules/mathoid

COPY ./config.yaml ./config.yaml

CMD ["server.js"]
