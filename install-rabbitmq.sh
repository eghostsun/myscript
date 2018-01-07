#!/bin/bash
DOWNLOAD_FILE=/home/eghostsun/download

######################
#安装erlang
######################
yum install -y unixODBC-devel unixODBC ncurses-devel

cd ${DOWNLOAD_FILE}
if [ ! -f "otp_src_20.2.tar.gz" ]; then
	wget http://erlang.org/download/otp_src_20.2.tar.gz
fi
if [ ! -n "$ERL_HOME" ]; then
	tar -xvf otp_src_20.2.tar.gz
	cd otp_src_20.2
	./configure --with-ssl -enable-threads -enable-smmp-support -enable-kernel-poll --enable-hipe
	make & make install

	cd /etc/profile.d
	if [ ! -f "erlang.sh" ]; then
		touch erlang.sh
		echo "ERL_HOME=/usr/local/erlang" >> erlang.sh
		echo "PATH=$ERL_HOME/bin:$PATH" >> erlang.sh
		echo "export ERL_HOME PATH" >> erlang.sh
		source /etc/profile
	fi
fi

###########################
#安装xz
###########################
cd ${DOWNLOAD_FILE}
if [ ! -f "xz-5.2.3.tar.gz" ]; then
	wget https://tukaani.org/xz/xz-5.2.3.tar.gz
fi
tar -xvf xz-5.2.3.tar.gz
cd xz-5.2.3
./configure
make
make install

###########################
#安装rabbitmq
###########################
cd ${DOWNLOAD_FILE}
if [ ! -f "rabbitmq-server-generic-unix-3.6.14.tar.xz" ]; then
	wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.14/rabbitmq-server-generic-unix-3.6.14.tar.xz
fi
if [ -f "rabbitmq-server-generic-unix-3.6.14.tar.xz" ]; then
	xz -d rabbitmq-server-generic-unix-3.6.14.tar.xz
fi
tar -xvf rabbitmq-server-generic-unix-3.6.14.tar
mv rabbitmq_server-3.6.14/ /opt/rabbitmq

cd /etc/profile.d
if [ ! -f "rabbitmq.sh" ]; then
	touch rabbitmq.sh
	echo "export RABBITMQ_HOME=/opt/rabbitmq" >> rabbitmq.sh
	echo "export PATH=$PATH:$RABBITMQ_HOME/sbin" >> rabbitmq.sh
	source /etc/profile
fi

##########################
#后台启动rabbitmq
##########################
rabbitmq-server -detached
##########################
#启动管理平台
##########################
rabbitmq-plugins enable rabbitmq_management
##########################
#添加账号
###########################
rabbitmqctl add_user eghostsun slf19860504
rabbitmqctl set_user_tags eghostsun administrator
###########################
#启用mqtt
###########################
rabbitmq-plugins enable rabbitmq_mqtt
###########################
#配置防火墙
###########################
iptables -I INPUT -p tcp --dport 15672 -j ACCEPT
service iptables save
service iptables restart





