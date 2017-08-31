#!/bin/bash
# Date:2017-08-11
# Author:Pboy Tom:)
# QQ:360254363/pboy@sina.cn
# E-mail:cylcjy009@gmail.com
# Website:www.pboy8.top pboy8.taobao.com
# Desc:unInstall nginx-1.10, php-5.2, gd2, freetype2, mysql-5.5 on linux Centos6, for ruiqi soft..
# Project home: https://github.com/tompboy/LNAMP
# Version:V 0.01


/usr/local/nginx/sbin/nginx -s stop
/usr/local/apache/bin/apachectl -k stop
service php-fpm stop
service vsftpd stop
/usr/local/nginx_php/sbin/php-fpm stop
/usr/local/mysql/support-files/mysql.server stop
userdel -r mysql
userdel -r www
rm -rf /usr/local/mysql*
rm -rf /usr/local/php*
rm -rf /usr/local/nginx*
rm -rf /usr/local/apache*
rm -rf /data/*.lock
