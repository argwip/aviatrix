#!/bin/bash

apt-get update
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get -y install mysql-server
wget "https://raw.githubusercontent.com/fkhademi/webapp-demo/main/sql/create_db_table.sql"
mysql -u root -proot < create_db_table.sql
sed -i "s/127.0.0.1/*/g" /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart