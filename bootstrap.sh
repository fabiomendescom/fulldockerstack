#!/bin/bash

# Install docker
wget -qO- https://get.docker.com/ | sh
wget -O /home/vagrant/zookeepercli_1.0.10_amd64.deb https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli_1.0.10_amd64.deb 
sudo dpkg -i /home/vagrant/zookeepercli_1.0.10_amd64.deb
sudo apt-get install -f
#sudo echo "export ZOOKPRSVRS=$(ifconfig docker0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'):2181" >> /etc/profile
#source /etc/profile

# Start all containers
cd /vagrant
./startall.sh

