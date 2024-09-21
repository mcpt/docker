FROM ghcr.io/dmoj/runtimes-tier3

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj-judge"

RUN apt-get update && \
    apt-get -y --no-install-recommends install make cmake git gcc-multilib git && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp/ && git clone https://github.com/justinmeza/lci.git && \
    cd lci && \
    cmake . && \
    make && \
    make install && \
    rm -rf /tmp/lci/

WORKDIR /judge/
RUN git clone --recurse-submodules https://github.com/mcpt/wlmoj-judge . && \
    pip install . && \
    runuser -u judge -- dmoj-autoconf -V > /judge-runtime-paths.yml && \
    echo '  crt_x86_in_lib32: true' >> /judge-runtime-paths.yml

COPY config.yml /config.yml

ENTRYPOINT ["/judge/.docker/entry"]