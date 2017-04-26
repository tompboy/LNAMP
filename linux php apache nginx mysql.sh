#!/bin/bash
# Date:2017-03-09
# Author:Pboy Tom:)
# QQ:360254363/pboy@sina.cn
# E-mail:cylcjy009@gmail.com
# Website:www.pboy8.top pboy8.taobao.com
# Desc:Install nginx-1.10, php-5.2, gd2, freetype2, mysql-5.5 on linux Centos6, for ruiqi soft..
# Add: php5.3, Apache2 ...and on Centos7..2017-03-17
# Add: php5.4, mysql 5.6...2017-03-22
# Add: php7, mysql 5.7...2017-03-23
# Debug: Fix some mistakes..2017-03-27
# Add: support on Ubuntu 16...2017-03-28
# Debug: Fix some mistakes..2017-04-05
# Debug: Fix some mistakes..2017-04-22
# Debug: Fix some mistakes..2017-04-26
# Project home: https://github.com/tompboy/LNAMP
# Version:V 0.10


[ `id -u` != 0 ] && { echo "Error: You must run this script $0 with root..."; exit 9; }

##预定义变量-Predefined variables
#时间-date-time
DATE_INST=`date +%Y-%m-%d-%H-%M`

#安装日志文件-Instlal log
INSTALL_LOG=/tmp/install_log$DATE_INST

#green color
GREEN_COLOR='\E[1;32m'
RES='\E[0m'

#源码安装包下载目录-Source packages download dir
INSTALL_PATH=/data
mkdir -p $INSTALL_PATH

#内核大版本-kernel version
RL=`uname -r|awk -F "." '{print $1}'`

#网站用户-user who run the web server
USER_WEB=www

#用户密码-the password for the user
USER_PSWD=`echo $(date +%t%N)$RANDOM|md5sum|cut -c 2-11`
echo -e "The user's password. is: $USER_PSWD">>$INSTALL_LOG

#Mysql root 密码-the password for mysql root
Mysql_PSWD=`echo $(date +%t%N)$RANDOM|md5sum|cut -c 2-11`
echo -e "The Mysql root's password. is: $Mysql_PSWD">>$INSTALL_LOG

#新建Mysql数据库名-the database name
Mysql_DBname=wwwdb

#Mysql普通用户名-normal user for mysql
Mysql_USER=wwwdbuser

#Mysql普通用户随机10位数密码-password for normal user, random 10 chars
Myuser_PSWD=`echo $(date +%t%N)$RANDOM|md5sum|cut -c 2-11`
echo -e "The Mysql user's password. is: $Myuser_PSWD">>$INSTALL_LOG


clear
echo "###################################################################"
echo -e "########### ${GREEN_COLOR}This script will install Mysql,Apache,Nginx$RES ###########"
echo -e "###########  ${GREEN_COLOR}Php, zend, Ftp..Thank you for use... $RES      ###########"
echo "###################################################################"
echo -e "\n"
echo -e "\n"

#Mysql server
while :; do
menu(){
cat <<EOF
#################################
#######  Mysql  #################
#################################
1. Install Mysql 5.5
2. Install Mysql 5.6
3. Install Mysql 5.7
EOF
}
menu
read -p "Please input which web server you want to install.." Mysql_INST
echo -e "\n"
if [[ $Mysql_INST != [1-3] ]]; then
	echo "Input error, please input the correct num[1-3].."
else
	break
fi
done

#Menu Web server
while :; do
menu(){
cat <<EOF
######################################
#######  WEB server ##################
######################################
1. Install Apache 2.2
2. Install Apache 2.4
3. Install Nginx
EOF
}
menu
read -p "Please input which web server you want to install.." WEB_INST
echo -e "\n"
if [[ $WEB_INST != [1-3] ]]; then
	echo "Input error, please input the correct num[1-3].."
else
	break
fi
done

#Menu PHP
while :; do
menu(){
cat <<EOF
############################################
########  PHP  #############################
############################################
1. Install PHP 5.2.17
2. Install PHP 5.3.29
3. Install PHP 5.4.45
4. Install PHP 5.5.38
5. Install PHP 5.6.30
6. Install PHP 7.0.17
7. Install PHP 7.1.3
EOF
}
menu
read -p "Please input which PHP you want to install.." PHP_INST
echo -e "\n"
if [[ $PHP_INST != [1-7] ]]; then
	echo "Input error, please input the correct num[1-7].."
else
	break
fi
done

CHK_SYS(){
cd $INSTALL_PATH
[ ! -e CHK_SYS.lock ] && {
##检查系统-check system
echo "系统信息收集中/gathering system info...">>$INSTALL_LOG
echo "gathering system info..."

echo "文件系统/file-systems">>$INSTALL_LOG
df -h >>$INSTALL_LOG
echo "#######END1">>$INSTALL_LOG

echo "CPU信息/CPU info">>$INSTALL_LOG
cat /proc/cpuinfo >>$INSTALL_LOG
echo "#######END2">>$INSTALL_LOG

echo "内存信息/MEM info">>$INSTALL_LOG
free -m >>$INSTALL_LOG
echo "#######END3">>$INSTALL_LOG

echo "内核版本/kernel info.">>$INSTALL_LOG
lsb_release -a >>$INSTALL_LOG
uname -a >>$INSTALL_LOG
echo "#######END4">>$INSTALL_LOG

echo "文件读写/disk read write info">>$INSTALL_LOG
time dd if=/dev/zero of=/tmp/1.gz count=100 bs=10M >> $INSTALL_LOG 2>&1
rm -f /tmp/1.gz
echo "#######END5">>$INSTALL_LOG

##系统参数优化-optimize the system
cat >>/etc/sysctl.conf<<EOF
# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 30
# Turn off the tcp_window_scaling
net.ipv4.tcp_window_scaling = 0
# Turn off the tcp_sack
net.ipv4.tcp_sack = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
EOF
sysctl -p




[ $RL = 2 ] && echo "*       hard    nproc  65535" >>/etc/security/limits.d/90-nproc.conf && sed -i 's/1024/65535/g' /etc/security/limits.d/90-nproc.conf

[ $RL = 3 ] && echo "*       hard    nproc  65535" >> /etc/security/limits.d/20-nproc.conf && sed -i 's/4096/65535/g' /etc/security/limits.d/20-nproc.conf

cat >>/etc/security/limits.conf<<EOF
*       soft    nofile  65535
*       hard    nofile  65535
*       soft    nproc  65535
*       hard    nproc  65535
EOF

[ $? -eq 0 ] && {
	echo "Optimize system successful">>$INSTALL_LOG
	touch $INSTALL_PATH/CHK_SYS.lock
	}|| {
	echo "Optimize system failed.">>$INSTALL_LOG
	exit 66
		}
	}
}

FTP_INST(){
cd $INSTALL_PATH
[ ! -e FTP_INST.lock ] && {
##Install FTP，建立用户，并设置密码
if [ $RL = 2 -o $RL = 3 ]; then
	yum install -y vsftpd
	[ $? -eq 0 ] && {
	sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd/vsftpd.conf
	sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/g' /etc/vsftpd/vsftpd.conf
	}
else
	apt-get -y install vsftpd
	sed -i 's/#write_enable=YES/write_enable=YES/g' /etc/vsftpd.conf
	sed -i 's/#local_umask=022/local_umask=022/g' /etc/vsftpd.conf
	sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/g' /etc/vsftpd.conf
fi
	service vsftpd start
[ `netstat -anp|grep vsftpd|wc -l` -gt 0 ] && echo "Vsftpd installed success.">>$INSTALL_LOG || { 
	echo "Vsftpd installed failed.">>$INSTALL_LOG
	exit 2
	}

useradd -s /sbin/nologin $USER_WEB && echo "$USER_WEB:$USER_PSWD"|chpasswd
[ $? -eq 0 ] && {
	echo "user $USER_WEB created success">>$INSTALL_LOG
	touch $INSTALL_PATH/FTP_INST.lock
	} || {
	echo "user $USER_WEB created failed">>$INSTALL_LOG
	exit 96
		}
}
}


DOWN_SOFT(){
cd $INSTALL_PATH
#安装依赖包\下载安装源码包-download the source packages and depended packages
#epel
[ ! -e DOWN_SOFT.lock ] && {
if [ $RL = 2 -o $RL = 3 ]; then
	[ $RL = 2 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	[ $RL = 3 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
	rpm -qa|grep epel-release
	[ $? -eq 0 ] && yum -y install kernel-devel rpm-build patch make gcc gcc-c++ flex bison \
	file libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel libtool libpng \
	libpng-devel wget libaio* vim libmcrypt libmcrypt-devel mcrypt mhash openssl openssl-devel libtool-ltdl-devel  freetype freetype-devel gd-devel|| exit 39
else
	[ $RL = 4 ] && {
	apt-get update &&\
	apt-get -y install automake patch make gcc flex bison file libxml2 libxml2-dev libjpeg-dev libpng-dev curl libtool wget libaio-dev vim mcrypt openssl libssl-dev zlib1g zlib1g-dev libfreetype6 libfreetype6-dev libjpeg-dev libcurl4-gnutls-dev libmcrypt-dev libtool-bin &&\
	ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib
}
fi
echo "Downloading packages..">>$INSTALL_LOG
wget -c http://nginx.org/download/nginx-1.10.2.tar.gz &&\
wget -c https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.bz2 &&\
wget -c http://zlib.net/fossils/zlib-1.2.11.tar.gz &&\
wget -c https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt && mv txtbgxGXAvz4N.txt php-5.x.x.patch
[ $? -eq 0 ] && {
	echo "download packages success.">>$INSTALL_LOG
	touch $INSTALL_PATH/DOWN_SOFT.lock
	} || {
	echo "download packages failed."
	echo "download packages failed.">>$INSTALL_LOG
	exit 99
		}
	}
}

Mysql55_INST(){
##Install MySQL 5.5 ################
cd $INSTALL_PATH
wget -c http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.53-linux2.6-x86_64.tar.gz
[ -f mysql-5.5.53-linux2.6-x86_64.tar.gz ] && [ ! -e Mysql55_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-5.5.53-linux2.6-x86_64.tar.gz
	cp -r mysql-5.5.53-linux2.6-x86_64 /usr/local/mysql
	cd /usr/local/mysql
	rm -f /etc/my.cnf
	cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf
	cat >>/etc/my.cnf<<EOF
	max_connections = 500
	wait_timeout = 30
EOF
	scripts/mysql_install_db --user=mysql
	/usr/local/mysql/support-files/mysql.server start
[ $? -eq 0 ] && {
	#创建root用户密码
	/usr/local/mysql/bin/mysqladmin -u root password $Mysql_PSWD
	#创建数据库
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "create database $Mysql_DBname default charset utf8;"
	#赋普通用户权
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "grant all on $Mysql_DBname.* to $Mysql_USER@'127.0.0.1' identified by '$Myuser_PSWD';"
	#刷新权限
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "flush privileges;"
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	service mysqld stop
	touch $INSTALL_PATH/Mysql55_INST.lock
	echo "Mysql installed successful.">>$INSTALL_LOG
	} || {
		echo "Mysql installed failed.">>$INSTALL_LOG
		exit 5
		}
	}
}

Mysql56_INST(){
##Install MySQL 5.6 ################
cd $INSTALL_PATH
wget -c https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
[ -f mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz ] && [ ! -e Mysql56_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
	cp -r mysql-5.6.35-linux-glibc2.5-x86_64 /usr/local/mysql
	cd /usr/local/mysql
	rm -f /etc/my.cnf
cat >>/etc/my.cnf<<EOF
[mysqld]
datadir = /usr/local/mysql/data
basedir = /usr/local/mysql
port = 3306
server_id = 1
max_connections = 500
wait_timeout = 30
EOF
	scripts/mysql_install_db --user=mysql
	/usr/local/mysql/support-files/mysql.server start
[ $? -eq 0 ] && {
	#创建root用户密码
	/usr/local/mysql/bin/mysqladmin -u root password $Mysql_PSWD
	#创建数据库
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "create database $Mysql_DBname default charset utf8;"
	#赋普通用户权
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "grant all on $Mysql_DBname.* to $Mysql_USER@'127.0.0.1' identified by '$Myuser_PSWD';"
	#刷新权限
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "flush privileges;"
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	service mysqld stop
	touch $INSTALL_PATH/Mysql56_INST.lock
	echo "Mysql installed successful.">>$INSTALL_LOG
	} || {
		echo "Mysql installed failed.">>$INSTALL_LOG
		exit 5
		}
	}
}

Mysql57_INST(){
##Install MySQL 5.7 ################
cd $INSTALL_PATH
wget -c https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
[ -f mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz ] && [ ! -e Mysql57_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
	cp -r mysql-5.7.17-linux-glibc2.5-x86_64 /usr/local/mysql
	cd /usr/local/mysql
	rm -f /etc/my.cnf
cat >>/etc/my.cnf<<EOF
[mysqld]
datadir = /usr/local/mysql/data
basedir = /usr/local/mysql
port = 3306
server_id = 1
max_connections = 500
wait_timeout = 30
EOF
	bin/mysqld --initialize --user=mysql &>/tmp/mysqlinstall{$DATE_INST}.log
	/usr/local/mysql/support-files/mysql.server start
[ $? -eq 0 ] && {
	LPASD=`cat /tmp/mysqlinstall{$DATE_INST}.log|grep root@localhost|awk -F":" '{print $4}'|sed s/[[:space:]]//g`
	#重设root用户密码
	/usr/local/mysql/bin/mysql -u root -p$LPASD -e "alter user root password '$Mysql_PSWD';"
	#创建数据库
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "create database $Mysql_DBname default charset utf8;"
	#赋普通用户权
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "grant all on $Mysql_DBname.* to $Mysql_USER@'127.0.0.1' identified by '$Myuser_PSWD';"
	#刷新权限
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "flush privileges;"
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	service mysqld stop
	touch $INSTALL_PATH/Mysql57_INST.lock
	echo "Mysql installed successful.">>$INSTALL_LOG
	} || {
		echo "Mysql installed failed.">>$INSTALL_LOG
		exit 5
		}
	}
}

APA22_INST(){
##Install apache2.2 #####################
cd $INSTALL_PATH
wget -c http://archive.apache.org/dist/httpd/httpd-2.2.32.tar.bz2
[ -f httpd-2.2.32.tar.bz2 ] && [ ! -e APA22_INST.lock ] && {
tar -jxvf httpd-2.2.32.tar.bz2
cd httpd-2.2.32
./configure --prefix=/usr/local/apache --enable-module=so --enable-mods-shared='rewrite' --enable-deflate --enable-proxy-http --enable-proxy
make && make install

[ $? -eq 0 ] && {
#vi /usr/local/apache/conf/httpd.conf

sed -i 's/User daemon/User '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/Group daemon/Group '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g'/usr/local/apache/conf/httpd.conf
sed -i 's/ErrorLog "logs\/error_log"/ErrorLog "\|\/usr\/local\/apache\/bin\/rotatelogs \/usr\/local\/apache\/logs\/error_%Y_%m_%d.log 86400 480"/g' /usr/local/apache/conf/httpd.conf
sed -i 's/CustomLog "logs\/access_log" common/CustomLog "\|\/usr\/local\/apache\/bin\/rotatelogs \/usr\/local\/apache\/logs\/access_%Y_%m_%d.log 86400 480" combined/g' /usr/local/apache/conf/httpd.conf


cat >>/usr/local/apache/conf/httpd.conf<<EOF

AddType application/x-httpd-php .php     
AddType application/x-httpd-php-source .phps

NameVirtualHost *:80

<VirtualHost *:80>
DocumentRoot "/home/www"
ServerName www.www.net
<Directory /home/www>
DirectoryIndex index.php index.html
Order allow,deny
Allow from all
</Directory>
</VirtualHost>


ExtendedStatus On

<location /apstatus>
SetHandler server-status
Order Allow,Deny
Allow from all
</location>

<IfModule mpm_prefork_module>
    StartServers          5
    MinSpareServers       5
    MaxSpareServers      30
	ServerLimit          2000
    MaxClients          2000
    MaxRequestsPerChild   15000
</IfModule>

#压缩级别

DeflateCompressionLevel 9
SetOutputFilter DEFLATE
AddOutputFilterByType DEFLATE text/html text/plain text/xml application/x-javascript application/x-httpd-php
AddOutputFilter DEFLATE js css
EOF
touch $INSTALL_PATH/APA22_INST.lock
echo "Apache2.2 installed success...">>$INSTALL_LOG
} || {
	echo "Apache2.2 installed failed...">>$INSTALL_LOG
	exit 998
	}
}

/usr/local/apache/bin/apachectl -t && /usr/local/apache/bin/apachectl start

}

APA24_INST(){
##Install apache 2.4 #####################
cd $INSTALL_PATH
wget -c http://archive.apache.org/dist/httpd/httpd-2.4.25.tar.bz2 &&\
wget -c http://archive.apache.org/dist/apr/apr-1.5.2.tar.bz2 &&\
wget -c http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.bz2
[ -f apr-1.5.2.tar.bz2 ] && [ -f apr-util-1.5.4.tar.bz2 ] && [ -f httpd-2.4.25.tar.bz2 ] && [ ! -e APA24_INST.lock ] && {
tar jxvf apr-1.5.2.tar.bz2
cd apr-1.5.2
./configure --prefix=/usr/local/apr && make && make install
cd $INSTALL_PATH
tar jxvf apr-util-1.5.4.tar.bz2
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config && make && make install
cd $INSTALL_PATH
tar jxvf pcre-8.40.tar.bz2
cd pcre-8.40
./configure --prefix=/usr/local/pcre && make && make install

cd $INSTALL_PATH
tar -jxvf httpd-2.4.25.tar.bz2
cd httpd-2.4.25
./configure --prefix=/usr/local/apache --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-module=so --enable-mods-shared='rewrite' --enable-deflate --enable-proxy-http --enable-proxy --with-pcre=/usr/local/pcre
make && make install

[ $? -eq 0 ] && {
#vi /usr/local/apache/conf/httpd.conf

sed -i 's/User daemon/User '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/Group daemon/Group '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g'/usr/local/apache/conf/httpd.conf
sed -i 's/ErrorLog "logs\/error_log"/ErrorLog "\|\/usr\/local\/apache\/bin\/rotatelogs \/usr\/local\/apache\/logs\/error_%Y_%m_%d.log 86400 480"/g' /usr/local/apache/conf/httpd.conf
sed -i 's/CustomLog "logs\/access_log" common/CustomLog "\|\/usr\/local\/apache\/bin\/rotatelogs \/usr\/local\/apache\/logs\/access_%Y_%m_%d.log 86400 480" combined/g' /usr/local/apache/conf/httpd.conf


cat >>/usr/local/apache/conf/httpd.conf<<EOF

AddType application/x-httpd-php .php     
AddType application/x-httpd-php-source .phps

<VirtualHost *:80>
DocumentRoot "/home/www"
ServerName www.www.net
<Directory /home/www>
DirectoryIndex index.php index.html
AllowOverride All
Require all granted
</Directory>
</VirtualHost>


ExtendedStatus On

<location /apstatus>
SetHandler server-status
Require all granted
</location>

<IfModule mpm_event_module>
    StartServers             3
    MinSpareThreads         75
    MaxSpareThreads        250
	ThreadLimit				250
    ThreadsPerChild         250
    MaxRequestWorkers      500
    MaxConnectionsPerChild   8000
</IfModule>

LoadModule deflate_module modules/mod_deflate.so
LoadModule filter_module modules/mod_filter.so

DeflateCompressionLevel 9
SetOutputFilter DEFLATE
AddOutputFilterByType DEFLATE text/html text/plain text/xml application/x-javascript application/x-httpd-php
AddOutputFilter DEFLATE js css
EOF
touch $INSTALL_PATH/APA24_INST.lock
echo "Apache2.4 installed success...">>$INSTALL_LOG
} || {
	echo "Apache2.4 installed failed...">>$INSTALL_LOG
	exit 998
	}
}

/usr/local/apache/bin/apachectl -t && /usr/local/apache/bin/apachectl start

}

NGX_INST(){
##Install nginx################
cd $INSTALL_PATH
[ -f pcre-8.40.tar.bz2 ] && [ -f zlib-1.2.11.tar.gz ] && [ -f nginx-1.10.2.tar.gz ] && [ ! -e NGX_INST.lock ] && {
	tar jxvf pcre-8.40.tar.bz2
	tar zxvf zlib-1.2.11.tar.gz
	tar zxvf nginx-1.10.2.tar.gz
	cd nginx-1.10.2
	./configure --user=$USER_WEB --group=$USER_WEB --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module  --with-http_realip_module --with-http_addition_module --with-pcre=$INSTALL_PATH/pcre-8.40 --with-zlib=$INSTALL_PATH/zlib-1.2.11
	make && make install
[ $? -eq 0 ] && {
	ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx && echo "Nginx installed success.">>$INSTALL_LOG
	touch $INSTALL_PATH/NGX_INST.lock
	nginx -t && nginx || exit 89
	} || {
		echo "Nginx installed failed.">>$INSTALL_LOG
		exit 62
		}
	}
}

FGP_INST(){
##Install jpeg##################
cd $INSTALL_PATH
wget -c http://down1.chinaunix.net/distfiles/jpegsrc.v6b.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/freetype-2.4.8.tar.bz2 &&\
wget -c http://down1.chinaunix.net/distfiles/gd-2.0.33.tar.gz
[ -f jpegsrc.v6b.tar.gz ] && {
	tar -xzvf jpegsrc.v6b.tar.gz
	cd jpeg-6b/
	yes|cp /usr/share/libtool/config/config.guess .
	yes|cp /usr/share/libtool/config/config.sub .
	mkdir -p /usr/local/jpeg/include
	mkdir -p /usr/local/jpeg/lib
	mkdir -p /usr/local/jpeg/bin
	mkdir -p /usr/local/jpeg/man/man1
	./configure --prefix=/usr/local/jpeg --enable-shared
	make && make install
[ $? -eq 0 ] && {
	echo "jpeg installed success.">>$INSTALL_LOG
	} || {
		echo "jpeg installed failed.">>$INSTALL_LOG
		exit 63
		}
}



##Install freetype################
cd $INSTALL_PATH

[ -f freetype-2.4.8.tar.bz2 ] && {
	tar jxvf freetype-2.4.8.tar.bz2
	cd freetype-2.4.8
	./configure --prefix=/usr/local/freetype
	make && make install
[ $? -eq 0 ] && echo "freetype installed success">>$INSTALL_LOG || {
	echo "freetype installed failed.">>$INSTALL_LOG
	exit 69
	}
}

##Install GD lib###############
cd $INSTALL_PATH

[ -f gd-2.0.33.tar.gz ] && {
	tar -zxvf gd-2.0.33.tar.gz
	cd gd-2.0.33
	./configure --prefix=/usr/local/gd2 --with-png --with-freetype-dir=/usr/local/freetype --with-jpeg-dir=/usr/local/jpeg
	make && make install
[ $? -eq 0 ] && echo "gd lib installed success">>$INSTALL_LOG; touch $INSTALL_PATH/FGP_INST.lock || {
	echo "gd lib installed failed.">>$INSTALL_LOG
	exit 60
	}
	}
}

PHP52_INST(){
## Install PHP 5.2 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://down1.chinaunix.net/distfiles/php-5.2.17.tar.bz2 &&\
wget -c http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz
[ -f php-5.2.17.tar.bz2 ] && [ -f php-5.2.17-fpm-0.5.14.diff.gz ] && [ ! -e PHP52_INST.lock ] && {
	tar jxvf php-5.2.17.tar.bz2
	cd php-5.2.17/
	patch -p0 -b < ../php-5.x.x.patch
	if [ $WEB_INST = 3 ]; then 
		gzip -cd /data/php-5.2.17-fpm-0.5.14.diff.gz | patch -d /data/php-5.2.17 -p1
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fastcgi --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-recommended /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cp sapi/cgi/fpm/php-fpm /etc/init.d/
		chmod +x /etc/init.d/php-fpm
		sed -i '/Unix group /a<value name=\"group\">www<\/value>' /usr/local/php/etc/php-fpm.conf
		sed -i '/Unix user /a<value name=\"user\">www<\/value>' /usr/local/php/etc/php-fpm.conf
		service php-fpm start
		[ $? -eq 0 ] && {
				touch $INSTALL_PATH/PHP52_INST.lock
				echo "PHP installed success">>$INSTALL_LOG
		} || {
				echo "PHP installed failed">>$INSTALL_LOG
				exit 58
			}
		}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-recommended /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		[ $? -eq 0 ] && {
				touch $INSTALL_PATH/PHP52_INST.lock
				echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
		}
	fi
	}
}

PHP53_INST(){
##Install PHP 5.3 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-5.3.29.tar.bz2
[ -f php-5.3.29.tar.bz2 ] && [ ! -e PHP53_INST.lock ] && {
	tar jxvf php-5.3.29.tar.bz2
	cd php-5.3.29/
	if [ $WEB_INST = 3 ]; then
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cd /usr/local/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
		touch /$INSTALL_PATH/PHP53_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		[ $RL = 4 ] && libtool --finish /data/php-5.3.29/libs
		touch /$INSTALL_PATH/PHP53_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

PHP54_INST(){
##Install PHP 5.4 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-5.4.45.tar.bz2
[ -f php-5.4.45.tar.bz2 ] && [ ! -e PHP54_INST.lock ] && {
	tar jxvf php-5.4.45.tar.bz2
	cd php-5.4.45/
	if [ $WEB_INST = 3 ]; then
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cd /usr/local/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
		touch /$INSTALL_PATH/PHP54_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		touch /$INSTALL_PATH/PHP54_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

PHP55_INST(){
##Install PHP 5.5 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-5.5.38.tar.bz2
[ -f php-5.5.38.tar.bz2 ] && [ ! -e PHP55_INST.lock ] && {
	tar jxvf php-5.5.38.tar.bz2
	cd php-5.5.38/
	if [ $WEB_INST = 3 ]; then
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cd /usr/local/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
		touch /$INSTALL_PATH/PHP55_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		touch /$INSTALL_PATH/PHP55_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

PHP56_INST(){
##Install PHP 5.6 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-5.6.30.tar.bz2
[ -f php-5.6.30.tar.bz2 ] && [ ! -e PHP56_INST.lock ] && {
	tar jxvf php-5.6.30.tar.bz2
	cd php-5.6.30/
	if [ $WEB_INST = 3 ]; then
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cd /usr/local/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
		touch /$INSTALL_PATH/PHP56_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		touch /$INSTALL_PATH/PHP56_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

PHP70_INST(){
##Install PHP 7.0 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-7.0.17.tar.bz2
[ -f php-7.0.17.tar.bz2 ] && [ ! -e PHP70_INST.lock ] && {
	tar jxvf php-7.0.17.tar.bz2
	cd php-7.0.17/
	if [ $WEB_INST = 3 ]; then
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cd /usr/local/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
		touch /$INSTALL_PATH/PHP70_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		touch /$INSTALL_PATH/PHP70_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

PHP71_INST(){
##Install PHP 7.1 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-7.1.3.tar.bz2
[ -f php-7.1.3.tar.bz2 ] && [ ! -e PHP71_INST.lock ] && {
	tar jxvf php-7.1.3.tar.bz2
	cd php-7.1.3/
	if [ $WEB_INST = 3 ]; then
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		cd /usr/local/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/php/etc/php-fpm.conf
		touch /$INSTALL_PATH/PHP71_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
		make && make install
		[ $? -eq 0 ] && {
		cp php.ini-production /usr/local/php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
		touch /$INSTALL_PATH/PHP71_INST.lock
		echo "PHP installed success">>$INSTALL_LOG
		} || {
			echo "PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

ZOPT_INST(){
##Install ZendOptimizer##################
cd $INSTALL_PATH
wget -c http://down1.chinaunix.net/distfiles/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
[ -f ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ] && [ $PHP_INST = 1 ] && [ ! -e ZOPT_INST.lock ] && {
	mkdir -p /usr/local/php/include/php/ext/zend
	tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/php/include/php/ext/zend/ZendOptimizer.so
cat >>/usr/local/php/lib/php.ini<<EOF
##########################
zend_optimizer.optimization_level=1
zend_extension="/usr/local/php/include/php/ext/zend/ZendOptimizer.so"
##########################
EOF
	php-fpm
	echo "Zend installed Optimizer success">>$INSTALL_LOG
	touch $INSTALL_PATH/ZOPT_INST.lock
	}
}

ZendGL_INST(){
##Install Zend Guard Loader##################
cd $INSTALL_PATH
wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
[ -f ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ] && [ $PHP_INST = 2 ] && [ ! -e ZendGL_INST.lock ] && {
	mkdir -p /usr/local/php/include/php/ext/zend
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/php/include/php/ext/zend/ZendGuardLoader.so
cat >>/usr/local/php/lib/php.ini<<EOF
##########################
zend_extension="/usr/local/php/include/php/ext/zend/ZendGuardLoader.so"
zend_loader.enable=1 
zend_loader.disable_licensing=0 
zend_loader.obfuscation_level_support=3
##########################
EOF
	touch $INSTALL_PATH/ZendGL_INST.lock
	echo "Zend Guard Loader installed success">>$INSTALL_LOG
	}
}

[ ! -e $INSTALL_PATH/CHK_SYS.lock ] && CHK_SYS
[ ! -e $INSTALL_PATH/FTP_INST.lock ] && FTP_INST
[ ! -e $INSTALL_PATH/DOWN_SOFT.lock ] && DOWN_SOFT

#Mysql
case $Mysql_INST in
	1)
	[ ! -e $INSTALL_PATH/Mysql55_INST.lock ] && Mysql55_INST
	;;
	
	2)
	[ ! -e $INSTALL_PATH/Mysql56_INST.lock ] && Mysql56_INST
	;;
	
	3)
	[ ! -e $INSTALL_PATH/Mysql57_INST.lock ] && Mysql57_INST
	;;

esac

#Web server
case $WEB_INST in
	1)
	[ ! -e $INSTALL_PATH/APA22_INST.lock ] && APA22_INST
	;;
	
	2)
	[ ! -e $INSTALL_PATH/APA24_INST.lock ] && APA24_INST
	;;
	
	3)
	[ ! -e $INSTALL_PATH/NGX_INST.lock ] && NGX_INST
	;;

esac

#[ ! -e $INSTALL_PATH/FGP_INST.lock ] && [ $RL != 4 ] && FGP_INST

#Php
case $PHP_INST in
	1)
	[ ! -e $INSTALL_PATH/PHP52_INST.lock ] && PHP52_INST
	;;
	
	2)
	[ ! -e $INSTALL_PATH/PHP53_INST.lock ] && PHP53_INST
	;;
	
	3)
	[ ! -e $INSTALL_PATH/PHP54_INST.lock ] && PHP54_INST
	;;
	
	4)
	[ ! -e $INSTALL_PATH/PHP55_INST.lock ] && PHP55_INST
	;;
	
	5)
	[ ! -e $INSTALL_PATH/PHP56_INST.lock ] && PHP56_INST
	;;
	
	6)
	[ ! -e $INSTALL_PATH/PHP70_INST.lock ] && PHP70_INST
	;;
	
	7)
	[ ! -e $INSTALL_PATH/PHP71_INST.lock ] && PHP71_INST
	;;

esac

[ ! -e $INSTALL_PATH/ZOPT_INST.lock ] && ZOPT_INST
[ ! -e $INSTALL_PATH/ZendGL_INST.lock ] && ZendGL_INST

#ADD to system on boot
##/etc/rcS.d
if [ $WEB_INST = 3 ]; then
	if [ $RL = 2 -o $RL = 3 ]; then
cat > /etc/rc.d/init.d/nginx <<EOF
#!/bin/bash
#Start web service ON BOOT
/usr/local/nginx/sbin/nginx
EOF
		chmod 700 /etc/rc.d/init.d/nginx
		ln -s /etc/rc.d/init.d/nginx /etc/rc.d/rc3.d/S60nginx
		[ -e /etc/rc.d/rc3.d/S60nginx ] && echo "Nginx script installed success">>$INSTALL_LOG || {
			echo "Nginx script installed failed">>$INSTALL_LOG
			exit 75
			}
	else
cat > /etc/init.d/nginx <<EOF
#!/bin/bash
#Start web service ON BOOT
/usr/local/nginx/sbin/nginx
EOF
		chmod 700 /etc/init.d/nginx
		ln -s /etc/init.d/nginx /etc/rcS.d/S60nginx
		[ -e /etc/rcS.d/S60nginx ] && echo "Nginx script installed success">>$INSTALL_LOG || {
			echo "Nginx script installed failed">>$INSTALL_LOG
			exit 75
			}
	fi
else
	if [ $RL = 2 -o $RL = 3 ]; then
cat > /etc/rc.d/init.d/httpd <<EOF
#!/bin/bash
#Start web service ON BOOT
/usr/local/apache/bin/apachectl -k start
EOF
		chmod 700 /etc/rc.d/init.d/httpd
		ln -s /etc/rc.d/init.d/httpd /etc/rc.d/rc3.d/S60httpd
		[ -e /etc/rc.d/rc3.d/S60httpd ] && echo "Apache script installed success">>$INSTALL_LOG || {
			echo "Apache script installed failed">>$INSTALL_LOG
			exit 75
			}
	else
cat > /etc/init.d/httpd <<EOF
#!/bin/bash
#Start web service ON BOOT
/usr/local/apache/bin/apachectl -k start
EOF
		chmod 700 /etc/init.d/httpd
		ln -s /etc/init.d/httpd /etc/rcS.d/S60httpd
		[ -e /etc/rcS.d/S60httpd ] && echo "Apache script installed success">>$INSTALL_LOG || {
			echo "Apache script installed failed">>$INSTALL_LOG
			exit 75
			}
	fi
fi

[ $RL = 2 -o $RL = 3 ] && {
cat > /etc/rc.d/init.d/mysqld <<EOF
#!/bin/bash
#Start mysql service ON BOOT
/usr/local/mysql/support-files/mysql.server start
EOF
chmod 700 /etc/rc.d/init.d/mysqld
ln -s /etc/rc.d/init.d/mysqld /etc/rc3.d/S60mysqld
[ -e /etc/rc3.d/S60mysqld ] && echo "Mysql script installed success">>$INSTALL_LOG || {
	echo "Mysql script installed failed">>$INSTALL_LOG
	exit 76
	}
} || {
cat > /etc/init.d/mysqld <<EOF
#!/bin/bash
#Start mysql service ON BOOT
/usr/local/mysql/support-files/mysql.server start
EOF
	chmod 700 /etc/init.d/mysqld
	ln -s /etc/init.d/mysqld /etc/rcS.d/S60mysqld
[ -e /etc/rcS.d/S60mysqld ] && echo "Mysql script installed success">>$INSTALL_LOG || {
	echo "Mysql script installed failed">>$INSTALL_LOG
	exit 76
	}
}


#iptables
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT
service iptables save

#start mysql
service mysqld start

#start php-fpm
if [ $PHP_INST = 1 -a $WEB_INST = 3 ]; then
	service php-fpm start
else
	[ $WEB_INST = 3 ] && /usr/local/php/sbin/php-fpm
fi

#Add to system environment
echo "export PATH=/usr/local/apache/bin:/usr/local/nginx/sbin:/usr/local/php/sbin:/usr/local/mysql/bin:$PATH">>/etc/profile
source /etc/profile

###########
echo "#####################"
#网站用户-web server's running user
echo -e "The user you want to run the web server. is: ${GREEN_COLOR}$USER_WEB$RES"
echo -e "The user you want to run the web server. is: $USER_WEB">>$INSTALL_LOG

#用户密码-user password
echo -e "The user's password. is: ${GREEN_COLOR}$USER_PSWD$RES"
echo -e "The user's password. is: $USER_PSWD">>$INSTALL_LOG

#Mysql root 密码-mysql root's passwd
echo -e "The Mysql root's password. is: ${GREEN_COLOR}$Mysql_PSWD$RES"
echo -e "The Mysql root's password. is: $Mysql_PSWD">>$INSTALL_LOG

#新建Mysql数据库名-website database name 
echo -e "The database name you want to create. is: ${GREEN_COLOR}$Mysql_DBname$RES"
echo -e "The database name you want to create. is: $Mysql_DBname">>$INSTALL_LOG

#Mysql普通用户名-normal mysql user
echo -e "The user you want to conncet mysql. is: ${GREEN_COLOR}$Mysql_USER$RES"
echo -e "The user you want to conncet mysql. is: $Mysql_USER">>$INSTALL_LOG

#Mysql普通用户密码-password for normal user
echo -e "The Mysql user's password. is: ${GREEN_COLOR}$Myuser_PSWD$RES"
echo -e "The Mysql user's password. is: $Myuser_PSWD">>$INSTALL_LOG
echo -e "\n"


DATE_INST=`date +%Y-%m-%d-%H:%M`
echo "Install finished at $DATE_INST."
echo "#####################END"
echo "Install finished at $DATE_INST.">>$INSTALL_LOG
echo -e "${GREEN_COLOR}You can find these important info in $INSTALL_LOG..$RES"
echo "#####################END">>$INSTALL_LOG
