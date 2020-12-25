#!/bin/bash

BRANCH=$1

# Create temporary password
PASS_OLD=`cat /var/log/mysqld.log | grep "temporary password" | tail -c13`
PASS_NEW=root
mysql -u root -p${PASS_OLD} -e "SET GLOBAL validate_password_length=4;" --connect-expired-password
mysql -u root -p${PASS_OLD} -e "SET GLOBAL validate_password_policy=LOW;" --connect-expired-password
mysql -u root -p${PASS_OLD} -e "SET password for root@localhost=password('root');" --connect-expired-password
mysql -u root -p${PASS_NEW} -e "CREATE DATABASE scouter_test DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"

mkdir -p /var/www/
cd /var/www
git clone -b ${BRANCH} https://github.com/kujira28/scouter-github-laravel.git
cd scouter-github-laravel
chmod 777 -R ./storage
chmod 777 -R ./bootstrap/cache
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed
