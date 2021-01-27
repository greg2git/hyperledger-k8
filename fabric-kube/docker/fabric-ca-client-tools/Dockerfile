# docker build .
FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

RUN pip3 install yq

RUN apt-get install -y curl tar gzip

RUN curl -L --retry 5 --retry-delay 3 https://github.com/hyperledger/fabric-ca/releases/download/v1.4.9/hyperledger-fabric-ca-linux-amd64-1.4.9.tar.gz | tar xz
RUN cp bin/fabric-ca-client /usr/local/bin
RUN chmod +x /usr/local/bin/fabric-ca-client