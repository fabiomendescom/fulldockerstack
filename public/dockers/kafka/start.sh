#!/bin/bash -x

EXTENSION=".default"

IP=$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

PORT=9092

cat /kafka/config/server.properties${EXTENSION} \
  | sed "s|{{ZOOKEEPER_SERVERS}}|${ZOOKPRSVRS}|g" \
  | sed "s|{{BROKER_ID}}|${BROKER_ID:-0}|g" \
  | sed "s|{{CHROOT}}|${ZKKAFKAROOT:-}|g" \
  | sed "s|{{EXPOSED_HOST}}|${EXPOSED_HOST:-$IP}|g" \
  | sed "s|{{PORT}}|${PORTNUMBER:-9092}|g" \
  | sed "s|{{EXPOSED_PORT}}|${PORTNUMBER:-9092}|g" \
   > /kafka/config/server.properties
   
cat /kafka/config/server.properties   
   
export JMX_PORT=7203

echo "Starting kafka"
exec /kafka/bin/kafka-server-start.sh /kafka/config/server.properties
