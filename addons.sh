#!/bin/bash
# Date:2017-08-31
# Author:Pboy Tom:)
# QQ:360254363/pboy@sina.cn
# E-mail:cylcjy009@gmail.com
# Website:www.pboy8.top pboy8.taobao.com
# Desc:Install zend etc. for php additional component ..
# Add: zend optimizer ..2017-08-31
# Project home: https://github.com/tompboy/LNAMP
# Version:V 0.1


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

[ ! -e $INSTALL_PATH/ZOPT_INST.lock ] && ZOPT_INST
[ ! -e $INSTALL_PATH/ZendGL_INST.lock ] && ZendGL_INST