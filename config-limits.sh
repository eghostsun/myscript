#!/bin/bash
#########################
#修改系统最大连接数
#########################
echo "*       soft    nofile  65535" >> /etc/security/limits.conf
echo "*       hard    nofile  65535" >> /etc/security/limits.conf
echo "*       soft    nproc  65535" >> /etc/security/limits.conf 
echo "*       hard    nproc  65535" >> /etc/security/limits.conf 
cat /etc/security/limits.conf 
echo "session    required     pam_limits.so" >> /etc/pam.d/login
cat /etc/pam.d/login
reboot