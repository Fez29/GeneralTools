FROM ubuntu:latest

RUN apt-get update && apt-get install -y wget && apt-get install libnorm1

WORKDIR /graft

RUN wget https://github.com/graft-project/GraftNetwork/releases/download/v1.8.2/GraftNetwork_1.8.2_ubuntu-18.04.x64.tar.gz && tar -zxvf GraftNetwork_1.8.2_ubuntu-18.04.x64.tar.gz \
&& mv GraftNetwork_1.8.2_ubuntu-18.04.x64 app

WORKDIR /graft/app
#COPY ./one .
COPY one.keys .

EXPOSE 18980
EXPOSE 18983
