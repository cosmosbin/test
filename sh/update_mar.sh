#!/bin/bash

exec 2>./update_err.log

if [[ -z $1 ]]; then
	echo "please input PKG,E.G (update.sh drsBT_update_20190606.tar.gz)"
	exit
fi
if [[ ! -e $1 ]]; then
	echo "the file no find."
	exit
fi

echo "正在备份数据库,请稍候......"
ntime=`/usr/gnu/bin/date +%Y%m%d%H%M%S`
su postgres -c "/SYSVOL/NAS/drsBT/pgsql/bin/pg_dump -O drs-boot > /SYSVOL/NAS/drsBT/pgsql/data/drs-boot_'$ntime'.bak"
svcadm disable drs-admin
svcadm disable drs-api
if [[ -n `svcs |grep drs-im` ]]; then
	svcadm disable drs-im
	svccfg delete drs-im
fi
svcadm disable drs-solr
svcadm disable drs-transcode
svcadm disable server/nginx
sleep 20

#str_api=`grep "^var BASE_URL" /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js`
#str_im=`grep "^var base_path" /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js`
#str_im2=`grep "^var WebSocketPath" /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js`
##如果是旧的common.js文件更改为新的WebSocketPath写法
#if [[ -z `echo $str_im2|grep ws` ]]; then
#	str_im2_end=`echo $str_im2|awk '{print $4}'`
#	str_im2="var WebSocketPath = 'ws://'+"$str_im2_end
#fi


echo "现在开始更新......"
cp -rf /SYSVOL/NAS/drsBT/drs/drs-api/WEB-INF/classes/dat ./
cp -rf /SYSVOL/NAS/drsBT/drs/drs-api/lib/dat ./
cp -rf /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/image/all-images/login.jpg ./
cp -rf /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/image/all-images/logo.png ./

if [[ ! -e /SYSVOL/NAS/drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar ]]; then
	while [[ ! -e ./drs-base.tar.gz ]]; do
		echo "版本太旧需要升级基础包,当前目录未找到基础包(drs-base.tar.gz),请上传后重试."
		read
	done
	rm -rf /SYSVOL/NAS/drsBT/drs/*
	tar -zxmf ./drs-base.tar.gz -C /SYSVOL/NAS/drsBT/
fi

rm -rf /SYSVOL/NAS/drsBT/etc/sql/*

rm -rf /SYSVOL/NAS/drsBT/drs/drs-admin/drs-admin.jar
rm -rf /SYSVOL/NAS/drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar
#rm -rf /SYSVOL/NAS/drsBT/drs/drs-api/lib
#rm -rf /SYSVOL/NAS/drsBT/drs/drs-im/drs-im.jar
rm -rf /SYSVOL/NAS/drsBT/drs/drs-solr/drs-solr.jar 
rm -rf /SYSVOL/NAS/drsBT/drs/drs-transcode/drs-transcode.jar
rm -rf /SYSVOL/NAS/drsBT/drs/drs-web/drs-web

tar -zxf $1 -C /SYSVOL/NAS/
#cp -rf /SYSVOL/NAS/drsBT/etc/drs/* /SYSVOL/NAS/drsBT/drs/

/usr/gnu/bin/sed -i 's/drsBT/SYSVOL\/NAS\/drsBT/' /SYSVOL/NAS/drsBT/drs/drs-admin/config/application.yml
/usr/gnu/bin/sed -i 's/drsBT/SYSVOL\/NAS\/drsBT/' /SYSVOL/NAS/drsBT/drs/drs-api/config/application.yml
/usr/gnu/bin/sed -i 's/drsBT/SYSVOL\/NAS\/drsBT/' /SYSVOL/NAS/drsBT/drs/drs-api/config/application-test.yml
/usr/gnu/bin/sed -i 's/drsBT/SYSVOL\/NAS\/drsBT/' /SYSVOL/NAS/drsBT/drs/drs-solr/config/application.yml
/usr/gnu/bin/sed -i 's/drsBT/SYSVOL\/NAS\/drsBT/' /SYSVOL/NAS/drsBT/drs/drs-transcode/config/application.yml

rm -rf ./db_err.log
for f in `ls /SYSVOL/NAS/drsBT/etc/sql/`; do
	su postgres -c "/SYSVOL/NAS/drsBT/pgsql/bin/psql -d drs-boot -f /SYSVOL/NAS/drsBT/etc/sql/'$f'" 1>./db_out.log 2> ./db_err.log
done

#api_num=`/usr/gnu/bin/sed -n '/^var BASE_URL/=' /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js`
#im_num=`/usr/gnu/bin/sed -n '/^var base_path/=' /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js`
#im2_num=`/usr/gnu/bin/sed -n '/^var WebSocketPath/=' /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js`
#/usr/gnu/bin/sed -i "$api_num c $str_api" /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js
#/usr/gnu/bin/sed -i "$im_num c $str_im" /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js
#/usr/gnu/bin/sed -i "$im2_num c $str_im2" /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/script/common.js

cp -rf /SYSVOL/NAS/drsBT/etc_mar/* /SYSVOL/NAS/drsBT/etc/
cp -rf /SYSVOL/NAS/drsBT/lib_mar/* /SYSVOL/NAS/drsBT/lib/
cp -rf /SYSVOL/NAS/drsBT/sh_mar/* /SYSVOL/NAS/drsBT/sh/
rm -rf /SYSVOL/NAS/drsBT/etc_mar
rm -rf /SYSVOL/NAS/drsBT/lib_mar
rm -rf /SYSVOL/NAS/drsBT/sh_mar

##如果是旧的nginx配置使用新的配置文件
#if [[ -z `grep "V20190813" /SYSVOL/NAS/drsBT/nginx/conf/nginx.conf` ]]; then
#	old_port=`grep "mvport" /SYSVOL/NAS/drsBT/nginx/conf/nginx.conf|awk '{print $3}'`
#	\cp -rf /SYSVOL/NAS/drsBT/etc/conf/nginx.conf /SYSVOL/NAS/drsBT/nginx/conf/
#	new_port=`grep "mvport" /SYSVOL/NAS/drsBT/nginx/conf/nginx.conf|awk '{print $3}'`
#	/usr/gnu/bin/sed -i "s/$new_port/$old_port/g" /SYSVOL/NAS/drsBT/nginx/conf/nginx.conf
#fi

cp -rf ./dat /SYSVOL/NAS/drsBT/drs/drs-api/lib/
#rm -rf ./dat
mv ./login.jpg /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/image/all-images/
mv ./logo.png /SYSVOL/NAS/drsBT/drs/drs-web/drs-web/image/all-images/

echo "系统更新完成,正在重启服务,请稍候重试......"
svcadm enable drs-admin
svcadm enable drs-api
#svcadm enable drs-im
svcadm enable drs-solr
svcadm enable drs-transcode
svcadm enable server/nginx


