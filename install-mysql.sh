#!/bin/bash
DOWNLOAD_FILE=/home/eghostsun/download
yum install perl numactl

############################
#删除老版本mysql
############################
rpm -qa|grep -i mysql

yum remove -y MySQL-server MySQL-devel mysql-libs

if [ -d "/var/lib/mysql" ]; then
	rm -rf /var/lib/mysql
	rm –rf /usr/my.cnf
	rm -rf /root/.mysql_sercret
	rm -rf /etc/my.cnf
	rm -rf /var/lib/mysql
fi
#################################
#安装mysql
#################################
if [ ! -f "MySQL-server-5.6.38-1.el6.x86_64.rpm" ]; then
	wget https://cdn.mysql.com//Downloads/MySQL-5.6/MySQL-server-5.6.38-1.el6.x86_64.rpm
	rpm -ivh MySQL-server-5.6.38-1.el6.x86_64.rpm
fi

if [ ! -f "MySQL-client-5.6.38-1.el6.x86_64.rpm" ]; then
	wget https://cdn.mysql.com//Downloads/MySQL-5.6/MySQL-client-5.6.38-1.el6.x86_64.rpm
	rpm -ivh MySQL-client-5.6.38-1.el6.x86_64.rpm
fi

if [ ! -f "MySQL-devel-5.6.38-1.el6.x86_64.rpm" ]; then
	wget https://cdn.mysql.com//Downloads/MySQL-5.6/MySQL-devel-5.6.38-1.el6.x86_64.rpm
	rpm -ivh MySQL-devel-5.6.38-1.el6.x86_64.rpm
fi
###########################
#开机启动mysql
##########################
chkconfig mysql on
############################
#配置文件
#############################
cp /usr/share/mysql/my-default.cnf /etc/my.cnf
############################
#初始化mysql数据库
#############################
/usr/bin/mysql_install_db
#############################
#启动mysql
#############################
service mysql start
#############################
#查看数据库安装情况
##############################
ps -ef|grep mysql
netstat -anpt|grep 3306
##############################
#mysql初始化账号密码
##############################
cat /root/.mysql_secret

##############################
#mysql防火墙配置
##############################
iptables -I OUTPUT -p tcp --sport 3306 -j ACCEPT
service iptables save
service iptables restart

##############################
#设置新密码 set password = password('123456');
##############################
