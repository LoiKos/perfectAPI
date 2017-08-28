FROM swift:latest

MAINTAINER Loic LE PENN <loic.lepenn@orange.com>

RUN apt-get update

RUN apt-get install -y libssl-dev libevent-dev libsqlite3-dev libcurl4-openssl-dev libicu-dev uuid-dev

RUN apt-get install libpq-dev -y

RUN apt-get install libxml2-dev -y

ENV DATABASE_HOST=
ENV DATABASE_PORT=
ENV DATABASE_DB=
ENV DATABASE_USER=
ENV DATABASE_PASSWORD=
