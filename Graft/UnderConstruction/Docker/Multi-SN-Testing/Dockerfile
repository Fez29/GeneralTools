FROM ubuntu:latest

ENV graftnetworkURL https://github.com/graft-project/GraftNetwork/releases/download/v1.8.2/GraftNetwork_1.8.2_ubuntu-18.04.x64.tar.gz
ENV supernodeURL https://github.com/graft-project/graft-ng/releases/download/v1.0.4/supernode.1.0.4.ubuntu-18.04.x64.tar.gz
#ENV environment --mainnet
#ENV supernode1run --config-file /home/graft/sn1/config.ini --log-file /home/graft/sn1/logs/sn1.log --log-level 1
#ENV supernode2run --config-file /home/graft/sn2/config.ini --log-file /home/graft/sn2/logs/sn2.log --log-level 1
#ENV supernode3run --config-file /home/graft/sn3/config.ini --log-file /home/graft/sn3/logs/sn3.log --log-level 1
ENV BUILDPACKAGES libnorm1 sudo wget
#ENV CREATESN_PATHS mkdir -p $HOME/sn1/logs && mkdir -p $HOME/sn2/logs && mkdir -p $HOME/sn3/logs
ENV HOME /home/graft/

RUN apt-get update && apt-get install $BUILDPACKAGES -y 

#RUN apt-get update && apt-get upgrade -y && apt-get install $BUILDPACKAGES -y

#RUN adduser graft -y

RUN useradd -m -g sudo -p "graft" graft

RUN usermod -aG sudo graft

USER graft

RUN mkdir $HOME/supernode && mkdir $HOME/graftnetwork && mkdir -p $HOME/sn1/logs && mkdir -p $HOME/sn2/logs && mkdir -p $HOME/sn3/logs

WORKDIR $HOME/supernode

RUN cd $HOME/supernode && wget -c $supernodeURL -O graftsupernode.tar.gz && mkdir graftsupernode && \
tar -zxvf ./graftsupernode.tar.gz -C $HOME/supernode --strip-components=1 && rm graftsupernode.tar.gz 

#&& \
#cp $HOME/supernode/config.ini $HOME/sn1/config.ini && \
#cp $HOME/supernode/config.ini $HOME/sn2/config.ini && \
#cp $HOME/supernode/config.ini $HOME/sn3/config.ini

WORKDIR $HOME/graftnetwork

RUN cd $HOME/graftnetwork && wget -c $graftnetworkURL -O graftnetwork.tar.gz && mkdir graftnetwork && tar -zxvf ./graftnetwork.tar.gz -C $HOME/graftnetwork --strip-components=1 && rm graftnetwork.tar.gz && pwd && ls
#\
#&& mv GraftNetwork_1.8.2_ubuntu-18.04.x64 app

#wget -c https://github.com/graft-project/GraftNetwork/releases/download/v1.7.4/GraftNetwork_1.7.4.ubuntu-18.04-x64.tar.gz -O graftnetwork.tar.gz && mkdir graftnetwork && tar -zxvf ./graftnetwork.tar.gz -C graftnetwork --strip-components=1

WORKDIR $HOME/graftnetwork
#COPY #mywallet .
#COPY #mywallet.keys .
COPY script.sh .
COPY config.ini .

USER root
RUN chown -R graft:sudo /home

EXPOSE 18980
#EXPOSE 18983
EXPOSE 18690-18710

USER graft

CMD ["/bin/bash", "-c", "/home/graft/graftnetwork/script.sh"]

# Working Docker run command - Change name and ports and volume where necessary
# docker run --name graft3 -d -p 18990:18980 -p 18690:18690 -v ~/blockchain2:/blockchain multi-sn-graft:latest