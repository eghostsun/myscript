#!/bin/bash
cd /home/eghostsun/download
wget http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.rpm?AuthParam=1515237747_0c628582a91e843e58d914f1d39d3fc9
mv jdk-8u151-linux-x64.rpm?AuthParam=1515237747_0c628582a91e843e58d914f1d39d3fc9 jdk-8u151-linux-x64.rpm
rpm -ivh jdk-8u151-linux-x64.rpm
rm -f jdk-8u151-linux-x64.rpm
echo "java安装完成"
java -version