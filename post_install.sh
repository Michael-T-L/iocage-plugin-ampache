#!/bin/sh

# Enable the services
sysrc -f /etc/rc.conf apache24_enable="YES"
sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf php_fpm_enable="YES"

# Start the services
service apache24 start 2>/dev/null
service mysql-server start 2>/dev/null
service php-fpm start 2>/dev/null

# configure IP
# If on NAT, we need to use the HOST address as the IP
if [ -e "/etc/iocage-env" ] ; then
	IOCAGE_PLUGIN_IP=$(cat /etc/iocage-env | grep HOST_ADDRESS= | cut -d '=' -f 2)
	echo "Using NAT Address: $IOCAGE_PLUGIN_IP"
fi

# Configure ampache

# Configure database
# Note - Ampache's web-based post-intall will set this up

# Final restart of all services
echo "Restarting apache ..."
/usr/local/etc/rc.d/apache24 restart
echo "Restarting mysql ..."
/usr/local/etc/rc.d/mysql-server restart
echo "Restarting php ..."
/usr/local/etc/rc.d/php-fpm restart