FROM ubuntu:latest
MAINTAINER Fabio Mendes

RUN apt-get update
RUN apt-get upgrade -y

# Install Oracle JDK 7 and others useful packages
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
# Accept the Oracle license before the installation
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections 
RUN apt-get install -y oracle-java7-installer
RUN apt-get update

#allow node user to run services on port 80 and 443 (when prefixed with 'authbind')
RUN \
  apt-get update && \
  apt-get install -y apt-utils && \
  apt-get install -y authbind && \
  rm -rf /var/lib/apt/lists/* && \
  touch /etc/authbind/byport/443 && \
  touch /etc/authbind/byport/80 && \
#  chown -R node:node /etc/authbind/byport/ && \
  chmod -R 755 /etc/authbind/byport/ 

# Tells Supervisor to run interactively rather than daemonize
RUN apt-get update
RUN apt-get install -y supervisor 
RUN apt-get install -y wget 
RUN apt-get install -y tar 
RUN apt-get install -y net-tools 
RUN apt-get install -y curl	

#Install Node
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y python-software-properties python g++ make
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update

RUN apt-get install -y ca-certificates

RUN wget -O /home/zookeepercli https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli
RUN chmod +x /home/zookeepercli
