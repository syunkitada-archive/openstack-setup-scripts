#!/bin/sh

#
# common settings
#

source ./openstackrc

# install epel repo
sudo yum install http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -y
sudo yum install openstack-utils -y

# setup ntp
sudo yum install ntp -y
sudo service ntpd start
sudo chkconfig ntpd on

# install rabbitmq(AMQP service)
sudo yum install rabbitmq-server -y
sudo service rabbitmq-server start
sudo chkconfig rabbitmq-server on

# setup db
sudo yum install mysql mysql-server MySQL-python -y
sudo service mysqld start
sudo chkconfig mysqld on

# create databases
if [ "$OS_DBPASS" = '' ]; then
    password_option=''
else
    password_option=-p$OS_DBPASS
fi
mysql -u$OS_DBUSER $password_option -e '
CREATE DATABASE keystone;
CREATE DATABASE neutron;
CREATE DATABASE nova;
CREATE DATABASE cinder;
CREATE DATABASE horizon;
CREATE DATABASE glance;
'
