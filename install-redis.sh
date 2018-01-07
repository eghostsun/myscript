#!/bin/bash
yum install -y tcl
DOWNLOAD_FILE=/home/eghostsun/download
if [ ! -f "redis-4.0.6.tar.gz" ]; then
	wget http://download.redis.io/releases/redis-4.0.6.tar.gz
fi
tar -xvf redis-4.0.6.tar.gz
cd redis-4.0.6
make

make install

cd utils
./install_server.sh

netstat -aon | grep '6379'

