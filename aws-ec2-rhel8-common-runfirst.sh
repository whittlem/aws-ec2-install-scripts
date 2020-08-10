#!/usr/bin/bash

yum repolist all
yum-config-manager --enable codeready-builder-for-rhel-8-rhui-rpms

yum update -y
yum install vim git unzip wget -y

dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

mkdir -p /opt/SP/home

groupadd www
useradd -c "WWW Run User" -d /opt/SP/home/wwwrun -s /sbin/nologin -g www wwwrun
usermod -a -G www wwwrun
useradd -c "WWW Admin User" -d /opt/SP/home/wwwadm -s /bin/bash -g www wwwadm
usermod -a -G www wwwadm

mkdir /var/httpd
mkdir /var/SP
ln -s /var/httpd /var/SP/httpd
chown -R wwwadm:www /var/SP
chmod +s /var/SP
chmod g+s /var/SP

sed -i 's~PATH=$PATH:$HOME/bin~export PATH=$PATH:$HOME/bin~' ~/.bash_profile
sed -i '/^export PATH$/d' .bash_profile
perl -i -pe "chomp if eof" ~/.bash_profile
echo "" >> ~/.bash_profile

echo "umask 027" >> ~/.bash_profile
echo "export EDITOR=/usr/bin/vim" >> ~/.bash_profile
echo "" >> ~/.bash_profile

rm -f ~wwwadm/.bash_profile
cp ~/.bash_profile ~wwwadm/.bash_profile
chmod 644 ~wwwadm/.bash_profile
chown wwwadm:wwwadm ~wwwadm/.bash_profile

rm -f ~/.vimrc
cp ~/aws-ec2-install-scripts/assets/profile/.vimrc ~
chmod 644 ~/.vimrc
chown root:root ~/.vimrc

rm -f ~wwwadm/.vimrc
cp ~/.vimrc ~wwwadm/.vimrc
chmod 644 ~wwwadm/.vimrc
chown wwwadm:wwwadm ~wwwadm/.vimrc

rm -f ~/.screenrc
cp ~/aws-ec2-install-scripts/assets/profile/.screenrc ~
chmod 644 ~/.screenrc
chown root:root ~/.screenrc

rm -f ~wwwadm/.screenrc
cp ~/.screenrc ~wwwadm/.screenrc
chmod 644 ~wwwadm/.screenrc
chown wwwadm:wwwadm ~wwwadm/.screenrc
