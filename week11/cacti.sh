#!/bin/bash

# Update and Upgrade Ubuntu System
sudo apt update && sudo apt upgrade -y

# Install LAMP Stack
sudo apt install apache2 mariadb-server php php-mysql libapache2-mod-php php-xml php-ldap php-mbstring php-gd php-gmp -y

# Secure MariaDB Installation
echo "Running secure MariaDB installation..."
sudo mysql_secure_installation

# Install SNMP and RRDTool
sudo apt install snmp php-snmp rrdtool librrds-perl -y

# Create Cacti Database and User
echo "Creating Cacti database and user..."
sudo mysql -u root -p<<MYSQL_SCRIPT
CREATE DATABASE cacti;
CREATE USER 'cactiuser'@'localhost' IDENTIFIED BY 'YOUR_CACTI_USER_PASSWORD';
GRANT ALL PRIVILEGES ON cacti.* TO 'cactiuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Install Cacti
echo "Installing Cacti..."
sudo apt install cacti cacti-spine -y

# Automated steps for dbconfig-common
# Note: This might require manual interaction depending on your system setup

# Schedule Cacti Poller (run as www-data user)
echo "Scheduling Cacti poller..."
(crontab -u www-data -l; echo "*/5 * * * * php /usr/share/cacti/site/poller.php > /dev/null 2>&1") | crontab -u www-data -

echo "Cacti installation script has completed."
echo "Please access the Cacti web interface to finish the installation process."

