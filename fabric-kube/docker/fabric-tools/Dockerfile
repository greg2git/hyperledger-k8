# docker build .
FROM hyperledger/fabric-tools:2.2.1

RUN apk --no-cache add tar gzip curl

RUN apk add --update --no-cache python3 && ln -sf python /usr/bin/python
RUN python3 -m ensurepip

RUN pip3 install yq