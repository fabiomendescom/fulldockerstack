FROM node

  	
RUN npm install express  
RUN npm install body-parser
RUN npm install passport
RUN npm install passport-http-bearer		
RUN npm install aws-sdk 
RUN npm install redis 
RUN npm install winston 
RUN npm install node-zookeeper-client 
RUN npm install cassandra-driver	
RUN npm install kafka-node 
#RUN npm install mongodb

#set to effective working dir for default command (working_dir directive doesn't work in tutum)
ENV NODE_DIR /var/www/

RUN \
	mkdir /var/log/drillix

EXPOSE 9000 

WORKDIR /var/www
	
ADD bootstrapper.sh /home/vagrant/bootstrapper.sh
RUN chmod +x /home/vagrant/bootstrapper.sh		
	
#USER node

VOLUME /var/www

ENTRYPOINT ["/home/vagrant/bootstrapper.sh"]
