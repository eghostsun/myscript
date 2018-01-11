#!/bin/bash
##########################
# useradd eghostsun
# cd /home/eghostsun/
# mkdir download
#########################
yum -y update
yum install -y kernel-devel
yum install -y vim unzip
yum install -y make gcc gcc-c++
yum install -y m4 ncurses-devel

###########################
#修改ssh端口1188
###########################
sed -i 's/#Port [0-9]*/Port 1188/g' /etc/ssh/sshd_config

iptables -I INPUT -p tcp --dport 1188 -j ACCEPT
service iptables save
service iptables restart