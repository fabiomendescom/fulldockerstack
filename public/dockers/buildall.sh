#!/bin/bash -l

set -e

echo "baseubuntu" 
sudo docker build -t fabiomendescom/baseubuntu -f baseubuntu/Dockerfile baseubuntu
echo "zookeeper"
sudo docker build -t fabiomendescom/zookeeper -f zookeeper/Dockerfile zookeeper   
echo "redis"
sudo docker build -t fabiomendescom/redis -f redis/Dockerfile redis 
echo "cassandra"
sudo docker build -t fabiomendescom/cassandra -f cassandra/Dockerfile cassandra
echo "nginx"
sudo docker build -t fabiomendescom/nginx -f nginx/Dockerfile nginx  
echo "kafka"
sudo docker build -t fabiomendescom/kafka -f kafka/Dockerfile kafka
echo "storm"
sudo docker build -t fabiomendescom/storm -f storm/Dockerfile storm
echo "nodemicroservice"
sudo docker build -t fabiomendescom/nodemicroservice -f nodemicroservice/Dockerfile nodemicroservice
  
#sudo docker push fabiomendescom/baseubuntu
#sudo docker push fabiomendescom/zookeeper
#sudo docker push fabiomendescom/redis
#sudo docker push fabiomendescom/cassandra
#sudo docker push fabiomendescom/nginx
#sudo docker push fabiomendescom/kafka
#sudo docker push fabiomendescom/storm
#sudo docker push fabiomendescom/nodemicroservice
