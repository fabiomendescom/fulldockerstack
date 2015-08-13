#!/bin/bash

set -e

usage="Usage: startup.sh [(nimbus|drpc|supervisor|ui|logviewer]"

#if [ $# -lt 1 ]; then
# echo $usage >&2;
 #exit 2;
#fi

#daemons=(nimbus, drpc, supervisor, ui, logviewer)

# Create supervisor configurations for Storm daemons
create_supervisor_conf () {
    echo "Create supervisord configuration for storm daemon $1"
    cat /home/storm/storm-daemon.conf | sed s,%daemon%,$1,g | tee -a /etc/supervisor/conf.d/storm-$1.conf
}	

# done by Fabio below
# parse the DRX_ZOOKPRSVRS to remove the IPS and put in the new format for the config file
IFS=',' read -ra FULLZOOADDRS <<< "$ZOOKPRSVRS"
for FULLZOOADDR in "${FULLZOOADDRS[@]}"; do
	IFS=':' read -ra IPPORTS <<< "$FULLZOOADDR"
	ZOOIPS="$ZOOIPS    - \"${IPPORTS[0]}\"\n"
    ZOOPORT=${IPPORTS[1]}
done

# Command
case $1 in
   nimbus)
          create_supervisor_conf nimbus
          create_supervisor_conf ui
		  MYIP=$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p') 
		  echo "My IP is $MYIP"
		  echo "Registering this node as nimbus with address $MYIP"
		  awk -v ZOOIPS="$ZOOIPS" -v NIMBUS_ADDR="$MYIP" -v ZKROOT=$ZKKAFKAROOT '{
			sub(/%zookeeper%/, ZOOIPS);
			sub(/%nimbus%/, NIMBUS_ADDR);
			sub(/%ui%/, NIMBUS_ADDR);
			sub(/%zookeeperroot%/, ZKROOT);
			print;
		  }' $STORM_HOME/conf/storm.yaml.nimbus.template > $STORM_HOME/conf/storm.yaml		           
    ;;
    supervisor)
          create_supervisor_conf supervisor
          echo "Registering this node as supervisor with nimbus $NIMBUS_ADDR"
		  awk -v ZOOIPS="$ZOOIPS" -v NIMBUS_ADDR="$NIMBUSIP" -v ZKROOT=$ZKSTORMROOT '{
			sub(/%zookeeper%/, ZOOIPS);
			sub(/%nimbus%/, NIMBUS_ADDR);
			sub(/%zookeeperroot%/, ZKROOT);
			print;
		  }' $STORM_HOME/conf/storm.yaml.supervisor.template > $STORM_HOME/conf/storm.yaml	          
    ;;
    *)
        echo $usage
        exit 1;
    ;;
esac

echo "Starting supervisor"
supervisord

exit 0;
