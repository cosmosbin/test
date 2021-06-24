#!/bin/bash

npath=$(cd `dirname $0`;pwd)
exec 2>>$npath'/err.log'
echo "正在解压安装包......"
tar -zxmf $npath'/drsBT_centos7_ins.tar.gz' -C /
#npath=$npath'/tool/'

echo "正在安装系统环境......"
##instll postgresql 9.4
cp -rf /drsBT/lib/libossp-uuid.so.16 /usr/lib64/
adduser postgres
echo 'ABC!@#123' | passwd --stdin postgres
chown -R postgres:postgres /drsBT/pgsql/data


##install ffmpeg
sdl="/lib64/libSDL-1.2.so.0"
if [[ ! -e $sdl ]]; then
	\cp -rvf /drsBT/lib/libSDL-1.2.so.0 /usr/lib64/
fi

echo '/drsBT/ffmpeg/lib/' >> /etc/ld.so.conf
echo '/drsBT/x264/lib/' >> /etc/ld.so.conf
ldconfig

##install libreoffice
\cp -rvf /drsBT/lib/lib_oo/* /usr/lib64/

##install rabbitmq
ln -s /drsBT/erlang/lib/erlang/bin/erl /usr/bin/erl
pto="/lib64/libcrypto.so.1.0.2k"
if [[ ! -e $pto ]]; then
	rpm -ivh /drsBT/lib/openssl-libs-1.0.2k-16.el7.x86_64.rpm --force
fi

##import windows fonts
fdir="/usr/share/fonts"
if [[ ! -d $fdir ]]; then
	mkdir -p /usr/share/fonts
fi
tar -zmxf /drsBT/lib/win_fonts.tar.gz -C "$fdir"

##import service for drsBT
cp -rf /drsBT/etc/service/* /usr/lib/systemd/system/
systemctl enable pgsql
systemctl enable solr
systemctl enable redis
systemctl enable rabbitmq
systemctl enable proftpd
systemctl enable oo
systemctl enable nginx
systemctl enable drs-admin
systemctl enable drs-api
systemctl enable drs-im
systemctl enable drs-solr
systemctl enable drs-transcode

##config crontab
echo "33 1 * * * /drsBT/sh/catfish.sh /drsBT/log" >> /var/spool/cron/root

##mody web ip####
/drsBT/sh/mvip.sh

st=`ifconfig |grep ether |head -1|awk '{print($2)}'`
echo ' '
echo '#####################################################'
echo '火星舱资源站安装完成!'
echo '本机系统为CENTOS7,MAC为:'$st
echo '请将该MAC发至火星高科申请许可证,并将申请后的许可文件'
echo '上传至以下目录/drsBT/drs/drs-api/WEB-INF/classes/dat/'
echo '请重启系统并使用 http://ip:8088/drs-web/ 访问资源站!'
echo '######################################################'
sleep 3
