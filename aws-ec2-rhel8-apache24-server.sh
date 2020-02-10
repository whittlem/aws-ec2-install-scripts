#/bin/bash

yum update -y
yum install gcc make -y

cd ~
https://libexpat.github.io
wget https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz
tar -zxvf expat-2.2.9.tar.gz
cd expat-2.2.9
./configure --prefix=/opt/SP/expat-2.2.9
make clean && make && make install

# https://apr.apache.org/download.cgi
cd ~
wget http://mirror.vorboss.net/apache//apr/apr-1.7.0.tar.gz
tar -zxvf apr-1.7.0.tar.gz
cd apr-1.7.0
./configure --prefix=/opt/SP/apr-1.7.0
make clean && make && make install

# https://apr.apache.org/download.cgi
cd ~
wget http://www.mirrorservice.org/sites/ftp.apache.org//apr/apr-util-1.6.1.tar.gz
tar -zxvf apr-util-1.6.1.tar.gz
cd apr-util-1.6.1
./configure --prefix=/opt/SP/apr-util-1.6.1 --with-apr=/opt/SP/apr-1.7.0 --with-expat=/opt/SP/expat-2.2.9
make clean && make && make install

yum install openssl-devel pcre-devel zlib-devel -y

# https://httpd.apache.org/download.cgi#apache24
cd ~
wget http://apache.mirror.anlx.net//httpd/httpd-2.4.41.tar.gz
tar -zxvf httpd-2.4.41.tar.gz
cd httpd-2.4.41
./configure -prefix=/opt/SP/apache-2.4 \
--with-apr=/opt/SP/apr-1.7.0 \
--with-apr-util=/opt/SP/apr-util-1.6.1 \
--with-expat=/opt/SP/expat-2.2.9 \
--enable-so \
--enable-deflate \
--enable-expires \
--enable-rewrite \
--enable-ssl \
--disable-autoindex \
--enable-file-cache \
--enable-cache \
--enable-disk-cache \
--enable-mem-cache \
--enable-headers \
--enable-usertrack \
--enable-vhost-alias \
--enable-proxy \
--enable-proxy-ajp \
--enable-proxy-balancer \
--enable-proxy-fcgi \
--enable-proxy-http \
--enable-proxy-connect \
--with-pre
make clean && make && make install

sed -i 's/^User daemon\s*$/User wwwrun/' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's/^Group daemon\s*$/Group wwwrun/' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's/^Listen 80$/Listen 8080/' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's~^#LoadModule proxy_http_module modules/mod_proxy_http.so~LoadModule proxy_http_module modules/mod_proxy_http.so~' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's~^#LoadModule proxy_module modules/mod_proxy.so~LoadModule proxy_module modules/mod_proxy.so~' /opt/SP/apache-2.4/conf/httpd.conf

ln -s /opt/SP/apache-2.4 /opt/SP/apache

sed -i 's~PATH=$PATH:$HOME/bin~export PATH=$PATH:$HOME/bin~' ~/.bash_profile
sed -i '/^export PATH$/d' .bash_profile
perl -i -pe "chomp if eof" ~/.bash_profile
echo 'export PATH=$PATH:/opt/SP/apache/bin' >> ~/.bash_profile

chown -R wwwadm:www /opt/SP/apache-2.4
chmod +s /opt/SP/apache-2.4
cd ~

cp ~/aws-ec2-install-scripts/assets/services/apache /etc/init.d
chown root:root /etc/init.d/apache 
chmod 611 /etc/init.d/apache
chkconfig apache on
service apache start

netstat -antup | grep -i 8080

echo "" >> /etc/sudoers
echo "%www    ALL=(ALL)       NOPASSWD:/usr/sbin/service" >> /etc/sudoers

yum remove gcc make openssl-devel pcre-devel zlib-devel -y
