FROM redis

WORKDIR /home/vagrant

RUN apt-get update
RUN apt-get -f install
RUN apt-get install -y net-tools wget	 
RUN wget -O /home/vagrant/zookeepercli https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli
RUN chmod +x /home/vagrant/zookeepercli

ADD bootstrapper.sh /home/vagrant/bootstrapper.sh
RUN chmod +x /home/vagrant/bootstrapper.sh	

ENTRYPOINT ["./bootstrapper.sh"]

#CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
