FROM fabiomendescom/baseubuntu

RUN mkdir /kafka /data /logs

ENV KAFKA_RELEASE_ARCHIVE kafka_2.10-0.8.2.1.tgz

# Download Kafka binary distribution
ADD http://www.trieuvan.com/apache/kafka/0.8.2.1/${KAFKA_RELEASE_ARCHIVE} /tmp/
#ADD https://dist.apache.org/repos/dist/release/kafka/0.8.2.1/${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/

WORKDIR /tmp

# Install Kafka to /kafka
RUN tar -zx -C /kafka --strip-components=1 -f ${KAFKA_RELEASE_ARCHIVE} 

ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-log4j12/1.7.6/slf4j-log4j12-1.7.6.jar /kafka/libs/
ADD config /kafka/config

#Copy my start_drx.sh instead to the start.sh to apply my substitions. See my comments in it
ADD start.sh /start.sh

ADD bootstrapper.sh /bootstrapper.sh
RUN chmod +x /bootstrapper.sh

WORKDIR /home/vagrant	

# Set up a user to run Kafka
RUN groupadd kafka && \
  useradd -d /kafka -g kafka -s /bin/false kafka && \
  chown -R kafka:kafka /kafka /data /logs
USER kafka
ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

# primary, jmx
EXPOSE 9092 7203
VOLUME [ "/data", "/logs" ]

ENTRYPOINT ["/bootstrapper.sh"]
#CMD ["/start.sh"]

