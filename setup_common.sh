#!/bin/sh

#
# common settings
#

source ./openstackrc

# install icehouse and epel repo
sudo yum install http://repos.fedorapeople.org/repos/openstack/openstack-icehouse/rdo-release-icehouse-3.noarch.rpm
sudo yum install http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -y
sudo yum install openstack-utils -y

# install pip
sudo yum install python-devel libxml2-devel libxslt-devel -y
wget http://python-distribute.org/distribute_setup.py
sudo python distribute_setup.py
sudo easy_install pip
rm -f distribute*

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
