#!/bin/bash
################################
#开放ip地址和端口
################################
if [ -n "$1" ]; then
	echo "请输入一个IP地址"
	exit
fi
if [ -n "$2" ]; then
	echo "请输入一个端口"
	exit
fi

iptables -I INPUT -s $1 -p tcp --dport $2 -j ACCEPT
service iptables save
service iptables restart