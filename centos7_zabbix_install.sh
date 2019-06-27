#!/bin/bash
# Date:2017-03-30
# Author:Pboy Tom:)
# QQ:360254363/pboy@sina.cn
# E-mail:cylcjy009@gmail.com
# Website:www.pboy8.top pboy8.taobao.com
# Desc:Install zabbix 3.0.x on linux Centos6 and 7, IN redhat7 ,you should use centos7's yum repo..
# Debug: Fix some mistakes;--2017-10-19
# Project home: https://github.com/tompboy
# Version:V 0.1

#You should put the lnamp install script in the directory same with this script.
[ -e lnamp_install.sh ] && {
	chmod +x lnamp_install.sh
	. ./lnamp_install.sh
	} || {
	echo "There is not exist lnamp_install script here, please copy it here..."
	}

source /etc/profile

useradd -c "Zabbix Monitoring" zabbix

yum -y install iksemel iksemel-devel perl-DBI postfix libidn-devel rpm-devel OpenIPMI-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn openldap-devel nss_ldap openldap-clients openldap-servers net-snmp* OpenIPMI java-devel gnutls-devel libevent-devel


cd /data
wget -O zabbix-3.0.8.tar.gz -c http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.0.8/zabbix-3.0.8.tar.gz/download
[ -e zabbix-3.0.8.tar.gz ] && {
tar zxvf zabbix-3.0.8.tar.gz
cd zabbix-3.0.8/database/mysql/
cat schema.sql |mysql -u$Mysql_USER -p$Myuser_PSWD -h 127.0.0.1 $Mysql_DBname &&\
cat images.sql |mysql -u$Mysql_USER -p$Myuser_PSWD -h 127.0.0.1 $Mysql_DBname &&\
cat data.sql |mysql -u$Mysql_USER -p$Myuser_PSWD -h 127.0.0.1 $Mysql_DBname
cd /data/zabbix-3.0.8
./configure --prefix=/usr/local/zabbix --enable-server --with-mysql=/usr/local/mysql/bin/mysql_config --with-net-snmp --with-jabber --with-libcurl --with-openipmi --enable-proxy --enable-agent --enable-java --with-libxml2
make && make install
[ $? -eq 0 ] && {
	cp misc/init.d/tru64/zabbix_* /etc/init.d/
	cp -r frontends/php /zabbix
	chmod 755 /etc/init.d/zabbix_*
	chown -R zabbix:zabbix /usr/local/zabbix
	sed -i '/#!\/bin\/sh/a# chkconfig: 2345 10 90' /etc/init.d/zabbix*
	chkconfig --add zabbix_server
	chkconfig --add zabbix_agentd
	chkconfig --level 35 zabbix_server on
	chkconfig --level 35 zabbix_agentd on
	echo "date.timezone = Asia/Shanghai">>/usr/local/php/lib/php.ini
	sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /usr/local/php/lib/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/lib/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 300/g' /usr/local/php/lib/php.ini
	sed -i 's/\/home\/www/\/zabbix/g' /usr/local/apache/conf/httpd.conf
	apachectl -t && apachectl -k stop && apachectl -k start
	sed -i 's/\/usr\/local\/sbin\/zabbix_agentd/\/usr\/local\/zabbix\/sbin\/zabbix_agentd/g' /etc/init.d/zabbix_agentd
	sed -i 's/\/usr\/local\/sbin\/zabbix_server/\/usr\/local\/zabbix\/sbin\/zabbix_server/g' /etc/init.d/zabbix_server
	echo "zabbix installed success.."
	echo "You may edit ${GREEN_COLOR}'/usr/local/zabbix/etc/zabbix_server.conf'$RES and ${GREEN_COLOR}'/usr/local/zabbix/etc/zabbix_agentd.conf'$RES manually.."
	echo "Please visit http://{your server'IP} to install zabbix..."
	} || {
	echo "zabbix installed failed.."
 	}
} || {
	echo "zabbix download failed.."
	}