FROM nginx

RUN apt-get update
RUN apt-get -f install
RUN apt-get install -y net-tools 	
RUN apt-get install -y wget

RUN wget -O /home/zookeepercli https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli
RUN chmod +x /home/zookeepercli

VOLUME /etc/nginx
VOLUME /etc/ssl
VOLUME /home/www
VOLUME /home/logs

EXPOSE 80 443
