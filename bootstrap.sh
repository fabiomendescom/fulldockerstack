#!/bin/bash

# Install docker
wget -qO- https://get.docker.com/ | sed -r 's/^apt-get install -y lxc-docker$/apt-get install lxc-docker-1.6.2/g' | sh
wget -O /home/vagrant/zookeepercli_1.0.10_amd64.deb https://github.com/outbrain/zookeepercli/releases/download/v1.0.10/zookeepercli_1.0.10_amd64.deb 
sudo dpkg -i /home/vagrant/zookeepercli_1.0.10_amd64.deb
sudo apt-get install -f


