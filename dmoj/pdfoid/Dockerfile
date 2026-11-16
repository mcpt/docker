FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"

# Pinned via Chrome for Testing (Google's apt repo only keeps the newest build).
# Chrome bumps have OOM'd pdfoid before: raise deliberately and watch memory.
ARG CHROME_VERSION=157.0.8103.38
ARG CFT=https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl wget gnupg git unzip xvfb libxi6 libgconf-2-4 exiftool fonts-noto-core gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils \
        libgbm1 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libdrm2 libxshmfence1 libvulkan1 ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q $CFT/chrome-linux64.zip $CFT/chromedriver-linux64.zip && \
    unzip -q chrome-linux64.zip -d /opt && \
    unzip -q chromedriver-linux64.zip && \
    mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    rm -rf chrome-linux64.zip chromedriver-linux64.zip chromedriver-linux64 && \
    useradd -m pdfoid

RUN git clone https://github.com/mcpt/pdfoid.git pdfoid && git -C pdfoid checkout 1ab2768918bffb54bfd1daba4f8ec7df7955b82a
WORKDIR /pdfoid/
RUN pip3 install -e .

ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver
ENV EXIFTOOL_PATH=/usr/bin/exiftool
ENV CHROME_PATH=/opt/chrome-linux64/chrome

EXPOSE 8888
USER pdfoid
ENTRYPOINT ["pdfoid", "--address=0.0.0.0", "--port=8888"]

