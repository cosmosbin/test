#!/bin/bash

#################################################################################
# * 20210420脚本为Ubuntu 20.04.2 LTS提供资源站自动化安装.                         #
#################################################################################

if [[ -z $1 ]]; then
	echo "please input PKG,E.G (drsVUE_ubuntu20_ins.sh drsVUE_update_20190606.tar.gz)"
	exit
fi
if [[ ! -e $1 ]]; then
	echo "the file no find."
	exit
fi
npath=$(cd `dirname $0`;pwd)
exec 2>>$npath'/err.log'

env_pak='/drsVUE_ubuntu20_ENV.tar.gz'
base_pak='./drsVUE-base.tar.gz'
db='drs-vue'
echo "正在安装系统环境......"

tar -zxmf $npath$env_pak -C /
\cp -rf /drsBT/etc/service/pgsql.service /usr/lib/systemd/system/
##instll postgresql 9.4
useradd postgres
chown -R postgres:postgres /drsBT/pgsql/data
systemctl start pgsql
systemctl enable pgsql

mv /etc/apt/sources.list /etc/apt/sources.list.bak
\cp -rf /drsBT/etc/conf/sources.list /etc/apt/sources.list
apt update
apt -y install net-tools redis rabbitmq-server nginx libreoffice ffmpeg
mv /etc/apt/sources.list.bak /etc/apt/sources.list

echo "正在安装应用服务......"
while [[ ! -e $base_pak ]]; do
		echo "当前目录未找到基础包,请上传后重试."
		read
done
echo "正在安装基础包......"
tar -zxmf $base_pak -C /drsBT/
echo "正在安装更新包......"
tar -zxmf $1 -C /
rm -rf /drsBT/etc_mar
rm -rf /drsBT/lib_mar
rm -rf /drsBT/sh_mar
\cp -rf /drsBT/etc/conf/nginx.conf /etc/nginx/nginx.conf
mkdir -p /drsBT/ftp/trans_file/trans_file
\cp -rf /drsBT/etc/service/drs-* /usr/lib/systemd/system/
\cp -rf /drsBT/etc/service/{oo.service,proftpd.service,solr.service} /usr/lib/systemd/system/

##import windows fonts
fdir="/usr/share/fonts"
if [[ ! -d $fdir ]]; then
	mkdir -p /usr/share/fonts
fi
tar -zxmf /drsBT/lib/win_fonts.tar.gz -C "$fdir"

##import service for drsBT
echo "正在配置服务......"

systemctl enable solr
systemctl enable redis
systemctl enable rabbitmq-server
systemctl enable proftpd
systemctl enable oo
systemctl enable nginx
systemctl enable drs-admin
systemctl enable drs-api
systemctl enable drs-task
systemctl enable drs-dynamic

##config crontab
echo "10 1 * * * /drsBT/sh/catfish.sh /drsBT/log" >> /var/spool/cron/crontabs/root

st=`ifconfig |grep ether |head -1|awk '{print($2)}'`
os=`lsb_release -d|awk '{print $2,$3,$4}'`
echo ' '
echo '#####################################################'
echo '天舱资源云站安装完成!'
echo '本机系统为'$os',MAC为:'$st
echo '请将该MAC发至数联腾云申请许可证,并将申请后的许可文件'
echo '上传至以下目录/drsBT/drs/drs-api/lib/dat/'
echo '请重启系统并使用 http://ip:8088/访问资源站!'
echo '######################################################'
sleep 3
