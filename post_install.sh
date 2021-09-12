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

#install ampache
cd /usr/local/www
git clone -b release5 https://github.com/ampache/ampache.git ampache

# Configure apache and php
rm -rf /usr/local/www/apache24/data
ln -s /usr/local/www/ampache/public /usr/local/www/apache24/data

cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini

sed -i '' 's/.*LoadModule rewrite_module libexec.*\/apache24\/mod_rewrite.so/LoadModule rewrite_module libexec\/apache24\/mod_rewrite.so/' /usr/local/etc/apache24/httpd.conf
sed -i '' 's/.*DirectoryIndex index.html.*/DirectoryIndex index.html index.php/' /usr/local/etc/apache24/httpd.conf

echo '<FilesMatch "\.php$">'  >> /usr/local/etc/apache24/httpd.conf
echo '    SetHandler application/x-httpd-php'  >> /usr/local/etc/apache24/httpd.conf
echo '</FilesMatch>'  >> /usr/local/etc/apache24/httpd.conf
echo '<FilesMatch "\.phps$">'  >> /usr/local/etc/apache24/httpd.conf
echo '    SetHandler application/x-httpd-php-source'  >> /usr/local/etc/apache24/httpd.conf
echo '</FilesMatch>' >> /usr/local/etc/apache24/httpd.conf

# Configure database
# Note - Ampache's web-based post-intall will set this up

# Final restart of all services
echo "Restarting apache ..."
/usr/local/etc/rc.d/apache24 restart
echo "Restarting mysql ..."
/usr/local/etc/rc.d/mysql-server restart
echo "Restarting php ..."
/usr/local/etc/rc.d/php-fpm restart
