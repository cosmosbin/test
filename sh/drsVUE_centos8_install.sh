#!/bin/bash

#执行出现报错，自动退出不继续执行,关闭自动退出 set +e
#set -e

#扑捉错误信号并输出行号
trap 'echo $LINENO' 2

if [[ -z $1 ]]; then
        echo "please input PKG,E.G (drsVUE_centos8_install.sh drsVUE_update_20201014.tar.gz)"
        exit
fi

if [[ ! -e './md5' ]]; then
	echo '无法找到md5文件！'
	exit
fi
#检验安装文件MD5的完整性,md5文件在pkg-vue.sh打包时生成。
ins_files=($1 './drsVUE_centos8_ENV.tar.gz' './drsVUE-base.tar.gz')
err_message=''
for ((i=0;i<${#ins_files[@]};i++)) do
        file_md5=`md5sum ${ins_files[i]} 2>/dev/null|awk '{print($1)}'`
        md5lines=`grep '^'$file_md5'$' md5|wc -l`
        if [[ ! -e ${ins_files[i]} || $md5lines == 0 ]];then
                err_message=${err_message}' '${ins_files[i]}
                #echo "安装文件 '${ins_files[i]}' 无效或不存在，请核实后重试！"
	    fi
done
#检验传入的$1更新包是否为正确的更新包，pkg-vue.sh打包时会创建一个标记文件（update_pkg_sign）用于这里检查。
test_update_pak=`tar -tvf $1 2>/dev/null|grep update_pkg_sign|wc -l`
if [[ $test_update_pak == 0 ]]; then
	err_message=${err_message}' 更新包'$1
	#echo "更新包 '$1' 无效，请核实后重试！"
	#exit
fi
if [[ $err_message != "" ]]; then
	echo "安装文件 '${err_message}' 无效，请核实后重试！"
	exit
fi

npath=$(cd `dirname $0`;pwd)
exec 2>$npath'/err.log'
echo "现在开始安装系统环境......"
tar -zxmf $npath'/drsVUE_centos8_ENV.tar.gz' -C /

##config java ENV，for erlang runing.
#cat << EOF >> /etc/profile
#export JAVA_HOME=/drsBT/jdk1.8/
#export JRE_HOME=/drsBT/jdk1.8/jre
#export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
#export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
#EOF
#source /etc/profile

##backup YUM repos.
mv /etc/yum.repos.d/* /drsBT/yum/repo/bak/
yum clean all
\cp /drsBT/yum/repo/local.repo /etc/yum.repos.d/
yum makecache
yum install -y lib64ossp-uuid16.x86_64 yasm libxcb SDL alsa-lib compat-openssl10 libSM.x86_64 libXinerama.x86_64 cairo libGL 
##安装libreoffice需要先用rpm安装javapackages-filesystem包,否则yum安装libreoffice无法成功。
##libreoffice6目前不支持资源站转码，因此只使用原编译过的5.1版本，需要安装libSM.x86_64
#rpm -ivh /drsBT/yum/libreoffice/javapackages-filesystem-5.3.0-1.module_el8.0.0+11+5b8c10bd.noarch.rpm
#yum install -y libreoffice-core.x86_64
##安装erlang，javapackages-filesystem、javapackages-tools必需手动安装，javapackages-tools需要java-1.8.0-openjdk-headless依赖
rpm -ivh /drsBT/yum/javapackages-filesystem-5.3.0-1.module_el8.0.0+11+5b8c10bd.noarch.rpm 
yum install -y java-1.8.0-openjdk-headless
rpm -ivh /drsBT/yum/javapackages-tools-5.3.0-1.module_el8.0.0+11+5b8c10bd.noarch.rpm
yum install -y erlang
yum install -y libreoffice5.*
rm -rf /etc/yum.repos.d/local.repo
\cp -rf /drsBT/yum/repo/bak/* /etc/yum.repos.d/ 
yum clean all

cp -rf /drsBT/etc/service/* /usr/lib/systemd/system/

##instll postgresql 9.4
adduser -M postgres
echo "正在安装基础包......"
tar -zxmf ./drsVUE-base.tar.gz -C /drsBT/
echo "正在安装更新包......"
tar -zxmf $1 -C /
rm -rf /drsBT/etc_mar
rm -rf /drsBT/lib_mar
rm -rf /drsBT/sh_mar
#将更新包中最新NGINX配置文件替换掉旧的配置文件，否则日志无法记录IP地址。
\cp -rf /drsBT/etc/conf/nginx.conf /drsBT/nginx/conf/
##config ffmpeg ENV
echo '/drsBT/ffmpeg/lib/' >> /etc/ld.so.conf
echo '/drsBT/x264/lib/' >> /etc/ld.so.conf
ldconfig

##import windows fonts
fdir="/usr/share/fonts"
if [[ ! -d $fdir ]]; then
	mkdir -p /usr/share/fonts
fi
tar -zxmf /drsBT/lib/win_fonts.tar.gz -C "$fdir"

##modify config for drsVUE
sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-admin/config/application-test.yml
sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-api/config/application-test.yml
sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-solr/config/application-test.yml
sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-transcode/config/application-test.yml

##import service for drsBT
echo "正在配置服务......"

systemctl enable pgsql
systemctl enable solr
systemctl enable redis
systemctl enable rabbitmq
systemctl enable proftpd
systemctl enable oo
systemctl enable nginx
systemctl enable drs-admin
systemctl enable drs-api
systemctl enable drs-solr
systemctl enable drs-transcode

##config crontab
echo "10 1 * * * /drsBT/sh/catfish.sh /drsBT/log" >> /var/spool/cron/root
echo "30 1 * * * /drsBT/sh/pgbk.sh /drsBT/bak/ 3" >> /var/spool/cron/root

##close selinux.
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

st=`ifconfig |grep ether |head -1|awk '{print($2)}'`
release=`cat /etc/redhat-release`
echo ' '
echo '#####################################################'
echo '资源站安装完成!'
echo '本机系统为'$release',MAC为:'$st
echo '请将该MAC发至厂商申请许可证,并将申请后的许可文件'
echo '上传至以下目录/drsBT/drs/drs-api/lib/dat/'
echo '请重启系统并使用 http://ip:8088/访问资源站!'
echo '######################################################'
sleep 3