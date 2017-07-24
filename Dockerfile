FROM swift:latest

MAINTAINER Loic LE PENN <loic.lepenn@orange.com>

RUN apt-get update

RUN apt-get install -y libssl-dev libevent-dev libsqlite3-dev libcurl4-openssl-dev libicu-dev uuid-dev

RUN apt-get install libpq-dev -y

RUN apt-get install libxml2-dev -y

ENV DATABASE_HOST=database
ENV DATABASE_PORT=5432
ENV DATABASE_DB=mbaoDB
ENV DATABASE_USER=Supervisor
ENV DATABASE_PASSWORD=3If6IPF6VgNIOGMvPbkPaDfBW94I9
