#!/bin/bash
#安装必要的包
yum install -y perl ppp make gcc gmp gmp-devel gawk flex bison iproute iptables xmlto libpcap-devel lsof

#安装openswan
cd /home/eghostsun/download
if [ ! -f "openswan-2.6.48.tar.gz" ]; then
	wget https://download.openswan.org/openswan/openswan-2.6.48.tar.gz
fi
tar -xvf openswan-2.6.48.tar.gz
cd openswan-2.6.48
make programs install

#安装xl2tpd
cd /home/eghostsun/download
if [ ! -f "xl2tpd-1.3.1" ]; then
	wget https://download.openswan.org/xl2tpd/xl2tpd-1.3.1.tar.gz
fi
tar -xvf xl2tpd-1.3.1.tar.gz
cd xl2tpd-1.3.1
make & make install

#配置访问密钥
cd ..
ipaddress=`ifconfig eth0 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}'`
touch /etc/ipsec.secrets
echo "${ipaddress} %any 0.0.0.0: PSK \"test\"" > /etc/ipsec.secrets
cat /etc/ipsec.secrets

#配置ppp访问账号
CHAP_FILE=/etc/ppp/chap-secrets
if [ -f "${CHAP_FILE}" ]; then
	mv ${CHAP_FILE} ${CHAP_FILE}.back
else
	touch ${CHAP_FILE}
fi
echo "slf * \"slf19860504\" *" > ${CHAP_FILE}
cat ${CHAP_FILE}

OPT_FILE=/etc/ppp/options.xl2tpd
#配置xl2tpd网络信息
if [ -f "${OPT_FILE}" ]; then
	mv ${OPT_FILE} ${OPT_FILE}.back
else
	touch ${OPT_FILE} 
fi
echo "ipcp-accept-local" >> ${OPT_FILE}
echo "ipcp-accept-remote" >> ${OPT_FILE}
echo "ms-dns 8.8.8.8" >> ${OPT_FILE}
echo "noccp" >> ${OPT_FILE}
echo "auth" >> ${OPT_FILE}
echo "crtscts" >> ${OPT_FILE}
echo "idle 1800" >> ${OPT_FILE}
echo "mtu 1200" >> ${OPT_FILE}
echo "mru 1200" >> ${OPT_FILE}
echo "nodefaultroute" >> ${OPT_FILE}
echo "debug" >> ${OPT_FILE}
echo "lock" >> ${OPT_FILE}
echo "proxyarp" >> ${OPT_FILE}
echo "connect-delay 10000" >> ${OPT_FILE}
cat ${OPT_FILE}

#配置/etc/ipsec.conf
IPSEC_FILE=/etc/ipsec.conf
if [ -f "${IPSEC_FILE}" ]; then
	mv ${IPSEC_FILE} ${IPSEC_FILE}.back
fi
touch ${IPSEC_FILE}
echo "version 2.0" >> ${IPSEC_FILE}
echo "config setup" >> ${IPSEC_FILE}
echo -e "\tnat_traversal=yes" >> ${IPSEC_FILE}
echo -e "\tvirtual_private=%v4:192.168.0.0/16,%v4:25.0.0.0/8,%v4:192.168.1.0/24" >> ${IPSEC_FILE}
echo -e "\tprotostack=netkey" >> ${IPSEC_FILE}
echo -e "\tinterfaces="%defaultroute"" >> ${IPSEC_FILE}
echo -e "\toe=off" >> ${IPSEC_FILE}
echo -e "conn l2tp-psk" >> ${IPSEC_FILE}
echo -e "\tauthby=secret" >> ${IPSEC_FILE}
echo -e "\tpfs=no" >> ${IPSEC_FILE}
echo -e "\tauto=add" >> ${IPSEC_FILE}
echo -e "\trekey=no" >> ${IPSEC_FILE}
echo -e "\ttype=transport" >> ${IPSEC_FILE}
echo -e "\tleft=${ipaddress}" >> ${IPSEC_FILE}
echo -e "\tleftprotoport=17/1701" >> ${IPSEC_FILE}
echo -e "\tright=%any" >> ${IPSEC_FILE}
echo -e "\trightprotoport=17/%any" >> ${IPSEC_FILE}
echo -e "\trightsubnet=vhost:%priv,%no" >> ${IPSEC_FILE}
cat ${IPSEC_FILE}

#配置xl2tpd文件
XL2TP_FILE=/etc/xl2tpd/xl2tpd.conf
mkdir /var/run/xl2tpd
mkdir /etc/xl2tpd
if [ -f "${XL2TP_FILE}" ]; then
	mv ${XL2TP_FILE} ${XL2TP_FILE}.back
else	
	touch ${XL2TP_FILE}
fi
echo "[global]" >> ${XL2TP_FILE}
echo "listen-addr = ${ipaddress}" >> ${XL2TP_FILE}
echo "ipsec saref = no" >> ${XL2TP_FILE}
echo "[lns default]" >> ${XL2TP_FILE}
echo "ip range = 192.168.1.128-192.168.1.254" >> ${XL2TP_FILE}
echo "local ip = 192.168.1.99" >> ${XL2TP_FILE}
echo "assign ip = yes" >> ${XL2TP_FILE}
echo "require chap = yes" >> ${XL2TP_FILE}
echo "refuse pap = yes" >> ${XL2TP_FILE}
echo "require authentication = yes" >> ${XL2TP_FILE}
echo "name = OpenswanVPN" >> ${XL2TP_FILE}
echo "ppp debug = yes" >> ${XL2TP_FILE}
echo "pppoptfile = /etc/ppp/options.xl2tpd" >> ${XL2TP_FILE}
echo "length bit = yes" >> ${XL2TP_FILE}

cat ${XL2TP_FILE}

#修改定向内容/etc/sysctl.conf
SYSCTL_FILE=/etc/sysctl.conf
sed -i 's/net.ipv4.ip_forward = [0-9a-zA-Z\.\/]*/net.ipv4.ip_forward = 1/g' ${SYSCTL_FILE}
sed -i 's/net.ipv4.conf.default.rp_filter = [0-9a-zA-Z\.\/]*/net.ipv4.conf.default.rp_filter = 0/g' ${SYSCTL_FILE}
sed -i 's/net.ipv4.conf.default.accept_source_route = [0-9a-zA-Z\.\/]*/net.ipv4.conf.default.accept_source_route = 0/g' ${SYSCTL_FILE}

echo "net.ipv4.conf.all.send_redirects = 0" >> ${SYSCTL_FILE}
echo "net.ipv4.conf.default.send_redirects = 0" >> ${SYSCTL_FILE}
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> ${SYSCTL_FILE}
cat ${SYSCTL_FILE}


#修改关闭系统网络重定向功能
for each in /proc/sys/net/ipv4/conf/*
do
echo 0 > $each/accept_redirects
echo 0 > $each/send_redirects
echo 0 > $each/rp_filter
done

#加载系统参数
sysctl -p

/etc/init.d/ipsec start
xl2tpd -c /etc/xl2tpd/xl2tpd.conf &
#验证配置结果
ipsec verify

#配置防火墙
iptables -I INPUT -p udp --dport 1701 -j ACCEPT
iptables -I INPUT -p udp --dport 500 -j ACCEPT
iptables -I INPUT -p udp --dport 4500 -j ACCEPT
iptables -I OUTPUT -p udp -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE
iptables -I FORWARD -s 192.168.1.0/24 -j ACCEPT
iptables -I FORWARD -d 192.168.1.0/24 -j ACCEPT
service iptables save
service iptables restart




