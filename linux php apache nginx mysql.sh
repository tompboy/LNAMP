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
# Debug: Fix some mistakes..2017-08-08
# Debug: Fix some mistakes..2017-08-11
# Debug: Fix some mistakes..Change the method of generate random password...2017-08-14
# Debug: Fix some mistakes..Your can set the software version num...2017-08-15
# Update: PCRE version..2017-08-17
# Debug: Fix some mistakes..2017-08-18
# Debug: Fix some mistakes..2017-08-25
# Debug: Fix some mistakes..2017-08-28
# Add: Optimize the default location of all..
#      Apache:/usr/local/apache2.2 or /usr/local/apache2.4, and will create a soft link to /usr/local/apache..
#      Mysql:/usr/local/mysql5.5.57 or /usr/local/mysql5.6.37 or.., and will create a soft link to /usr/local/mysql..
#		PHP:/usr/local/apache_php52 or /usr/local/nginx_php53 or .., and will create a soft link to 
#			/usr/local/apache_php or /usr/local/nginx_php..2017-08-31
# Debug: change sth version, php, mysql, apache..2017-10-16
# Debug: Fix some mistakes..2017-10-16
# Debug: Fix some mistakes..2017-10-19
# Debug: Fix some mistakes..2017-10-23
# Debug: update sth versions, php, apache..2017-11-2
# Add: nginx php+enable-zip..2017-11-17
# Debug: Fix MySQL version...2018-01-25
# Debug: Fix MySQL version...2018-03-01
# Debug: Fix some mistakes...2018-07-09
# Debug: Fix some mistakes...2019-05-08
# Project home: https://github.com/tompboy/LNAMP
# Version:V 0.18


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

#CPU核数，cpu cores
CPU_C=`cat /proc/cpuinfo |grep "processor"|wc -l`


yum -y install expect && {

#网站用户-user who run the web server
USER_WEB=www

#用户密码-the password for the user
USER_PSWD=`mkpasswd -l 16`
echo -e "The user's password. is: $USER_PSWD">>$INSTALL_LOG

#Mysql root 密码-the password for mysql root
Mysql_PSWD=`mkpasswd -l 16`
echo -e "The Mysql root's password. is: $Mysql_PSWD">>$INSTALL_LOG

#新建Mysql数据库名-the database name
Mysql_DBname=wwwdb

#Mysql普通用户名-normal user for mysql
Mysql_USER=wwwdbuser

#Mysql普通用户随机16位数密码-password for normal user, random 16 chars
Myuser_PSWD=`mkpasswd -l 16`
echo -e "The Mysql user's password. is: $Myuser_PSWD">>$INSTALL_LOG
} || { echo "Install expect failed..."; exit 002; }

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
4. Install Mysql 8.0
5. NOT install
EOF
}
menu
read -p "Please input which Mysql Database you want to install.." Mysql_INST
echo -e "\n"
if [[ $Mysql_INST != [1-5] ]]; then
	echo "Input error, please input the correct num[1-5].."
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
1. Install Apache 2.2.34
2. Install Apache 2.4
3. Install Nginx
4. NOT install
EOF
}
menu
read -p "Please input which web server you want to install.." WEB_INST
echo -e "\n"
if [[ $WEB_INST != [1-4] ]]; then
	echo "Input error, please input the correct num[1-4].."
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
5. Install PHP 5.6
6. Install PHP 7.0
7. Install PHP 7.1
8. Install PHP 7.2
9. Install PHP 7.3
10. NOT install
EOF
}
menu
read -p "Please input which PHP you want to install.." PHP_INST
echo -e "\n"
if [[ $PHP_INST != [1-9] ]]; then
	if [ j$PHP_INST != jX ]; then
		echo "Input error, please input the correct num[1-9] Or X.."
	fi
else
	break
fi
done


#Mysql version, update here
My55_Ver=5.5.62
My56_Ver=5.6.44
My57_Ver=5.7.26
My80_Ver=8.0.16

#Web Server version, update here
APA24_Ver=2.4.39
APR_Ver=1.7.0
APRU_Ver=1.6.1
NGX_Ver=1.16.0
PCRE_Ver=8.43
OSSL_Ver=1.1.1b
ZLIB_Ver=1.2.11



#PHP version, update here
PHP56_Ver=5.6.40
PHP70_Ver=7.0.33
PHP71_Ver=7.1.29
PHP72_Ver=7.2.18
PHP73_Ver=7.3.5


CHK_SYS(){
cd $INSTALL_PATH
[ ! -e CHK_SYS.lock ] && {
##检查系统-check system
echo "系统信息收集中/gathering system info...">>$INSTALL_LOG
echo "gathering system info..."

echo -e "127.0.0.1 $HOSTNAME">>/etc/hosts

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
USER_IF=`cat /etc/passwd|awk -F ":" '{print $1}'|grep www`
[ "$USER_IF"x != "$USER_WEB"x ] && useradd -s /sbin/nologin $USER_WEB && echo "$USER_WEB:$USER_PSWD"|chpasswd
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
	[ $RL = 2 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
	[ $RL = 3 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	rpm -qa|grep epel-release
	[ $? -eq 0 ] && yum -y install kernel-devel rpm-build patch make gcc gcc-c++ flex bison \
	file libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel libtool libpng \
	libpng-devel wget libaio* vim libmcrypt libmcrypt-devel mcrypt mhash openssl openssl-devel libtool-ltdl-devel  freetype freetype-devel gd-devel numactl expat-devel zlib-devel|| exit 39
else
	[ $RL = 4 ] && {
	apt-get update &&\
	apt-get -y install automake patch make gcc flex bison file libxml2 libxml2-dev libjpeg-dev libpng-dev curl libtool wget libaio-dev vim mcrypt openssl libssl-dev zlib1g zlib1g-dev libfreetype6 libfreetype6-dev libjpeg-dev libcurl4-gnutls-dev libmcrypt-dev libtool-bin libexpat1-dev&&\
	ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib
}
fi
echo "Downloading packages..">>$INSTALL_LOG
wget -c http://zlib.net/fossils/zlib-$ZLIB_Ver.tar.gz
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
wget -c https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-$My55_Ver-linux-glibc2.12-x86_64.tar.gz
[ -f mysql-$My55_Ver-linux-glibc2.12-x86_64.tar.gz ] && [ ! -e Mysql55_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-$My55_Ver-linux-glibc2.12-x86_64.tar.gz
	cp -rf mysql-$My55_Ver-linux-glibc2.12-x86_64 /usr/local/mysql$My55_Ver
	ln -sf /usr/local/mysql$My55_Ver /usr/local/mysql
	cd /usr/local/mysql
	rm -f /etc/my.cnf
	cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf
	sed -i '/\[mysqld\]/amax_connections = 800' /etc/my.cnf
	sed -i '/\[mysqld\]/await_timeout = 30' /etc/my.cnf
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
wget -c https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-$My56_Ver-linux-glibc2.12-x86_64.tar.gz
[ -f mysql-$My56_Ver-linux-glibc2.12-x86_64.tar.gz ] && [ ! -e Mysql56_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-$My56_Ver-linux-glibc2.12-x86_64.tar.gz
	cp -rf mysql-$My56_Ver-linux-glibc2.12-x86_64 /usr/local/mysql$My56_Ver
	ln -sf /usr/local/mysql$My56_Ver /usr/local/mysql
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
wget -c https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-$My57_Ver-linux-glibc2.12-x86_64.tar.gz
[ -f mysql-$My57_Ver-linux-glibc2.12-x86_64.tar.gz ] && [ ! -e Mysql57_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-$My57_Ver-linux-glibc2.12-x86_64.tar.gz
	cp -rf mysql-$My57_Ver-linux-glibc2.12-x86_64 /usr/local/mysql$My57_Ver
	ln -sf /usr/local/mysql$My57_Ver /usr/local/mysql
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
innodb_file_per_table = 1
EOF
	bin/mysqld --initialize --user=mysql &>/tmp/mysqlinstall{$DATE_INST}.log
	/usr/local/mysql/support-files/mysql.server start
[ $? -eq 0 ] && {
	LPASD=`cat /tmp/mysqlinstall{$DATE_INST}.log|grep root@localhost|awk -F":" '{print $4}'|sed s/[[:space:]]//g`
	#重设root用户密码
	/usr/local/mysql/bin/mysql -u root -p$LPASD --connect-expired-password -e "alter user 'root'@'localhost' IDENTIFIED BY '$Mysql_PSWD';"
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

Mysql80_INST(){
##Install MySQL 8.0 ################
cd $INSTALL_PATH
wget -c https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-$My80_Ver-linux-glibc2.12-x86_64.tar.xz
[ -f mysql-$My80_Ver-linux-glibc2.12-x86_64.tar.xz ] && [ ! -e Mysql80_INST.lock ] && {
	userdel -r mysql
	useradd mysql
	tar Jxvf mysql-$My80_Ver-linux-glibc2.12-x86_64.tar.xz
	cp -rf mysql-$My80_Ver-linux-glibc2.12-x86_64 /usr/local/mysql$My80_Ver
	ln -sf /usr/local/mysql$My80_Ver /usr/local/mysql
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
innodb_file_per_table = 1
EOF
	bin/mysqld --initialize --user=mysql &>/tmp/mysqlinstall{$DATE_INST}.log
	/usr/local/mysql/support-files/mysql.server start
[ $? -eq 0 ] && {
	LPASD=`cat /tmp/mysqlinstall{$DATE_INST}.log|grep root@localhost|awk -F":" '{print $4}'|sed s/[[:space:]]//g`
	#重设root用户密码
	/usr/local/mysql/bin/mysql -u root -p$LPASD --connect-expired-password -e "alter user 'root'@'localhost' IDENTIFIED BY '$Mysql_PSWD';"
	#创建数据库
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "create database $Mysql_DBname default charset utf8;"
	#赋普通用户权
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "grant all on $Mysql_DBname.* to $Mysql_USER@'127.0.0.1' identified by '$Myuser_PSWD';"
	#刷新权限
	/usr/local/mysql/bin/mysql -u root -p$Mysql_PSWD -e "flush privileges;"
	cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
	service mysqld stop
	touch $INSTALL_PATH/Mysql80_INST.lock
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
wget -c http://archive.apache.org/dist/httpd/httpd-2.2.34.tar.bz2
[ -f httpd-2.2.34.tar.bz2 ] && [ ! -e APA22_INST.lock ] && {
tar -jxvf httpd-2.2.34.tar.bz2
cd httpd-2.2.34
./configure --prefix=/usr/local/apache2.2 --enable-module=so --enable-mods-shared='rewrite' --enable-deflate --enable-proxy-http --enable-proxy
make -j$CPU_C && make install

[ $? -eq 0 ] && {
#vi /usr/local/apache/conf/httpd.conf
ln -s /usr/local/apache2.2 /usr/local/apache
sed -i 's/User daemon/User '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/Group daemon/Group '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' /usr/local/apache/conf/httpd.conf
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
wget -c http://archive.apache.org/dist/httpd/httpd-$APA24_Ver.tar.bz2 &&\
wget -c http://archive.apache.org/dist/apr/apr-$APR_Ver.tar.bz2 &&\
wget -c http://archive.apache.org/dist/apr/apr-util-$APRU_Ver.tar.bz2 &&\
wget -c https://ftp.pcre.org/pub/pcre/pcre-$PCRE_Ver.tar.bz2
[ -f apr-$APR_Ver.tar.bz2 ] && [ -f apr-util-$APRU_Ver.tar.bz2 ] && [ -f httpd-$APA24_Ver.tar.bz2 ] && [ ! -e APA24_INST.lock ] && {
tar jxvf apr-$APR_Ver.tar.bz2
cd apr-$APR_Ver
./configure --prefix=/usr/local/apr && make -j$CPU_C && make install
cd $INSTALL_PATH
tar jxvf apr-util-$APRU_Ver.tar.bz2
cd apr-util-$APRU_Ver
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config && make -j$CPU_C && make install
cd $INSTALL_PATH
tar jxvf pcre-$PCRE_Ver.tar.bz2
cd pcre-$PCRE_Ver
./configure --prefix=/usr/local/pcre && make -j$CPU_C && make install

cd $INSTALL_PATH
tar -jxvf httpd-$APA24_Ver.tar.bz2
cd httpd-$APA24_Ver
./configure --prefix=/usr/local/apache$APA24_Ver --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-module=so --enable-mods-shared='rewrite' --enable-deflate --enable-proxy-http --enable-proxy --with-pcre=/usr/local/pcre
make -j$CPU_C && make install

[ $? -eq 0 ] && {
#vi /usr/local/apache/conf/httpd.conf
ln -s /usr/local/apache$APA24_Ver /usr/local/apache
sed -i 's/User daemon/User '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/Group daemon/Group '$USER_WEB'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /usr/local/apache/conf/httpd.conf
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
	ThreadLimit		250
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
wget -c http://nginx.org/download/nginx-$NGX_Ver.tar.gz &&\
wget -c https://ftp.pcre.org/pub/pcre/pcre-$PCRE_Ver.tar.bz2 &&\
wget -c https://www.openssl.org/source/openssl-$OSSL_Ver.tar.gz
[ -f pcre-$PCRE_Ver.tar.bz2 ] && [ -f zlib-$ZLIB_Ver.tar.gz ] && [ -f nginx-$NGX_Ver.tar.gz ] && [ ! -e NGX_INST.lock ] && [ -f openssl-$OSSL_Ver.tar.gz ] && {
	tar jxvf pcre-$PCRE_Ver.tar.bz2
	tar zxvf zlib-$ZLIB_Ver.tar.gz
	tar zxvf nginx-$NGX_Ver.tar.gz
	tar zxvf openssl-$OSSL_Ver.tar.gz
	cd nginx-$NGX_Ver
	./configure --user=$USER_WEB --group=$USER_WEB --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module  --with-http_realip_module --with-http_addition_module --with-pcre=$INSTALL_PATH/pcre-$PCRE_Ver --with-zlib=$INSTALL_PATH/zlib-$ZLIB_Ver --with-http_ssl_module --with-openssl=$INSTALL_PATH/openssl-$OSSL_Ver --with-http_v2_module --with-stream
	make -j$CPU_C && make install
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


PHP52_INST(){
## Install PHP 5.2 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://museum.php.net/php5/php-5.2.17.tar.bz2 &&\
wget -c http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz &&\
wget -c https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt && mv txtbgxGXAvz4N.txt php-5.x.x.patch
[ -f php-5.2.17.tar.bz2 ] && [ -f php-5.2.17-fpm-0.5.14.diff.gz ] && {
	tar jxvf php-5.2.17.tar.bz2
	cd php-5.2.17/
	patch -p0 -b < ../php-5.x.x.patch
	if [ $WEB_INST = 3 -a ! -e NGX_PHP52_INST.lock ]; then 
		gzip -cd /data/php-5.2.17-fpm-0.5.14.diff.gz | patch -d /data/php-5.2.17 -p1
		./configure --prefix=/usr/local/nginx_php52 --with-mysql=/usr/local/mysql --enable-fastcgi --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php52 /usr/local/nginx_php
		cp php.ini-recommended /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cp sapi/cgi/fpm/php-fpm /etc/init.d/
		chmod +x /etc/init.d/php-fpm
		sed -i '/Unix group /a<value name=\"group\">www<\/value>' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i '/Unix user /a<value name=\"user\">www<\/value>' /usr/local/nginx_php/etc/php-fpm.conf
		service php-fpm start
		[ $? -eq 0 ] && {
				touch $INSTALL_PATH/NGX_PHP52_INST.lock
				echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
				echo "Nginx PHP installed failed">>$INSTALL_LOG
				exit 58
			}
		}
	else
		./configure --prefix=/usr/local/apache_php52 --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php52 /usr/local/apache_php
		cp php.ini-recommended /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		[ $? -eq 0 ] && {
				touch $INSTALL_PATH/APA_PHP52_INST.lock
				echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
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
[ -f php-5.3.29.tar.bz2 ] && {
	tar jxvf php-5.3.29.tar.bz2
	cd php-5.3.29/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP53_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php53 --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php53 /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.conf
		touch $INSTALL_PATH/NGX_PHP53_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php53 --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php53 /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		[ $RL = 4 ] && libtool --finish /data/php-5.3.29/libs
		touch $INSTALL_PATH/APA_PHP53_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
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
[ -f php-5.4.45.tar.bz2 ] && {
	tar jxvf php-5.4.45.tar.bz2
	cd php-5.4.45/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP54_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php54 --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php54 /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.conf
		touch $INSTALL_PATH/NGX_PHP54_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php54 --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php54 /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP54_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
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
[ -f php-5.5.38.tar.bz2 ] && {
	tar jxvf php-5.5.38.tar.bz2
	cd php-5.5.38/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP55_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php55 --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php55 /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.conf
		touch $INSTALL_PATH/NGX_PHP55_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php55 --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php55 /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP55_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
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
wget -c http://cn2.php.net/distributions/php-$PHP56_Ver.tar.bz2
[ -f php-$PHP56_Ver.tar.bz2 ] && {
	tar jxvf php-$PHP56_Ver.tar.bz2
	cd php-$PHP56_Ver/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP56_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php$PHP56_Ver --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php$PHP56_Ver /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.conf
		touch $INSTALL_PATH/NGX_PHP56_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php$PHP56_Ver --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php$PHP56_Ver /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP56_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
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
wget -c http://cn2.php.net/distributions/php-$PHP70_Ver.tar.bz2
[ -f php-$PHP70_Ver.tar.bz2 ] && {
	tar jxvf php-$PHP70_Ver.tar.bz2
	cd php-$PHP70_Ver/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP70_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php$PHP70_Ver --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php$PHP70_Ver /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.conf
		touch $INSTALL_PATH/NGX_PHP70_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php$PHP70_Ver --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php$PHP70_Ver /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP70_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
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
wget -c http://cn2.php.net/distributions/php-$PHP71_Ver.tar.bz2
[ -f php-$PHP71_Ver.tar.bz2 ] && {
	tar jxvf php-$PHP71_Ver.tar.bz2
	cd php-$PHP71_Ver/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP71_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php$PHP71_Ver --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php$PHP71_Ver /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/php-fpm.d
		cp www.conf.default www.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		touch $INSTALL_PATH/NGX_PHP71_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php$PHP71_Ver --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php$PHP71_Ver /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP71_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}


PHP72_INST(){
##Install PHP 7.2 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-$PHP72_Ver.tar.bz2
[ -f php-$PHP72_Ver.tar.bz2 ] && {
	tar jxvf php-$PHP72_Ver.tar.bz2
	cd php-$PHP72_Ver/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP72_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php$PHP72_Ver --with-mysql=/usr/local/mysql --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php$PHP72_Ver /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/php-fpm.d
		cp www.conf.default www.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		touch $INSTALL_PATH/NGX_PHP72_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php$PHP72_Ver --enable-zip --with-mysql=/usr/local/mysql --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php$PHP72_Ver /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP72_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
	}
}

PHP73_INST(){
##Install PHP 7.3 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
wget -c http://cn2.php.net/distributions/php-$PHP73_Ver.tar.bz2
wget -c https://libzip.org/download/libzip-1.5.2.tar.xz
wget -c https://github.com/Kitware/CMake/releases/download/v3.14.3/cmake-3.14.3.tar.gz
[ -f php-$PHP73_Ver.tar.bz2 ] && {
	tar jxvf php-$PHP73_Ver.tar.bz2
	tar Jxvf libzip-1.5.2.tar.xz
	tar zxvf cmake-3.14.3.tar.gz
	cd cmake-3.14.3
	./configure &&gmake && make install
	cd $INSTALL_PATH/libzip-1.5.2
	mkdir build && cd build
	yum -y install mysql-devel
	cmake ..
	make && make install
echo '/usr/local/lib64
/usr/local/lib
/usr/lib
/usr/lib64'>>/etc/ld.so.conf&&ldconfig
	cd $INSTALL_PATH/php-$PHP73_Ver/
	if [ $WEB_INST = 3 -a ! -e NGX_PHP73_INST.lock ]; then
		./configure --prefix=/usr/local/nginx_php$PHP73_Ver --enable-fpm --enable-zip --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mysqli --with-pdo-mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/nginx_php$PHP73_Ver /usr/local/nginx_php
		cp php.ini-production /usr/local/nginx_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/nginx_php/lib/php.ini
		cd /usr/local/nginx_php/etc/php-fpm.d
		cp www.conf.default www.conf
		sed -i 's/user = nobody/user = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/group = nobody/group = '$USER_WEB'/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;rlimit_files = 1024/rlimit_files = 10240/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/pm = dynamic/pm = static/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/pm.max_children = 5/pm.max_children = 100/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pm.max_requests = 500/pm.max_requests = 5000/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pm.status_path = \/pmstatus/pm.status_path = \/pmstatus/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 30s/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		sed -i 's/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g' /usr/local/nginx_php/etc/php-fpm.d/www.conf
		touch $INSTALL_PATH/NGX_PHP73_INST.lock
		echo "Nginx PHP installed success">>$INSTALL_LOG
		} || {
			echo "Nginx PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	else
		./configure --prefix=/usr/local/apache_php$PHP73_Ver --enable-zip --with-apxs2=/usr/local/apache/bin/apxs --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --enable-bcmath --enable-sockets --with-gettext
		make -j$CPU_C && make install
		[ $? -eq 0 ] && {
		ln -s /usr/local/apache_php$PHP73_Ver /usr/local/apache_php
		cp php.ini-production /usr/local/apache_php/lib/php.ini
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/apache_php/lib/php.ini
		touch $INSTALL_PATH/APA_PHP73_INST.lock
		echo "Apache PHP installed success">>$INSTALL_LOG
		} || {
			echo "Apache PHP installed failed">>$INSTALL_LOG
			exit 58
			}
	fi
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
	
	4)
	[ ! -e $INSTALL_PATH/Mysql80_INST.lock ] && Mysql80_INST
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



#Php
case $PHP_INST in
	1)
	[ ! -e $INSTALL_PATH/NGX_PHP52_INST.lock -o ! -e $INSTALL_PATH/APA_PHP52_INST.lock ] && PHP52_INST
	;;
	
	2)
	[ ! -e $INSTALL_PATH/NGX_PHP53_INST.lock -o ! -e $INSTALL_PATH/APA_PHP53_INST.lock ] && PHP53_INST
	;;
	
	3)
	[ ! -e $INSTALL_PATH/NGX_PHP54_INST.lock -o ! -e $INSTALL_PATH/APA_PHP54_INST.lock ] && PHP54_INST
	;;
	
	4)
	[ ! -e $INSTALL_PATH/NGX_PHP55_INST.lock -o ! -e $INSTALL_PATH/APA_PHP55_INST.lock ] && PHP55_INST
	;;
	
	5)
	[ ! -e $INSTALL_PATH/NGX_PHP56_INST.lock -o ! -e $INSTALL_PATH/APA_PHP56_INST.lock ] && PHP56_INST
	;;
	
	6)
	[ ! -e $INSTALL_PATH/NGX_PHP70_INST.lock -o ! -e $INSTALL_PATH/APA_PHP70_INST.lock ] && PHP70_INST
	;;
	
	7)
	[ ! -e $INSTALL_PATH/NGX_PHP71_INST.lock -o ! -e $INSTALL_PATH/APA_PHP71_INST.lock ] && PHP71_INST
	;;
	
	8)
	[ ! -e $INSTALL_PATH/NGX_PHP72_INST.lock -o ! -e $INSTALL_PATH/APA_PHP72_INST.lock ] && PHP72_INST
	;;
	
	9)
	[ ! -e $INSTALL_PATH/NGX_PHP73_INST.lock -o ! -e $INSTALL_PATH/APA_PHP73_INST.lock ] && PHP73_INST
	;;

esac



#ADD to system on boot
#### Web
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
	elif [ $WEB_INST = 4 ]; then
	echo "No web server installed..">>$INSTALL_LOG
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

### Mysql
if [ $Mysql_INST -le 3 ]; then
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
else
echo "No Mysql installed.">>$INSTALL_LOG
fi


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
	[ $WEB_INST = 3 ] && /usr/local/nginx_php/sbin/php-fpm
fi

#Add to system environment
echo "export PATH=/usr/local/apache/bin:/usr/local/nginx/sbin:/usr/local/nginx_php/sbin:/usr/local/mysql/bin:$PATH">>/etc/profile
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


DATE_FIN=`date +%Y-%m-%d-%H:%M`
echo "Install finished at $DATE_FIN.."
echo "#####################END"
echo "Install finished at $DATE_FIN.">>$INSTALL_LOG
echo -e "${GREEN_COLOR}You can find these important info in $INSTALL_LOG..$RES"
echo "#####################END">>$INSTALL_LOG