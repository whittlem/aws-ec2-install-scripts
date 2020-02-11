#/bin/bash

#yum install git unzip libnsl libaio apr apr-devel apr-util apr-util-devel pcre-devel.x86_64 zlib-devel libtool libxslt libxslt-devel sqlite-devel systemd-devel libstdc++.so.6 gcc-c++ libxml2-devel bzip2-devel curl-devel openldap-devel gnutls-devel libicu-devel python3-docutils libpng-devel libzip-devel libzip -y

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
cd ..
