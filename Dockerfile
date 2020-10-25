FROM debian:jessie

RUN apt-get update \
  && apt-get -y --quiet --force-yes upgrade \
  && apt-get install -y --no-install-recommends ca-certificates wget gcc g++ make cmake build-essential git autoconf automake  curl libtool libtool-bin libssl-dev libcurl4-openssl-dev \
  && wget https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4.tar.gz \
  && tar xzf cmake-3.13.4.tar.gz \
  && cd cmake-3.13.4 \
  && ./bootstrap \ 
  && make \
  && make install \
  && git clone --depth=50 --branch=master git://github.com/davehorton/drachtio-server.git /usr/local/src/drachtio-server \
  && cd /usr/local/src/drachtio-server \
  && git submodule update --init --recursive \
  && ./bootstrap.sh \
  && mkdir /usr/local/src/drachtio-server/build  \
  && cd /usr/local/src/drachtio-server/build  \
  && ../configure CPPFLAGS='-DNDEBUG' CXXFLAGS='-O0' \
  && make \
  && make install \
  && apt-get purge -y --quiet --force-yes --auto-remove gcc g++ make build-essential git autoconf automake curl libtool libtool-bin \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && rm -Rf /var/log/* \
  && rm -Rf /var/lib/apt/lists/* \
  && cd /usr/local/src \
  && rm -Rf drachtio-server \
  && cd /usr/local/bin \
  && rm -f timer ssltest parser uri_test test_https test_asio_curl

COPY letsencrypt /etc/letsencrypt
COPY ./drachtio.conf.xml /etc/drachtio.conf.xml
COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["drachtio"]
