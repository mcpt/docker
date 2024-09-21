FROM dmoj/runtimes-tier3

LABEL org.opencontainers.image.source="https://github.com/mcpt/wlmoj-judge"

# Keep in a seperate RUN command as this should always have a cache hit while the rest of the image may not
RUN apt-get update && \
    apt-get -y --no-install-recommends install make cmake git gcc-multilib git && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp/ && git clone https://github.com/justinmeza/lci && \
    cd lci && \
    cmake . && \
    make && \
    make install && \
    rm -rf /tmp/lci/ && \
    cd /tmp/ && \
    git clone --recursive https://github.com/mcpt/wlmoj-judge /judge && \
    cd /judge && \
    python3 -m venv --prompt=DMOJ /env && \
    /env/bin/pip3 install cython setuptools && \
    /env/bin/pip3 install -e . && \
    /env/bin/python3 setup.py develop && \
    HOME=~judge . ~judge/.profile && \
    runuser -u judge -w PATH -- /env/bin/dmoj-autoconf -V > /judge-runtime-paths.yml && \
    echo '  crt_x86_in_lib32: true' >> /judge-runtime-paths.yml

COPY config.yml /config.yml

ENTRYPOINT ["/usr/bin/tini", "--", "/judge/.docker/entry"]