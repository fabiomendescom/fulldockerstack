#!/bin/bash

set -e

export MAINROOT="TEST"

export ZOOKPRKAFKAPATH="/$MAINROOT/KAFKA"
export ZOOKPRSTORMPATH="/$MAINROOT/STORM"
export ZOOKPRREDISPATH="/$MAINROOT/REDIS"

export ZOOKPRSVRS=$(ifconfig docker0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

echo ""
CONTAINER="zookeeper"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/zookeeper image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null || true
sudo docker run -d \
	--name="$CONTAINER" \
	--net=host \
	-p 2181:2181 -p 2888:2888 -p 3888:3888 \
	fabiomendescom/zookeeper \
	|| true
	
sleep 6	
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER /home/zookeepercli --servers $ZOOKPRSVRS -c ls /  | grep "zookeeper"  \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"

echo ""
CONTAINER="redis"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/redis image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null || true
sudo docker run -d \
	--name="$CONTAINER" \
	-e "ZOOKPRSVRS=$ZOOKPRSVRS" \
	-e "CONTAINERNAME=$CONTAINER" \
	-e "PORTNUMBER=6379" \
	-e "ZOOKPRREDISPATH=$ZOOKPRREDISPATH" \
	-p 6379:6379 \
	fabiomendescom/redis \
	|| true
sleep 4
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER redis-cli ping	| grep "PONG" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ">>> Finished $CONTAINER testing"

echo ""
CONTAINER="kafka" 
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/kafka image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null || true
sudo docker run -d \
	--name="$CONTAINER" \
	-e "CONTAINERNAME=$CONTAINER" \
	-e "ZOOKPRSVRS=$ZOOKPRSVRS" \
	-e "BROKER_ID=1" \
	-e "ZKKAFKAROOT=$ZOOKPRKAFKAPATH" \
	-p 9092:9092 \
	fabiomendescom/kafka \
	|| true
sleep 20
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER bin/kafka-topics.sh --zookeeper $ZOOKPRSVRS$ZOOKPRPATH --list \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"

echo ""
CONTAINER="cassandra"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/cassandra image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null  || true
sudo docker run -d \
	--name="$CONTAINER" \
	-e "CONTAINERNAME=$CONTAINER" \
	-e "ZOOKPRSVRS=$ZOOKPRSVRS" \
	-p 7000:7000 -p 7199:7199 -p 9042:9042 -p 9160:9160 -p 61621:61621 \
	fabiomendescom/cassandra \
	|| true
sleep 20	
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER cqlsh -u cassandra -p cassandra -e "describe keyspaces;" $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER) 9042 | grep "system_traces" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"

echo ""		
CONTAINER="nimbus"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/storm image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null || true
sudo docker run -d \
	--name="$CONTAINER" \
	-e "CONTAINERNAME=$CONTAINER" \
	-e "ZOOKPRSVRS=$ZOOKPRSVRS" \
	-e "ZKKAFKAROOT=$ZOOKPRKAFKAPATH" \
	-p 6627:6627 -p 8080:8080 \
	-p 3773:3773 -p 3772:3772 \
	-p 8000:8000 \
	fabiomendescom/storm nimbus \
	|| true
sleep 20	
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER storm list | grep "No topologies running" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"

echo ""	
CONTAINER="supervisor"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/storm image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null  || true
sudo docker run -d \
	--name="$CONTAINER" \
	-e "CONTAINERNAME=$CONTAINER" \
	-e "ZOOKPRSVRS=$ZOOKPRSVRS" \
	-e "ZKSTORMROOT=ZOOKPRSTORMPATH" \
	-e "NIMBUSIP=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nimbus)" \
	-e "KAFKAIP=$$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' kafka)" \
	-p 6700:6700 -p 6701:6701 -p 6702:6702 -p 6703:6703 \
	fabiomendescom/storm supervisor \
	|| true
sleep 20	
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER storm list | grep "No topologies running" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"	

sleep 15

echo ""			
CONTAINER="wordcounter"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/nodemicroservice image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null || true
sudo docker run -d \
	--name="$CONTAINER" \
	-e "CONTAINERNAME=$CONTAINER" \
	-e "ZOOKPRSVRS=$ZOOKPRSVRS" \
	-e "ZKKAFKAROOT=$ZOOKPRKAFKAPATH" \
	-e "KAFKAIP=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' kafka)" \
	-e "PORTNUMBER=9000" \
	-v /vagrant/public/containers/wordcounter/code:/var/www \
	-p 9000:9000 \
	fabiomendescom/nodemicroservice \
	|| true
sleep 20	
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER ps -aux | grep "node" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"	

echo ""
CONTAINER="nginx"
echo ">>> STARTING $CONTAINER CONTAINER from fabiomendescom/nginx image"
sudo docker kill $CONTAINER &> /dev/null || true
sudo docker rm $CONTAINER &> /dev/null || true
sudo docker run -d \
	--name="$CONTAINER" \
	-p 80:80 \
	-v /vagrant/public/containers/nginx/conf:/etc/nginx \
	-v /vagrant/public/containers/nginx/www:/home/www \
	fabiomendescom/nginx \
	|| true
echo ">>> FINISHED $CONTAINER CONTAINER. IP: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER)"		
echo ">>> Testing $CONTAINER container"
sudo docker exec -it $CONTAINER ps -aux | grep "nginx" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
echo ">>> Finished $CONTAINER testing"

sleep 10

# Update the nginx settings with the generated IP addresses
cat /vagrant/public/containers/nginx/conf/nginx.conf.template \
  | sed "s|{{MICROSERVER}}|$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' wordcounter):9000|g" \
  | sed "s|{{SERVERNAME}}|$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nginx)|g" \
   > /vagrant/public/containers/nginx/conf/nginx.conf \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"    
   
# Reload nginx to pick up the latest settings  
sudo docker exec -it nginx nginx -s reload \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"  


# You need to create the events prior. Even though the first call to add to the queue creates the queue, 
# a bug causes the first call to fail. To avoid this, we just create prior
sudo docker exec -it kafka bin/kafka-topics.sh --zookeeper $ZOOKPRSVRS$ZOOKPRKAFKAPATH --create --partitions 1 --replication-factor 1 --topic sentences | grep "Created topic" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 

sudo docker exec -it cassandra cqlsh -u cassandra -p cassandra -e "create keyspace test with replication = {'class':'SimpleStrategy','replication_factor':3};" $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' cassandra) 9042 \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
sudo docker exec -it cassandra cqlsh -u cassandra -p cassandra -e "create table test.sentences (eventuuid uuid PRIMARY KEY,requestuuid uuid,tenantid uuid,dataset text,fields map<text,text>);" $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' cassandra) 9042 \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 

echo "Enter a few transactions"
# Enter a few transactions through the main URL
curl -i -H "Content-Type: application/json" -H "Authorization: bearer E95C52F99868D96F6791264A1AE4A" \
-X POST -d '{"sentences":[{"sentence": "Sentence 1"}]}' \
http://$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nginx)/sentence > /tmp/xxxxxxasldkjf.out
cat /tmp/xxxxxxasldkjf.out | grep "success" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 

curl -i -H "Content-Type: application/json" -H "Authorization: bearer E95C52F99868D96F6791264A1AE4A" \
-X POST -d '{"sentences":[{"sentence": "Sentence 2"}]}' \
http://$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nginx)/sentence > /tmp/xxxxxxasldkjf.out
cat /tmp/xxxxxxasldkjf.out | grep "success" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"  


curl -i -H "Content-Type: application/json" -H "Authorization: bearer E95C52F99868D96F6791264A1AE4A" \
-X POST -d '{"sentences":[{"sentence": "Sentence 3"}]}' \
http://$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nginx)/sentence > /tmp/xxxxxxasldkjf.out
cat /tmp/xxxxxxasldkjf.out | grep "success" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 


echo ""
echo ""

echo "List the kafka messages"
echo ""
sudo docker exec -it kafka bin/kafka-console-consumer.sh --zookeeper $ZOOKPRSVRS$ZOOKPRKAFKAPATH \
--topic sentences \
--from-beginning --max-messages 3 | grep "Consumed 3 messages" \
  && echo "PASSED" \
  || echo "TEST: FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 


echo ""
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "All dockers successfully implemented"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "========================================"
echo "Zookeeper ...........: $(ifconfig docker0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"
echo "Redis ...............: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis)"
echo "Kafka ...............: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' kafka)"
echo "Cassandra ...........: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' cassandra)"
echo "Nimbus ..............: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nimbus)"
echo "Supervisor ..........: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' supervisor)"
echo "Wordcounter .........: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' wordcounter)"
echo "Nginx ...............: $(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' nginx)"
echo "========================================"
echo ""
echo ""
