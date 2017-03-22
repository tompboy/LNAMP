#!/bin/bash
# Date:2017-03-09
# Author:Pboy Tom:)
# QQ:360254363/pboy@sina.cn
# E-mail:cylcjy009@gmail.com
# Website:www.pboy8.top pboy8.taobao.com
# Desc:Install nginx-1.10 php-5.2,gd2,freetype2,mysql-5.5 on linux Centos6, for ruiqi soft..
# Add: php5.3 Apache...and on Centos7..2017-03-17
# Add: php5.4,mysql 5.6...2017-03-22
# Version:V 0.5


##预定义变量-Predefined variables
#时间-date-time
DATE_INST=`date +%Y-%m-%d-%H-%M`

#安装日志文件-Instlal log
INSTALL_LOG=/tmp/install_log$DATE_INST

#源码安装包下载目录-Source packages download dir
INSTALL_PATH=/data
mkdir -p $INSTALL_PATH

#内核大版本-kernel version
RL=`uname -r|awk -F "." '{print $1}'`
#USER_WEB=www

#网站用户-user who run the web server
#USER_WEB=""
read -p "Please input the user you want to run the web server." USER_WEB

#用户密码-the password for the user
read -p "Please input the user's password." USER_PSWD

#Mysql root 密码-the password for mysql root
read -p "Please input the Mysql root's password." Mysql_PSWD

#新建Mysql数据库名-the database name
read -p "Please input the database name you want to create." Mysql_DBname

#Mysql普通用户名-normal user for mysql
read -p "Please input the user you want to conncet mysql." Mysql_USER

#Mysql普通用户密码-password for normal user
read -p "Please input the Mysql user's password." Myuser_PSWD

#Menu Web server
menu(){
cat <<EOF
1. Install Apache 2.4
2. Install Apache 2.2
3. Install Nginx
EOF
}
menu
read -p "Please input which web server you want to install.." WEB_INST

#Menu PHP
menu(){
cat <<EOF
1. Install PHP 5.2.17
2. Install PHP 5.3.29
EOF
}
menu
read -p "Please input which PHP you want to install.." PHP_INST



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

cat >>/etc/security/limits.conf<<EOF
*       soft    nofile  65535
*       hard    nofile  65535
EOF


[ $RL = 2 ] && echo "*       hard    nproc  65535" >>/etc/security/limits.d/90-nproc.conf && sed -i 's/1024/65535/g' /etc/security/limits.d/90-nproc.conf

[ $RL = 3 ] && echo "*       hard    nproc  65535" >> /etc/security/limits.d/20-nproc.conf && sed -i 's/4096/65535/g' /etc/security/limits.d/90-nproc.conf

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
yum install -y vsftpd
[ $? -eq 0 ] &&
{
	sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd/vsftpd.conf
	sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/g' /etc/vsftpd/vsftpd.conf
	service vsftpd start
[ `netstat -anp|grep vsftpd|wc -l` -gt 0 ] && echo "Vsftpd installed success.">>$INSTALL_LOG || {
	echo "Vsftpd installed failed.">>$INSTALL_LOG
	exit 2
}
}|| {
	echo "vsftpd download failed">>$INSTALL_LOG
	exit 1
	}

#建立用户,并设置密码
useradd -s /sbin/nologin $USER_WEB && echo "$USER_PSWD" |passwd --stdin $USER_WEB
[ $? -eq 0 ] && echo {
	"user $USER_WEB created success">>$INSTALL_LOG
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

[ ! -e DOWN_soft.lock ] && {
[ $RL = 2 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
[ $RL = 3 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm

[ $? -eq 0 ] && yum -y install kernel-devel rpm-build patch make gcc gcc-c++ flex bison \
file libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel libtool libpng \
libpng-devel wget libaio* vim libmcrypt libmcrypt-devel mcrypt mhash || exit 39

echo "Downloading packages..">>$INSTALL_LOG
wget -c http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.53-linux2.6-x86_64.tar.gz &&\
wget -c http://nginx.org/download/nginx-1.10.2.tar.gz &&\
wget -c https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.bz2 &&\
wget -c http://zlib.net/fossils/zlib-1.2.11.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/jpegsrc.v6b.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/freetype-2.4.8.tar.bz2 &&\
wget -c http://down1.chinaunix.net/distfiles/gd-2.0.33.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/php-5.2.17.tar.bz2 &&\
wget -c http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz &&\
wget -c http://down1.chinaunix.net/distfiles/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz &&\
wget -c https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt && mv txtbgxGXAvz4N.txt patch-5.x.x.patch &&\
wget -c http://cn2.php.net/distributions/php-5.3.29.tar.bz2 &&\
wget -c http://archive.apache.org/dist/httpd/httpd-2.2.32.tar.bz2 &&\
wget -c http://archive.apache.org/dist/httpd/httpd-2.4.25.tar.bz2 &&\
wget -c http://archive.apache.org/dist/apr/apr-1.5.2.tar.bz2 &&\
wget -c http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.bz2 &&\
wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz

[ $? -eq 0 ] && {
	echo "download packages success.">>$INSTALL_LOG
	touch $INSTALL_PATH/DOWN_soft.lock
	} || {
	echo "download packages failed."
	echo "download packages failed.">>$INSTALL_LOG
	exit 99
		}
	}
}

My55_INST(){
##Install MySQL 5.5 ################
cd $INSTALL_PATH
[ -f mysql-5.5.53-linux2.6-x86_64.tar.gz ] && [ ! -e Mysql55.lock ]{
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
	touch $INSTALL_PATH/Mysql55.lock
	echo "Mysql installed successful.">>$INSTALL_LOG
	} || {
		echo "Mysql installed failed.">>$INSTALL_LOG
		exit 5
		}
	}
}

My55_INST(){
##Install MySQL 5.6 ################
cd $INSTALL_PATH
wget -c https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
[ -f mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz ] && [ ! -e Mysql56.lock ]{
	userdel -r mysql
	useradd mysql
	tar zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
	cp -r mysql-5.6.35-linux-glibc2.5-x86_64 /usr/local/mysql
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
	touch $INSTALL_PATH/Mysql56.lock
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
#AddType application/x-httpd-php .php     
#AddType application/x-httpd-php-source .phps

cat >>/usr/local/apache/conf/httpd.conf<<EOF
NameVirtualHost *:80

<VirtualHost *:80>
DocumentRoot "/home/rong1net3"
ServerName www.rong1.net
<Directory /home/rong1net3>
Order allow,deny
Allow from all
</Directory>
</VirtualHost>

AddType application/x-httpd-php .php     
AddType application/x-httpd-php-source .phps

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
echo "apache2.2 installed success...">>$INSTALL_LOG
} || {
	echo "apache2.2 installed failed...">>$INSTALL_LOG
	exit 998
	}
}

/usr/local/apache/bin/apachectl -t && /usr/local/apache/bin/apachectl start

}

APA24_INST(){
##Install apache 2.4 #####################
cd $INSTALL_PATH
[ -f httpd-2.4.25.tar.bz2 ] && [ ! -e apa24_inst.lock ] && {
tar jxvf apr-1.5.2.tar.bz2
cd apr-1.5.2
./configure --prefix=/usr/local/apr && make && make install
cd $INSTALL_PATH
tar jxvf apr-util-1.5.4.tar.bz2
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config && make && make install
cd $INSTALL_PATH
tar zxvf pcre-8.35.tar.gz
cd pcre-8.35
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
#AddType application/x-httpd-php .php     
#AddType application/x-httpd-php-source .phps

cat >>/usr/local/apache/conf/httpd.conf<<EOF

<VirtualHost *:80>
DocumentRoot "/home/rong1net3"
ServerName www.rong1.net
<Directory /home/rong1net3>
AllowOverride All
Require all granted
</Directory>
</VirtualHost>

AddType application/x-httpd-php .php     
AddType application/x-httpd-php-source .phps

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
touch $INSTALL_PATH/apa24_inst.lock
echo "apache2.4 installed success...">>$INSTALL_LOG
} || {
	echo "apache2.4 installed failed...">>$INSTALL_LOG
	exit 998
	}
}

/usr/local/apache/bin/apachectl -t && /usr/local/apache/bin/apachectl start

}

NGX_INST(){
##Install nginx################
cd $INSTALL_PATH
[ -f pcre-8.40.tar.gz ] && [ -f zlib-1.2.11.tar.gz ] && [ -f nginx-1.10.2.tar.gz ] && [ ! -e NGX_INST.lock ] && {
	tar zxvf pcre-8.40.tar.gz
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
} || {
		echo "jpeg download failed.">>$INSTALL_LOG
		exit 65
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
	} || {
		echo "freetype download failed.">>$INSTALL_LOG
		exit 68
		}

##Install GD lib###############
cd $INSTALL_PATH

[ -f gd-2.0.33.tar.gz ] && {
	tar -zxvf gd-2.0.33.tar.gz
	cd gd-2.0.33
	./configure --prefix=/usr/local/gd2 --with-png --with-freetype-dir=/usr/local/freetype --with-jpeg-dir=/usr/local/jpeg
	make && make install
[ $? -eq 0 ] && echo "gd lib installed success">>$INSTALL_LOG || {
	echo "gd lib installed failed.">>$INSTALL_LOG
	exit 60
	}
	} || {
		echo "gd lib download failed.">>$INSTALL_LOG
		exit 59
		}
}

PHP52_INST(){
## Install PHP 5.2 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
[ -f php-5.2.17.tar.bz2 ] && [ -f php-5.2.17-fpm-0.5.14.diff.gz ] && [ ! -e PHP52_INST.lock ] && {
	tar jxvf php-5.2.17.tar.bz2
	gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1
	cd php-5.2.17/
	patch -p0 -b < ../php-5.x.x.patch
	./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fastcgi --enable-fpm --with-freetype-dir=/usr/local/freetype --with-jpeg-dir=/usr/local/jpeg --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd
	make && make install
[ $? -eq 0 ] && {
	cp php.ini-recommended /usr/local/php/lib/php.ini
	cp sapi/cgi/fpm/php-fpm /etc/init.d/
	chmod +x /etc/init.d/php-fpm
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
	#mkdir /etc/php
	#ln -s /usr/local/php/lib/php.ini /etc/php
	#ln -s /usr/local/php/etc/php-fpm.conf /etc/php
	touch $INSTALL_PATH/PHP52_INST.lock
	echo "PHP installed success">>$INSTALL_LOG
	} || {
		echo "PHP installed failed">>$INSTALL_LOG
		exit 58
		}
	}
}

PHP53_INST(){
##Install PHP 5.3 ###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
[ -f php-5.3.29.tar.bz2 ] && [ ! -e php53.lock ] && {
	tar jxvf php-5.3.29.tar.bz2
	cd php-5.3.29/
	./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir=/usr/local/freetype --with-jpeg-dir=/usr/local/jpeg --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
	make && make install
[ $? -eq 0 ] && {
	cp php.ini-production /usr/local/php/lib/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
	#mkdir /etc/php
	#ln -s /usr/local/php/lib/php.ini /etc/php
	#ln -s /usr/local/php/etc/php-fpm.conf /etc/php
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
	touch /$INSTALL_PATH/php53.lock
	echo "PHP installed success">>$INSTALL_LOG
	} || {
		echo "PHP installed failed">>$INSTALL_LOG
		exit 58
		}
	}|| {
		echo "PHP download failed">>$INSTALL_LOG
		exit 56
		}
}

ZOPT_INST(){
##Install ZendOptimizer##################
cd $INSTALL_PATH
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
	echo "Zend installed success">>$INSTALL_LOG
	touch $INSTALL_PATH/ZOPT_INST.lock
	}
}

ZendGL_INST(){
##Install Zend Guard Loader##################
cd $INSTALL_PATH
[ -f ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ] && [ $PHP_INST = 2 ] && [ ! -e ZendGL.lock ] && {
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
	touch $INSTALL_PATH/ZendGL.lock
	echo "Zend Guard Loader installed success">>$INSTALL_LOG
	}
}

CHK_SYS
FTP_INST
DOWN_SOFT
My55_INST

#Web server
case $WEB_INST in{
	1)
	APA24_INST
	;;
	
	2)
	APA22_INST
	;;
	
	3)
	NGX_INST
	;;
	
	*)
	echo "Wrong input..."
}
esac

FGP_INST

#Php
case $PHP_INST in{
	1)
	PHP52_INST
	;;
	
	2)
	PHP53_INST
	;;
	
	*)
	echo "Wrong input..."
}
esac

ZOPT_INST
ZendGL_INST


#ADD to system on boot

cat > /etc/rc.d/init.d/nginx <<EOF
#!/bin/bash
#Start httpd service
/usr/local/nginx/sbin/nginx
EOF
chmod 700 /etc/rc.d/init.d/nginx
ln -s /etc/rc.d/init.d/nginx /etc/rc.d/rc3.d/S60nginx
[ $? -eq 0 ] && echo "Nginx script installed success">>$INSTALL_LOG || {
	echo "Nginx script installed failed">>$INSTALL_LOG
	exit 75
	}

cat > /etc/rc.d/init.d/mysql <<EOF
#!/bin/bash
#Start mysql service
/usr/local/mysql/support-files/mysql.server start
EOF
chmod 700 /etc/rc.d/init.d/mysql
ln -s /etc/rc.d/init.d/mysql /etc/rc3.d/S60mysql
[ $? -eq 0 ] && echo "Mysql script installed success">>$INSTALL_LOG || {
	echo "Mysql script installed failed">>$INSTALL_LOG
	exit 76
	}

#iptables

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT

iptables -A OUTPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT

service iptables save


###########
echo "#####################"
#网站用户-web server's running user
echo "The user you want to run the web server. is $USER_WEB"

#用户密码-user password
echo "The user's password. is $USER_PSWD "

#Mysql root 密码-mysql root's passwd
echo  "The Mysql root's password. is $Mysql_PSWD"

#新建Mysql数据库名-website database name 
echo  "The database name you want to create. is $Mysql_DBname"

#Mysql普通用户名-normal mysql user
echo  "The user you want to conncet mysql. is $Mysql_USER"

#Mysql普通用户密码-password for normal user
echo  "The Mysql user's password. is $Myuser_PSWD"

DATE_INST=`date +%Y-%m-%d-%H:%M`
echo "Install finished at $DATE_INST."
echo "#####################END"
echo "Install finished at $DATE_INST.">>$INSTALL_LOG
echo "#####################END">>$INSTALL_LOG
exit 0
