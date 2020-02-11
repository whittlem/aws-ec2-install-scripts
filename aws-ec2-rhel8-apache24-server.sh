#/bin/bash

yum update -y
yum install gcc make -y

# https://libexpat.github.io
cd ~
wget https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz
tar -zxvf expat-2.2.9.tar.gz
cd expat-2.2.9
./configure --prefix=/opt/SP/expat-2.2.9
make clean && make && make install

# https://github.com/nghttp2/nghttp2/releases
cd ~
wget https://github.com/nghttp2/nghttp2/releases/download/v1.40.0/nghttp2-1.40.0.tar.gz
tar -zxvf nghttp2-1.40.0.tar.gz
cd nghttp2-1.40.0
./configure --prefix=/opt/SP/nghttp2-1
make clean && make && make install

# https://apr.apache.org/download.cgi
cd ~
wget http://mirror.vorboss.net/apache//apr/apr-1.7.0.tar.gz
tar -zxvf apr-1.7.0.tar.gz
cd apr-1.7.0
./configure --prefix=/opt/SP/apr-1.7.0
make clean && make && make install

yum install openldap-devel -y

# https://apr.apache.org/download.cgi
cd ~
wget http://www.mirrorservice.org/sites/ftp.apache.org//apr/apr-util-1.6.1.tar.gz
tar -zxvf apr-util-1.6.1.tar.gz
cd apr-util-1.6.1
./configure --prefix=/opt/SP/apr-util-1.6.1 \
--with-apr=/opt/SP/apr-1.7.0 \
--with-expat=/opt/SP/expat-2.2.9 \
--with-ldap \
--with-ldap-lib=/usr/lib64 \
--with-ldap-include=/etc/openldap
make clean && make && make install

yum install openssl-devel pcre-devel zlib-devel -y

# https://httpd.apache.org/download.cgi#apache24
cd ~
wget http://apache.mirror.anlx.net//httpd/httpd-2.4.41.tar.gz
tar -zxvf httpd-2.4.41.tar.gz
cd httpd-2.4.41
./configure --prefix=/opt/apache-2.4 \
--with-apr=/opt/SP/apr-1.7.0 \
--with-apr-util=/opt/SP/apr-util-1.6.1 \
--libdir=/opt/apache-2.4/lib64 \
--enable-nonportable-atomics=yes \
--with-devrandom=/dev/urandom \
--with-ldap \
--enable-authnz-ldap \
--with-crypto \
--with-gdbm \
--with-ssl \
--enable-mods-shared=all \
--enable-mpms-shared=all \
--enable-authnz_fcgi \
--enable-cgi \
--enable-pie \
--enable-http2 \
--enable-proxy-http2 \
--with-nghttp2=/opt/SP/nghttp2-1 ac_cv_openssl_use_errno_threadid=yes
make clean && make && make install

sed -i 's/^User daemon\s*$/User wwwrun/' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's/^Group daemon\s*$/Group wwwrun/' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's/^Listen 80$/Listen 8080/' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's~^#LoadModule proxy_http_module modules/mod_proxy_http.so~LoadModule proxy_http_module modules/mod_proxy_http.so~' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's~^#LoadModule proxy_module modules/mod_proxy.so~LoadModule proxy_module modules/mod_proxy.so~' /opt/SP/apache-2.4/conf/httpd.conf
sed -i 's~/opt/SP/apache-2.4/htdocs~/var/SP/httpd/htdocs~g' /opt/SP/apache-2.4/conf/httpd.conf

ln -s /opt/SP/apache-2.4 /opt/apache-2.4
ln -s /opt/SP/apache-2.4 /opt/SP/apache
chown -R wwwadm:www /opt/SP/apache-2.4

sed -i 's~PATH=$PATH:$HOME/bin~export PATH=$PATH:$HOME/bin~' ~/.bash_profile
sed -i '/^export PATH$/d' .bash_profile
perl -i -pe "chomp if eof" ~/.bash_profile
echo 'export PATH=$PATH:/opt/SP/apache/bin' >> ~/.bash_profile

chown -R wwwadm:www /opt/SP/apache-2.4
chmod +s /opt/SP/apache-2.4
cd ~

mkdir -p /var/SP/httpd
chown -R wwwadm:www /var/SP/httpd
mv /opt/SP/apache-2.4/htdocs /var/SP/httpd

cp ~/aws-ec2-install-scripts/assets/services/apache /etc/init.d
chown root:root /etc/init.d/apache 
chmod 611 /etc/init.d/apache
chkconfig apache on
service apache start

netstat -antup | grep -i 8080

echo "" >> /etc/sudoers
echo "%www    ALL=(ALL)       NOPASSWD:/usr/sbin/service" >> /etc/sudoers

yum remove gcc make openldap-devel openssl-devel pcre-devel zlib-devel -y
