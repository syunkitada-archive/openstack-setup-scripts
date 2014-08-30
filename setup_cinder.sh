#!/bin/bash -x

# cinder-api
# Accepts API requests and routes them to cinder-volume for action.

# cinder-volume
# Responds to requests to read from and write to the Block Storage database to maintain state.
# interacting with other processes (like cinder-scheduler) through a message queue and directly upon block storage providing hardware or software. It can interact with a variety of storage providers through a driver architecture.

# cinder-scheduler (daemon)
# Like the nova-scheduler, picks the optimal block storage provider node no which to create the volume.

# Messaging queue: Routes information between the Block Storage service processes.

source ./openstackrc
source ./clientrc

sudo yum install openstack-cinder -y

sudo openstack-config --set /etc/cinder/cinder.conf \
    database connection mysql://$OS_DBUSER:$OS_DBPASS@$OS_DBHOST/cinder

cinder-manage db sync


sudo openstack-config --set /etc/cinder/cinder.conf \
    DEFAULT auth_strategy keystone
sudo openstack-config --set /etc/cinder/cinder.conf\
    keystone_authtoken auth_host $OS_CTL
sudo openstack-config --set /etc/cinder/cinder.conf \
    keystone_authtoken auth_protocol http
sudo openstack-config --set /etc/cinder/cinder.conf \
    keystone_authtoken auth_port 35357
sudo openstack-config --set /etc/cinder/cinder.conf \
    admin_user cinder
sudo openstack-config --set /etc/cinder/cinder.conf \
    admin_tenant_name service
sudo openstack-config --set /etc/cinder/cinder.conf \
    admin_password cinderpass


keystone user-create --name=cinder --pass=cinderpass \
    --email=$OS_ADMIN_EMAIL
keystone user-role-add --user=cinder --tenant=service --role=admin

keystone service-create --name=cinder --type=volume --description="OpenStack Block Storage"
keystone endpoint-create \
    --service-id=$(keystone service-list | awk '/ volume / {print $2}') \
    --publicurl=http://$OS_CTL_HOST:8776/v1/%\(tenant_id\)s \
    --internalurl=http://$OS_CTL_HOST:8776/v1/%\(tenant_id\)s \
    --adminurl=http://$OS_CTL_HOST:8776/v1/%\(tenant_id\)s

keystone service-create --name=cinderv2 --type=volumev2 --description="OpenStack Block Storage v2"
keystone endpoint-create \
    --service-id=$(keystone service-list | awk '/ volumev2 / {print $2}') \
    --publicurl=http://$OS_CTL_HOST:8776/v2/%\(tenant_id\)s \
    --internalurl=http://$OS_CTL_HOST:8776/v2/%\(tenant_id\)s \
    --adminurl=http://$OS_CTL_HOST:8776/v2/%\(tenant_id\)s


sudo service openstack-cinder-api start
sudo service openstack-cinder-scheduler start
sudo chkconfig openstack-cinder-api on
sudo chkconfig openstack-cinder-scheduler on
