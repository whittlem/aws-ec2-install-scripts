#!/usr/bin/bash

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
