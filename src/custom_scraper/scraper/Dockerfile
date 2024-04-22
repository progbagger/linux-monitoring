FROM alpine:latest

RUN apk add bash

COPY *.sh /src/

WORKDIR /src

ENTRYPOINT /src/main.sh
