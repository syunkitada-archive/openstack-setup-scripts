#!/bin/sh -x

source ./openstackrc

sudo yum install openstack-keystone -y

# setup db
# sqlalchemyのバージョンを上げる
# from sqlalchemy import exceptions as sa_exceptions
#ImportError: cannot import name exceptions
sudo pip install sqlalchemy --upgrade
sudo pip install sqlalchemy-migrate --upgrade
sudo openstack-config --set /etc/keystone/keystone.conf \
    database connection mysql://$OS_DBUSER:$OS_DBPASS@$OS_DBHOST/keystone
sudo keystone-manage db_sync

sudo openstack-config --set /etc/keystone/keystone.conf \
    DEFAULT admin_token $OS_SERVICE_TOKEN

sudo openstack-config --set /etc/keystone/keystone.conf \
    token provider keystone.token.providers.uuid.Provider

sudo service openstack-keystone start
sudo chkconfig openstack-keystone on


# create admin user
keystone role-create --name=admin
keystone user-create --name=admin --pass=$OS_ADMIN_PASS --email=$OS_ADMIN_EMAIL
keystone tenant-create --name=admin --description="Admin Tenant"
keystone user-role-add --user=admin --tenant=admin --role=admin
keystone user-role-add --user=admin --tenant=admin --role=_member_


# difine services and api endpoints
keystone service-create --name=keystone --type=identity \
    --description="OpenStack Identity"
keystone endpoint-create \
    --service-id=$(keystone service-list | awk '/ identity / {print $2}') \
    --publicurl=http://${OS_CTL_HOST}:5000/v2.0 \
    --internalurl=http://${OS_CTL_HOST}:5000/v2.0 \
    --adminurl=http://${OS_CTL_HOST}:35357/v2.0

keystone tenant-create --name=service
