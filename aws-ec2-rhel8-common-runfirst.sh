#/usr/bin/bash

yum update -y
yum install git unzip wget -y

dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

mkdir -p /opt/SP/home

groupadd www
useradd -c "WWW Run User" -d /opt/SP/home/wwwrun -s /sbin/nologin wwwrun
usermod -a -G www wwwrun
useradd -c "WWW Admin User" -d /opt/SP/home/wwwadm -s /bin/bash wwwadm
usermod -a -G www wwwadm

mkdir -p /var/SP/httpd
chown wwwadm:www /var/SP
chmod +s /var/SP
ln -s /var/SP/httpd /var/httpd
