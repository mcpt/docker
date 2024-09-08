FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl wget gnupg git unzip xvfb libxi6 libgconf-2-4 exiftool fonts-noto-core && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://storage.googleapis.com/chrome-for-testing-public/$(curl -s https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE)/linux64/chrome-linux64.zip && \
    wget https://storage.googleapis.com/chrome-for-testing-public/$(curl -s https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE)/linux64/chromedriver-linux64.zip && \
    unzip chromedriver-linux64.zip && \
    unzip chrome-linux64.zip && \
    mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    mv chrome-linux64 /usr/bin/google-chrome-stable && \
    chmod +x /usr/bin/chromedriver && \
    chmod +x /usr/bin/google-chrome-stable && \
    rm chromedriver-linux64.zip && \
    rm chrome-linux64.zip && \
    useradd -m pdfoid



RUN git clone https://github.com/mcpt/pdfoid.git pdfoid
WORKDIR /pdfoid/
RUN pip3 install -e .

ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver
ENV EXIFTOOL_PATH=/usr/bin/exiftool
ENV CHROME_PATH=/usr/bin/google-chrome-stable/chrome

EXPOSE 8888
USER pdfoid
ENTRYPOINT ["pdfoid", "--address=0.0.0.0", "--port=8888"]

