#!/bin/bash

#################################################################################
# * 20210203将原来的drs-solr项目替换成新项目drs-task，修改对应服务名;               #
#   证书文件改到drs-api/config下，删除drs-api/lib/dat                             #
# * 20210219弃用drs-transcode项目，添加drs-dynamic项目                            #
# * 证书文件重新改回到drs-api/lib下，注释掉删除drs-api/lib/dat代码.                #
# * 20210326弃用原有pg_dump工具数据备份模式，后续将改为日志归档备份模式.             #
#################################################################################

if [[ -z $1 ]]; then
	echo "please input PKG,E.G (drsBT_centos7_ENV.sh drsBT_update_20190606.tar.gz)"
	exit
fi
if [[ ! -e $1 ]]; then
	echo "'"$1"', the file no find."
	exit
fi
npath=$(cd `dirname $0`;pwd)
exec 2>>$npath'/err.log'
echo "正在安装系统环境......"
if [[ $2 == 'vue' ]]; then
	env_pak='/drsVUE_centos7_ENV.tar.gz'
	base_pak='./drsVUE-base.tar.gz'
	db='drs-vue'
else
	env_pak='/drsBT_centos7_ENV.tar.gz'
	base_pak='./drs-base.tar.gz'
	db='drs-boot'
fi

tar -zxmf $npath'/drsBT_centos7_ENV.tar.gz' -C /
\cp -rf /drsBT/etc/service/* /usr/lib/systemd/system/
##instll postgresql 9.4
adduser -M postgres
#echo 'ABC!@#123' | passwd --stdin postgres 1>/dev/null
chown -R postgres:postgres /drsBT/pgsql/data
systemctl start pgsql
systemctl enable pgsql
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
#\cp -rf /drsBT/etc/image/* /drsBT/drs/drs-web/drs-web/image/all-images/
\cp -rf /drsBT/etc/conf/nginx.conf /drsBT/nginx/conf/
mkdir -p /drsBT/ftp/trans_file/trans_file
\cp -rf /drsBT/etc/service/* /usr/lib/systemd/system/
#npath=$npath'/tool/'

#pgsql uuid lib
\cp -rfn /drsBT/lib/libossp-uuid.so.16 /usr/lib64/

##install ffmpeg
sdl="/lib64/libSDL-1.2.so.0"
if [[ ! -e $sdl ]]; then
	\cp -rfn /drsBT/lib/libSDL-1.2.so.0 /usr/lib64/
fi
if [[ ! -e /lib64/libxcb-shape.so.0 ]]; then
	\cp -rfn /drsBT/lib/libxcb-shape.so.0 /usr/lib64/	
fi

echo '/drsBT/ffmpeg/lib/' >> /etc/ld.so.conf
echo '/drsBT/x264/lib/' >> /etc/ld.so.conf
ldconfig

##install libreoffice
\cp -rfn /drsBT/lib/lib_oo/* /usr/lib64/

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
tar -zxmf /drsBT/lib/win_fonts.tar.gz -C "$fdir"

##import lib of config info.
\cp -rfn /drsBT/lib/libsigar* /usr/lib64/

##modify config for drsVUE
if [[ $2 == 'vue' ]]; then
	sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-admin/config/application-test.yml
	sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-api/config/application-test.yml
	#sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-solr/config/application-test.yml
	sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-transcode/config/application-test.yml
fi

#证书文件改到drs-api/config下，删除drs-api/lib/dat
#if [[ -d "/drsBT/drs/drs-api/lib/dat"  ]]; then
#	rm -rf /drsBT/drs/drs-api/lib/dat
#fi

##import service for drsBT
echo "正在配置服务......"

systemctl enable solr
systemctl enable redis
systemctl enable rabbitmq
systemctl enable proftpd
systemctl enable oo
systemctl enable nginx
systemctl enable drs-admin
systemctl enable drs-api
#systemctl enable drs-im
systemctl enable drs-task
#systemctl enable drs-transcode
systemctl enable drs-dynamic

##update database
#systemctl start pgsql
#sleep 10
rm -rf ./db_err.log
for f in `ls /drsBT/etc/sql/`; do
	echo '######begin '$f' update######' >> ./db_err.log
	if [[ $2 != 'vue' ]]; then
		su postgres -c "/drsBT/pgsql/bin/psql -d '$db' -f /drsBT/etc/sql/'$f'" 1>/dev/null 2>> ./db_err.log
	fi
	echo '======end '$f' update======' >> ./db_err.log
done
##config crontab
echo "10 1 * * * /drsBT/sh/catfish.sh /drsBT/log" >> /var/spool/cron/root
#20210326弃用原有pg_dump工具数据备份模式
#echo "30 1 * * * /drsBT/sh/pgbk.sh /drsBT/bak/ 3" >> /var/spool/cron/root

##mody web ip####
#/drsBT/sh/mvip.sh
ifconfig 1>/dev/null 2>/dev/null
no_ifcn=`echo $?`
if [[ "$no_ifcn" != "0" ]]; then
	rpm -i --nodeps /drsBT/lib/net-tools-2.0-0.24.20131004git.el7.x86_64.rpm
fi
st=`ifconfig |grep ether |head -1|awk '{print($2)}'`
echo ' '
echo '#####################################################'
echo '天舱资源云站安装完成!'
echo '本机系统为CENTOS7,MAC为:'$st
echo '请将该MAC发至数联腾云申请许可证,并将申请后的许可文件'
echo '上传至以下目录/drsBT/drs/drs-api/lib/dat/'
echo '请重启系统并使用 http://ip:8088/访问资源站!'
echo '######################################################'
sleep 3
