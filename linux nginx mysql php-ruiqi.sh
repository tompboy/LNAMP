#!/bin/bash
# Date:2017-03-09
# Author:Pboy Tom:)
# QQ:360254363
# Desc:Install nginx-1.10 php-5.2,gd2,freetype2,mysql-5.5 on linux Centos6, for ruiqi soft..
# Add: php5.3 Apache...and on Centos7..2017-03-17
# Version:V 0.3

##预定义变量
#时间
DATE_INST=`date +%Y-%m-%d-%H-%M`

#安装日志文件
INSTALL_LOG=/tmp/install_log$DATE_INST

#源码安装包下载目录
INSTALL_PATH=/data
#USER_WEB=www

#用户
#USER_WEB=""
read -p "Please input the user you want to run the web server." USER_WEB

#用户密码
read -p "Please input the user's password." USER_PSWD

#Mysql root 密码
read -p "Please input the Mysql root's password." Mysql_PSWD

#新建Mysql数据库名
read -p "Please input the database name you want to create." Mysql_DBname

#Mysql普通用户名
read -p "Please input the user you want to conncet mysql." Mysql_USER

#Mysql普通用户密码
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




##检查系统
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



##系统参数优化
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
echo "*       hard    nproc  65535" >>/etc/security/limits.d/90-nproc.conf
sed -i 's/1024/65535/g' /etc/security/limits.d/90-nproc.conf
[ $? -eq 0 ] && echo "Optimize system successful">>$INSTALL_LOG || {
	echo "Optimize system failed.">>$INSTALL_LOG
	exit 66
}

 
##安装FTP，建立用户，并设置密码
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
[ $? -eq 0 ] && echo "user $USER_WEB created success">>$INSTALL_LOG || {
	echo "user $USER_WEB created failed">>$INSTALL_LOG
	exit 96
}


mkdir -p $INSTALL_PATH
cd $INSTALL_PATH
#安装依赖包\下载安装源码包
#epel
RL=`uname -r|awk -F "." '{print $1}'`
[ $RL = 2 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
[ $RL = 3 ] && rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm

[ $? -eq 0 ] && yum -y install kernel-devel rpm-build patch make gcc gcc-c++ flex bison file libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel libtool libpng libpng-devel wget libaio* vim libmcrypt libmcrypt-devel mcrypt mhash || exit 39

echo "Downloading packages..">>$INSTALL_LOG
wget -c http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.53-linux2.6-x86_64.tar.gz && wget -c http://nginx.org/download/nginx-1.10.2.tar.gz && wget -c https://sourceforge.net/projects/pcre/files/pcre/8.35/pcre-8.35.tar.gz && wget -c http://zlib.net/fossils/zlib-1.2.11.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/jpegsrc.v6b.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/freetype-2.4.8.tar.bz2 &&\
wget -c http://down1.chinaunix.net/distfiles/gd-2.0.33.tar.gz &&\
wget -c http://down1.chinaunix.net/distfiles/php-5.2.17.tar.bz2 && wget -c http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz &&\
wget -c http://down1.chinaunix.net/distfiles/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz &&\
wget -c https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt && mv txtbgxGXAvz4N.txt patch-5.x.x.patch &&\
wget -c http://cn2.php.net/distributions/php-5.3.29.tar.bz2 && wget -c http://archive.apache.org/dist/httpd/httpd-2.2.32.tar.bz2



#[ $? -ne 0 ] && {
#echo "download packages failed."
#echo "download packages failed.">>$INSTALL_LOG
#exit 99
#}


##安装MySQL################

[ -f mysql-5.5.53-linux2.6-x86_64.tar.gz ] && {
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
	echo "Mysql installed successful.">>$INSTALL_LOG
	} || {
		echo "Mysql installed failed.">>$INSTALL_LOG
		exit 5
		}
	} || {
		echo "Mysql download failed.">>$INSTALL_LOG
		exit 3
		}

		
APA22_INST(){
##安装apache#####################
cd $INSTALL_PATH
[ -f httpd-2.2.32.tar.bz2 ] && {
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

echo "apache2.2 installed success...">>$INSTALL_LOG
} || {
	echo "apache2.2 installed failed...">>$INSTALL_LOG
	exit 998
	}
} || {
	echo "apache2.2 download failed...">>$INSTALL_LOG
	exit 996
	}

/usr/local/apache/bin/apachectl -t && /usr/local/apache/bin/apachectl start

}

NGX_INST(){
##安装nginx################
cd $INSTALL_PATH
[ -f pcre-8.35.tar.gz ] && [ -f zlib-1.2.11.tar.gz ] && [ -f nginx-1.10.2.tar.gz ] && {
	tar zxvf pcre-8.35.tar.gz
	tar zxvf zlib-1.2.11.tar.gz
	tar zxvf nginx-1.10.2.tar.gz
	cd nginx-1.10.2
	./configure --user=$USER_WEB --group=$USER_WEB --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module  --with-http_realip_module --with-http_addition_module --with-pcre=$INSTALL_PATH/pcre-8.35 --with-zlib=$INSTALL_PATH/zlib-1.2.11
	make && make install
[ $? -eq 0 ] && {
	ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx && echo "Nginx installed success.">>$INSTALL_LOG
	nginx -t && nginx || exit 89
	} || {
		echo "Nginx installed failed.">>$INSTALL_LOG
		exit 62
		}
	} || {
		echo "Nginx download failed.">>$INSTALL_LOG
		exit 61
		}
}


##安装jpeg##################
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



##安装freetype################
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

##安装GD库###############
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

PHP52_INST(){
##安装PHP###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
[ -f php-5.2.17.tar.bz2 ] && [ -f php-5.2.17-fpm-0.5.14.diff.gz ] && {
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

PHP53_INST(){
##安装PHP###################
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
cd $INSTALL_PATH
[ -f php-5.3.29.tar.bz2 ] [ ! -e php53.lock ] && {
	tar jxvf php-5.3.29.tar.bz2
	cd php-5.3.29/
	./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --enable-fpm --with-freetype-dir=/usr/local/freetype --with-jpeg-dir=/usr/local/jpeg --with-png-dir --with-zlib --with-curl --with-iconv --enable-mbstring --with-gd --with-openssl --with-mcrypt --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql
	make && make install
[ $? -eq 0 ] && {
	cp php.ini-recommended /usr/local/php/lib/php.ini
	cp sapi/cgi/fpm/php-fpm /etc/init.d/
	chmod +x /etc/init.d/php-fpm
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/lib/php.ini
	#mkdir /etc/php
	#ln -s /usr/local/php/lib/php.ini /etc/php
	#ln -s /usr/local/php/etc/php-fpm.conf /etc/php
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

##安装ZendOptimizer##################
cd $INSTALL_PATH

[ -f ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ] && {
	mkdir -p /usr/local/php/include/php/ext/zend
	tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/php/include/php/ext/zend/ZendOptimizer.so
cat >>/usr/local/php/lib/php.ini<<EOF
##########################
zend_optimizer.optimization_level=1
zend_extension="/usr/local/php/include/php/ext/zend/ZendOptimizer.so"
##########################
EOF
	echo "Zend installed success">>$INSTALL_LOG
}|| {
	echo "Zend download failed">>$INSTALL_LOG
	exit 55
	}
sed -i '/Unix group /a<value name=\"group\">www<\/value>' /usr/local/php/etc/php-fpm.conf
sed -i '/Unix user /a<value name=\"user\">www<\/value>' /usr/local/php/etc/php-fpm.conf
service php-fpm start


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
echo "The user you want to run the web server. is $USER_WEB"

#用户密码
echo "The user's password. is $USER_PSWD "

#Mysql root 密码
echo  "The Mysql root's password. is $Mysql_PSWD"

#新建Mysql数据库名
echo  "The database name you want to create. is $Mysql_DBname"

#Mysql普通用户名
echo  "The user you want to conncet mysql. is $Mysql_USER"

#Mysql普通用户密码
echo  "The Mysql user's password. is $Myuser_PSWD"

DATE_INST=`date +%Y-%m-%d-%H:%M`
echo "Install finished at $DATE_INST."
echo "#####################END"
echo "Install finished at $DATE_INST.">>$INSTALL_LOG
echo "#####################END">>$INSTALL_LOG
exit 0