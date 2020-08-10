#!/usr/bin/bash

yum update -y
yum install gcc gcc-c++ make python3-docutils -y

cd ~
wget https://github.com/skvadrik/re2c/releases/download/1.1.1/re2c-1.1.1.tar.gz
tar zxvf re2c-1.1.1.tar.gz
cd re2c-1.1.1
./configure --prefix=/opt/SP/re2c --enable-docs
make clean && make && make install
echo 'export PATH=$PATH:/opt/SP/re2c/bin' >> ~/.bash_profile
cd ~
source .bash_profile

cd ~
wget https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3.tar.gz
tar zxvf cmake-3.13.3.tar.gz
cd cmake-3.13.3
./bootstrap
make clean && make && make DESTDIR=/opt/SP/cmake install
echo 'export PATH=$PATH:/opt/SP/cmake/usr/local/bin' >> ~/.bash_profile
cd ~
source .bash_profile

yum install zlib-devel -y

cd ~
wget https://libzip.org/download/libzip-1.5.1.tar.xz
tar xf libzip-1.5.1.tar.xz
cd libzip-1.5.1
mkdir build
cd build
/opt/SP/cmake/usr/local/bin/cmake ..
make && make test && make install
echo "/usr/local/lib64" >> /etc/ld.so.conf
ldconfig

yum install libaio-level m4 -y

cd ~
wget https://ftp.gnu.org/gnu/bison/bison-3.5.tar.gz
tar -zxvf bison-3.5.tar.gz 
cd bison-3.5
./configure --prefix=/opt/SP/bison-3.5
make clean && make && make install
ln -s /opt/SP/bison-3.5 /opt/SP/bison
echo 'export PATH=$PATH:/opt/SP/bison/bin' >> ~/.bash_profile
cd ~
source .bash_profile

yum install autoconf bzip2-devel curl-devel libpng-devel libzip-devel libzip libxml2-devel openldap-devel gnutls-devel libicu-devel openssl-devel systemd-devel -y

cd ~
wget https://www.php.net/distributions/php-7.3.14.tar.gz
tar -zxvf php-7.3.14.tar.gz
cd php-7.3.14
./buildconf --force
./configure --prefix=/opt/SP/php-7.3.14 \
--enable-fpm \
--with-fpm-systemd \
--enable-zip \
--with-libzip \
--with-zlib \
--with-bz2 \
--with-curl \
--with-gd \
--with-openssl \
--with-ldap \
--with-libdir=lib64 \
--enable-mbstring \
--with-pcre-regex \
--quiet
make clean && make && make install

ln -s /opt/SP/php-7.3.14 /opt/SP/php7

echo 'export PATH=$PATH:/opt/SP/php7/bin' >> ~/.bash_profile
echo 'export PATH=$PATH:/opt/SP/php7/bin' >> ~/.bash_profile
echo 'export PHP_HOME=/opt/SP/php7' >> ~/.bash_profile
echo 'export PHP_INI_SCAN_DIR=/opt/SP/php7/etc' >> ~/.bash_profile
cd ~
source .bash_profile

## ORACLE ###
cd /opt/SP/php-7.3.14/bin
./pecl channel-update pecl.php.net
printf "instantclient,/opt/SP/instantclient_12_1\n" | ./pecl install oci8-2.2.0
ln -s /opt/SP/instantclient_12_1/libclntsh.so.12.1 /opt/SP/instantclient_12_1/libclntsh.so
echo "extension=oci8.so" >> /opt/SP/php-7.3.14/etc/php.ini
##

rm -f /opt/SP/php-7.3.14/etc/php-fpm.conf.default
rm -f /opt/SP/php-7.3.14/etc/php-fpm.d/www.conf.default

mkdir /opt/SP/php-7.3.14/log
chown wwwrun:www /opt/SP/php-7.3.14/log
chmod +s /opt/SP/php-7.3.14/log

rm -f /opt/SP/php-7.3.14/etc/php.ini
cp ~/aws-ec2-install-scripts/config/php.ini /opt/SP/php-7.3.14/etc
chown root:root /opt/SP/php-7.3.14/etc/php.ini
chmod 644 /opt/SP/php-7.3.14/etc/php.ini
rm -f /opt/SP/php-7.3.14/etc/php-fpm.conf
cp ~/aws-ec2-install-scripts/config/php-fpm.conf /opt/SP/php-7.3.14/etc
chown root:root /opt/SP/php-7.3.14/etc/php-fpm.conf
chmod 644 /opt/SP/php-7.3.14/etc/php-fpm.conf
rm -f /opt/SP/php-7.3.14/etc/php-fpm.d/www.conf
cp ~/aws-ec2-install-scripts/config/www.conf /opt/SP/php-7.3.14/etc/php-fpm.d
chown root:root /opt/SP/php-7.3.14/etc/php-fpm.d/www.conf
chmod 644 /opt/SP/php-7.3.14/etc/php-fpm.d/www.conf

cp ~/aws-ec2-install-scripts/assets/services/php /etc/init.d
chown root:root /etc/init.d/php
chmod 611 /etc/init.d/php
chkconfig php on
service php start

netstat -antup | grep -i 9000

yum remove gcc gcc-c++ make python3-docutils bzip2-devel curl-devel libpng-devel libzip-devel libxml2-devel openldap-devel gnutls-devel libicu-devel openssl-devel systemd-devel zlib-devel -y

rm -f /root/cmake-3.13.3.tar.gz;
rm -f /root/php-7.3.14.tar.gz;
rm -f /root/re2c-1.1.1.tar.gz;
rm -f /root/libzip-1.5.1.tar.xz;

rm -f ~wwwadm/.bash_profile
cp ~/.bash_profile ~wwwadm/.bash_profile
chmod 644 ~wwwadm/.bash_profile
chown wwwadm:wwwadm ~wwwadm/.bash_profile
