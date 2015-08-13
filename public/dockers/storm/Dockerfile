FROM fabiomendescom/baseubuntu

RUN echo [supervisord] | tee -a /etc/supervisor/supervisord.conf ; echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf ; echo loglevel=debug | tee -a /etc/supervisor/supervisord.conf

ENV STORM_VERSION 0.9.5

# Create storm group and user
ENV STORM_HOME /usr/share/apache-storm 

RUN groupadd storm; useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm

# Download and Install Apache Storm
#RUN wget http://apache.mirrors.ovh.net/ftp.apache.org/dist/storm/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz && \
RUN wget http://mirror.metrocast.net/apache/storm/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz && \
tar -xzvf apache-storm-$STORM_VERSION.tar.gz -C /usr/share && mv $STORM_HOME-$STORM_VERSION $STORM_HOME && \
rm -rf apache-storm-$STORM_VERSION.tar.gz

RUN mkdir /var/log/storm ; chown -R storm:storm /var/log/storm ; ln -s /var/log/storm /home/storm/log
RUN ln -s $STORM_HOME/bin/storm /usr/bin/storm
ADD conf/cluster.xml $STORM_HOME/logback/cluster.xml
ADD conf/storm.yaml.nimbus.template $STORM_HOME/conf/storm.yaml.nimbus.template
ADD conf/storm.yaml.supervisor.template $STORM_HOME/conf/storm.yaml.supervisor.template

# Add scripts required to run storm daemons under supervision
ADD script/entrypoint.sh /home/storm/entrypoint.sh
ADD supervisor/storm-daemon.conf /home/storm/storm-daemon.conf

RUN chown -R storm:storm $STORM_HOME && chmod u+x /home/storm/entrypoint.sh

#COPY kstorm-1.0-SNAPSHOT-jar-with-dependencies.jar /home/storm/kstorm-1.0-SNAPSHOT-jar-with-dependencies.jar

# Add VOLUMEs to allow backup of config and logs
# VOLUME ["/usr/share/apache-storm/conf","/var/log/storm"]

WORKDIR /home/storm

EXPOSE 8080 6627 3773 3772 6700 6701 6702 6703 8000

ENTRYPOINT ["/bin/bash", "/home/storm/entrypoint.sh"]
