#!/bin/bash
DOWNLOAD_DIR=/home/eghostsun/download
cd ${DOWNLOAD_DIR}

if [ ! -f "nginx-1.13.8.tar.gz" ]; then
	wget http://nginx.org/download/nginx-1.13.8.tar.gz
fi
if [ ! -f "LuaJIT-2.0.5.tar.gz" ]; then
	wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz
fi
if [ ! -f "v0.3.0.tar.gz" ]; then
wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
fi
if [ ! -f "v0.10.12rc1.tar.gz" ]; then
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.12rc1.tar.gz
fi
if [ ! -f "pcre-8.41.tar.gz" ]; then
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz
fi
if [ ! -f "zlib-1.2.11.tar.gz" ]; then
wget http://www.zlib.net/zlib-1.2.11.tar.gz
fi
if [ ! -f "openssl-1.0.1e.tar.gz" ]; then
wget https://www.openssl.org/source/old/1.0.1/openssl-1.0.1e.tar.gz
fi

##########################################
##安装zlib
##########################################
tar -xvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make & make install

##########################################
##安装pcre
##########################################
cd ${DOWNLOAD_DIR}
tar -xvf pcre-8.41.tar.gz
cd pcre-8.41
./configure
make & make install

##########################################
##安装lua
##########################################
cd ${DOWNLOAD_DIR}
tar -xvf LuaJIT-2.0.5.tar.gz
cd LuaJIT-2.0.5
make & make install

cd /etc/profile.d
touch lua.sh
echo "export LUAJIT_LIB=/usr/local/lib" >> lua.sh
echo "export LUAJIT_INC=/usr/local/include/luajit-2.0" >> lua.sh

source /etc/profile

##########################################
##解压openssl
##########################################
cd ${DOWNLOAD_DIR}
tar -xvf openssl-1.0.1e.tar.gz

##########################################
##解压nginx模块
##########################################
#ngx_devel_kit
cd ${DOWNLOAD_DIR}
tar -xvf v0.3.0.tar.gz
#lua-nginx-module
cd ${DOWNLOAD_DIR}
tar -xvf v0.10.12rc1.tar.gz

##########################################
##安装nginx
##########################################
cd ${DOWNLOAD_DIR}
tar -xvf nginx-1.13.8.tar.gz
cd nginx-1.13.8
./configure --with-http_ssl_module --with-pcre=../pcre-8.41 --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.0.1e --add-module=../ngx_devel_kit-0.3.0 --add-module=../lua-nginx-module-0.10.12rc1
make
make install

cd /etc/profile.d
touch nginx.sh
echo "export PATH=$PATH:/usr/local/nginx/sbin" >> nginx.sh
source /etc/profile

#加载动态链接库
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

nginx
##########################################
#location /lua {
#    default_type 'text/html';
#
#    content_by_lua_file conf/lua/test.lua; #相对于nginx安装目录
#}
#########################################

#iptables -I INPUT -p tcp --dport 80 -j ACCEPT

#service iptables save
#service iptables restart

