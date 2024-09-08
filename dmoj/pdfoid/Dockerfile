FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl gnupg git unzip xvfb libxi6 libgconf-2-4 exiftool && \
    apt-get update && \
    apt-get install -y --no-install-recommends fonts-noto ttf-mscorefonts-installer && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://storage.googleapis.com/chrome-for-testing-public/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/linux64/chrome-linux64.zip && \
    wget https://storage.googleapis.com/chrome-for-testing-public/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/linux64/chromedriver-linux64.zip && \
    unzip chromedriver_linux64.zip && \
    unzip chrome_linux64.zip && \
    mv chromedriver /usr/bin/chromedriver && \
    mv chrome /usr/bin/google-chrome-stable && \
    chmod +x /usr/bin/chromedriver && \
    chmod +x /usr/bin/google-chrome-stable && \
    rm chromedriver_linux64.zip && \
    rm chrome_linux64.zip && \
    useradd -m pdfoid



RUN git clone https://github.com/mcpt/pdfoid.git pdfoid
WORKDIR /pdfoid/
RUN pip3 install -e .

ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver
ENV EXIFTOOL_PATH=/usr/bin/exiftool
ENV CHROME_PATH=/usr/bin/google-chrome-stable

EXPOSE 8888
USER pdfoid
ENTRYPOINT ["pdfoid", "--address=0.0.0.0", "--port=8888"]

