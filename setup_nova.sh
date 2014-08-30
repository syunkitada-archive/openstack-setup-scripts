sudo yum install openstack-nova-api openstack-nova-cert openstack-nova-conductor \
    openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler \
    python-novaclient -y


sudo openstack-config --set /etc/nova/nova.conf \
    database connection mysql://$OS_DBUSER:$OS_DBPASS@$OS_DBHOST/nova
nova-manage db sync


sudo openstack-config --set /etc/nova/nova.conf \
    DEFAULT my_ip 192.168.254.134
sudo openstack-config --set /etc/nova/nova.conf \
    DEFAULT vncserver_listen 192.168.254.134
sudo openstack-config --set /etc/nova/nova.conf \
    DEFAULT vncserver_proxyclient_address 192.168.254.134

sudo openstack-config --set /etc/nova/nova.conf \
    DEFAULT auth_strategy keystone
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken auth_uri http://$OS_CTL_HOST:5000
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken auth_host $OS_CTL_HOST
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken auth_protocol http
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken auth_port 35357
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken admin_user nova
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken admin_tenant_name service
sudo openstack-config --set /etc/nova/nova.conf \
    keystone_authtoken admin_password novapass


keystone user-create --name=nova --pass=novapass --email=$OS_ADMIN_EMAIL
keystone user-role-add --user=nova --tenant=service --role=admin
keystone service-create --name=nova --type=compute \
    --description="Openstack Compute"
keystone endpoint-create \
    --service-id=$(keystone service-list | awk '/ compute / {print $2}') \
    --publicurl=http://$OS_CTL_HOST:8774/v2/%\(tenant_id\)s \
    --internalurl=http://$OS_CTL_HOST:8774/v2/%\(tenant_id\)s \
    --adminurl=http://$OS_CTL_HOST:8774/v2/%\(tenant_id\)s


sudo service openstack-nova-api start
sudo service openstack-nova-cert start
sudo service openstack-nova-consoleauth start
sudo service openstack-nova-scheduler start
sudo service openstack-nova-conductor start
sudo service openstack-nova-novncproxy start
sudo chkconfig openstack-nova-api on
sudo chkconfig openstack-nova-cert on
sudo chkconfig openstack-nova-consoleauth on
sudo chkconfig openstack-nova-scheduler on
sudo chkconfig openstack-nova-conductor on
sudo chkconfig openstack-nova-novncproxy on



