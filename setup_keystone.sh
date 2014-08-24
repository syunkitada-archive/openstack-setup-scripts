#!/bin/sh

source ./openstackrc

sudo yum install openstack-keystone -y

sudo openstack-config --set /etc/keystone/keystone.conf \
   database connection mysql://$OS_DBUSER:$OS_DBPASS@$OS_DBHOST

sudo pip install 'sqlalchemy <= 0.7.10'
