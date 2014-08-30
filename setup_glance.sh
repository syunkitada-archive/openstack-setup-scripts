#!/bin/sh -x

# glance-api
# Accepts Image API calls for image discovery, retrieval, and storage.

# glance-registry
# Stores, processes, and retrieves metadata about images.
# Metadata invludes items such as size and type.

# Database. Stores image metadata.

source ./openstackrc
source ./clientrc

sudo yum install openstack-glance -y

sudo openstack-config --set /etc/glance/glance-api.conf \
    database connection mysql://$OS_DBUSER:$OS_DBPASS@$OS_DBHOST/glance
sudo openstack-config --set /etc/glance/glance-registry.conf \
    database connection mysql://$OS_DBUSER:$OS_DBPASS@$OS_DBHOST/glance
sudo glance-manage db_sync


sudo openstack-config --set /etc/glance/glance-api.conf \
    DEFAULT notification_driver rabbit
sudo openstack-config --set /etc/glance/glance-api.conf \
    DEFAULT notification_driver rabbit

sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken auth_uri http://$OS_CTL_HOST:5000
sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken auth_host $OS_CTL_HOST
sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken auto_port 35357
sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken auth_protocol http
sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken admin_tenant_name service
sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken admin_user glance
sudo openstack-config --set /etc/glance/glance-api.conf \
    keystone_authtoken admin_password glancepass
sudo openstack-config --set /etc/glance/glance-api.conf \
    paste_deploy flavor keystone

sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken auth_uri http://$OS_CTL_HOST:5000
sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken auth_host $OS_CTL_HOST
sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken auto_port 35357
sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken auth_protocol http
sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken admin_tenant_name service
sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken admin_user glance
sudo openstack-config --set /etc/glance/glance-registry.conf \
    keystone_authtoken admin_password glancepass
sudo openstack-config --set /etc/glance/glance-registry.conf \
    paste_deploy flavor keystone


keystone user-create --name=glance --pass=glancepass --email=${OS_ADMIN_EMAIL}
keystone user-role-add --user=glance --tenant=service --role=admin
keystone service-create --name=glance --type=image \
    --description="OpenStack Image Service"
keystone endpoint-create \
    --service-id=$(keystone service-list | awk '/ image / {print $2}') \
    --publicurl=http://${OS_CTL_HOST}:9292 \
    --internalurl=http://${OS_CTL_HOST}:9292 \
    --adminurl=http://${OS_CTL_HOST}:9292 \

sudo service openstack-glance-api restart
sudo service openstack-glance-registry restart
sudo chkconfig openstack-glance-api on
sudo chkconfig openstack-glance-registry on


sudo chown glance:glance /var/lib/glance/images/

