#!/bin/bash


ZOO=$(/home/vagrant/zookeepercli --servers $DRX_ZOOKPRSVRS -c exists $ZOOKPRREDISPATH)
if [ ! $ZOO ]; then
	echo "Creating $ZOOKPRREDISPATH service folder"
	/home/vagrant/zookeepercli --servers $ZOOKPRSVRS -c create $ZOOKPRREDISPATH redis
	echo "$ZOOKPRREDISPATH service folder created"
fi

IPADDR=$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

ZOO=$(/home/vagrant/zookeepercli --servers $ZOOKPRSVRS -c exists $ZOOKPRREDISPATH/$CONTAINERNAME)
if [ $ZOO ]; then
	/home/vagrant/zookeepercli --servers $ZOOKPRSVRS -c delete $ZOOKPRREDISPATH/$CONTAINERNAME
fi
/home/vagrant/zookeepercli --servers $ZOOKPRSVRS -c create $ZOOKPRREDISPATH/$CONTAINERNAME $IPADDR:$PORTNUMBER
echo "$CONTAINERNAME with IP $IPADDR:$PORTNUMBER registered on $ZOOKPRREDISPATH/$CONTAINERNAME on zookeeper"

redis-server 
#/usr/local/etc/redis/redis.conf
