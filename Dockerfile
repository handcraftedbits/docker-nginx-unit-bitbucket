FROM handcraftedbits/nginx-unit-java:8.112.15
MAINTAINER HandcraftedBits <opensource@handcraftedbits.com>

ARG BITBUCKET_VERSION=4.12.0

ENV BITBUCKET_HOME /opt/data/bitbucket

COPY data /

RUN apk update && \
  apk add ca-certificates git mercurial wget && \

  cd /opt && \
  wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz && \
  tar -xzvf atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz && \
  rm atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz && \
  mv atlassian-bitbucket-${BITBUCKET_VERSION} bitbucket && \

  apk del wget

EXPOSE 7990
EXPOSE 7999

CMD ["/bin/bash", "/opt/container/script/run-bitbucket.sh"]
