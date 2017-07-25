#!/bin/bash

# $1 = URL without www
# $2 = path to ssl certs

echo "127.0.0.1 $1" >> /etc/hosts

touch /etc/apache2/sites-available/$1.conf

mkdir /var/log/apache2/$1
mkdir /var/www/html/$1

contents='<VirtualHost *:80>
ServerName '$1'
Redirect permanent / https://'$1'/
</VirtualHost>
<IfModule mod_ssl.c>
<VirtualHost *:443>
ServerName '$1'
ServerAdmin webmaster@localhost
DocumentRoot /var/www/html/'$1'
ErrorLog ${APACHE_LOG_DIR}/'$1'/error.log
CustomLog ${APACHE_LOG_DIR}/'$1'/access.log combined
SSLEngine on
SSLCertificateFile    '$2'/cert.pem
SSLCertificateKeyFile '$2'/privkey.pem
SSLCertificateChainFile '$2'/fullchain.pem
<FilesMatch "\.(cgi|shtml|phtml|php)$">
SSLOptions +StdEnvVars
</FilesMatch>
BrowserMatch "MSIE [2-6]" \
nokeepalive ssl-unclean-shutdown \
downgrade-1.0 force-response-1.0
BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
</VirtualHost>
</IfModule>'

echo "$contents" >> /etc/apache2/sites-available/$1.conf

certbot --apache certonly

chown www-data:www-data /var/www/html/$3 -R

a2ensite $1.conf

service apache2 restart
