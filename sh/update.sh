#!/bin/bash

######################################################################################
# *修改适用于vue版本的更新（数据库、配置）                                               #
# *20210204 nginx配置采用etc/config下文件替换旧文件，并保留原有key配置信息;              #
#  删除drs-solr项目，改用drs-task项目.                                                 #
# *20210206截取变量db_name最右边空格后的所有字符，${db_name% *}                         #
#  保留NGINX原有端口、https配置                                                        #
# *20210219弃用drs-transcode项目，添加drs-dynamic项目                                  #
######################################################################################

#本地自动更新
#数据库更新角本必需放在/drsBT/etc/sql/下
#所有项目的配置文件必需以本地(localhost)方式配置,不能以IP或主机名方式连接.
#drs-web项目的/drsBT/drs/drs-web/drs-web/script/common.js文件如果有新更改必需手动替换.

exec 2>./update.log

if [[ -z $1 ]]; then
	echo "please input PKG,E.G (update.sh drsBT_update_20190606.tar.gz)"
	exit
fi
if [[ ! -e $1 ]]; then
	echo "the file no find."
	exit
fi

db_name=`sed -n '/localhost:5432/p' /drsBT/drs/drs-api/config/application-test.yml|head -1|awk -F '/' '{print($4)}'`
echo "现在开始备份数据,请稍候......"
ntime=`date +%Y%m%d%H%M%S`
#20210206截取变量db_name最右边空格后的所有字符，${db_name% *}
su postgres -c "/drsBT/pgsql/bin/pg_dump -O ${db_name%?} > /drsBT/pgsql/data/${db_name%?}_${ntime}.bak"
systemctl stop drs-admin
systemctl stop drs-api
systemctl stop drs-im
systemctl disable drs-im
systemctl mask drs-im
systemctl stop drs-solr
systemctl disable drs-solr
systemctl mask drs-solr
systemctl stop drs-task
systemctl stop drs-transcode
systemctl disable drs-transcode
systemctl mask drs-transcode
systemctl stop drs-dynamic
systemctl stop nginx
systemctl stop solr
systemctl start pgsql

#str_api=`grep "^var BASE_URL" /drsBT/drs/drs-web/drs-web/script/common.js`
#str_im=`grep "^var base_path" /drsBT/drs/drs-web/drs-web/script/common.js`
#str_im2=`grep "^var WebSocketPath" /drsBT/drs/drs-web/drs-web/script/common.js`

##如果是旧的common.js文件更改为新的WebSocketPath写法
#if [[ -z `echo $str_im2|grep ws` ]]; then
	#str_im2_end=`echo $str_im2|awk '{print $4}'`
	#str_im2="var WebSocketPath = 'ws://'+"$str_im2_end
#fi

##如果是旧common.js获取原有的API IM端口
#api_port="8885"
#im_port="8886"
#if [[ -z `grep "^var serverIp" /drsBT/drs/drs-web/drs-web/script/common.js` ]]; then
#	api_port=`sed -n '/^var BASE_URL/p' /drsBT/drs/drs-web/drs-web/script/common.js |awk 'BEGIN {FS=":"} {print $3}'|awk 'BEGIN {FS="/"} {print $1}'`
#	im_port=`sed -n '/^var base_path/p' /drsBT/drs/drs-web/drs-web/script/common.js|awk 'BEGIN {FS=":"} {print $3}'|awk 'BEGIN {FS="/"} {print $1}'`
#fi

echo "现在开始更新,请稍候......"
\cp -rf /drsBT/drs/drs-api/lib/dat ./
\cp -rf /drsBT/drs/drs-api/config/dat ./
\cp -rf /drsBT/etc/key ./
#\cp -rf /drsBT/drs/drs-web/drs-web/image/all-images/login.jpg ./
#\cp -rf /drsBT/drs/drs-web/drs-web/image/all-images/logo.png ./

#if [[ ! -e /drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar ]]; then
#	while [[ ! -e ./drs-base.tar.gz ]]; do
#		echo "版本太旧需要升级基础包,当前目录未找到基础包(drs-base.tar.gz),请上传后重试."
#		read
#	done
#	rm -rf /drsBT/drs/*
#	tar -zxmf ./drs-base.tar.gz -C /drsBT/
#fi

rm -rf /drsBT/etc/sql/*
rm -rf /drsBT/drs/drs-admin/drs-admin.jar
rm -rf /drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar
#rm -rf /drsBT/drs/drs-im/drs-im.jar
rm -rf /drsBT/drs/drs-task/drs-task.jar 
rm -rf /drsBT/drs/drs-transcode/drs-transcode.jar
rm -rf /drsBT/drs/drs-dynamic/drs-dynamic.jar
rm -rf /drsBT/drs/drs-web/drs-web
tar -zxmf $1 -C /

#证书文件改到drs-api/config下，删除drs-api/lib/dat
#if [[ -d "/drsBT/drs/drs-api/lib/dat"  ]]; then
#	rm -rf /drsBT/drs/drs-api/lib/dat
#fi
#rm -rf ./db_err.log
#for f in `ls /drsBT/etc/sql/`; do
#	echo '######begin '$f' update######' >> ./update.log
#	su postgres -c "/drsBT/pgsql/bin/psql -d drs-boot -f /drsBT/etc/sql/'$f'" 1>>./update.log 2>> ./update.log
#	echo '======end '$f' update======' >> ./update.log
#done

#api_num=`sed -n '/^var BASE_URL/=' /drsBT/drs/drs-web/drs-web/script/common.js`
#im_num=`sed -n '/^var base_path/=' /drsBT/drs/drs-web/drs-web/script/common.js`
#im2_num=`sed -n '/^var WebSocketPath/=' /drsBT/drs/drs-web/drs-web/script/common.js`
#sed -i "$api_num c $str_api" /drsBT/drs/drs-web/drs-web/script/common.js
#sed -i "$im_num c $str_im" /drsBT/drs/drs-web/drs-web/script/common.js
#sed -i "$im2_num c $str_im2" /drsBT/drs/drs-web/drs-web/script/common.js

##如果是旧的nginx配置使用新的配置文件
#if [[ -z `grep map /drsBT/nginx/conf/nginx.conf` ]]; then
#	\cp -rf /drsBT/etc/conf/nginx.conf /drsBT/nginx/conf/
	#api_num=`sed -n '/upstream drs-api/=' /drsBT/nginx/conf/nginx.conf`
	#let api_num=$api_num+1
	#sed -i "$api_num c server localhost:$api_port;" /drsBT/nginx/conf/nginx.conf
	#im_num=`sed -n '/upstream drs-im/=' /drsBT/nginx/conf/nginx.conf`
	#let im_num=$im_num+1
	#sed -i "$im_num c server localhost:$im_port;" /drsBT/nginx/conf/nginx.conf
#fi

##modify config for drsVUE
if [[ ${db_name%?}=='drs-vue' ]]; then
	sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-admin/config/application-test.yml
	sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-api/config/application-test.yml
	#sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-solr/config/application-test.yml
	sed -i 's/drs-boot/drs-vue/' /drsBT/drs/drs-transcode/config/application-test.yml
fi

rm -rf /drsBT/etc_mar
rm -rf /drsBT/lib_mar
rm -rf /drsBT/sh_mar

#旧的NGINX配置文件记录端口并替换成新配置文件.
#if [[ -z `grep "V20200514" /drsBT/nginx/conf/nginx.conf` ]]; then
	#old_port=`grep "mvport" /drsBT/nginx/conf/nginx.conf|awk '{print $3}'`
	#if [[ -z $old_port ]]; then
	#	old_port="8088"
	#fi
	#\cp -rf /drsBT/etc/conf/nginx.conf /drsBT/nginx/conf/
	#new_port=`grep "mvport" /drsBT/nginx/conf/nginx.conf|awk '{print $3}'`
	#sed -i "s/$new_port/$old_port/g" /drsBT/nginx/conf/nginx.conf
#fi

#20210204保留NGINX原有key配置信息
#20210206保留NGINX原有端口、https配置
default_port='8088'
ng_file='/drsBT/nginx/conf/nginx.conf'
ng_port=`grep "mvport" $ng_file |awk '{print($3)}'`
mvport=`sed -n "/mvport= ${ng_port}/p" $ng_file`
https=`sed -n "/listen.*${ng_port}.*ssl;/p" $ng_file|head -1`
http=`sed -n "/listen.*${ng_port};/p" $ng_file|head -1`
cer=`sed -n '/^[ \t]*ssl_certificate /p' $ng_file`
cer_key=`sed -n '/^[ \t]*ssl_certificate_key /p' $ng_file`
\cp /drsBT/etc/conf/nginx.conf $ng_file
mvport_num=`sed -n "/mvport= ${default_port}/=" $ng_file`
https_num=`sed -n "/listen.*${default_port}.*ssl;/=" $ng_file|head -1`
http_num=`sed -n "/listen.*${default_port};/=" $ng_file|head -1`
cer_num=`sed -n '/^[ \t]*ssl_certificate /=' $ng_file`
cer_key_num=`sed -n '/^[ \t]*ssl_certificate_key /=' $ng_file`
sed -i "${mvport_num}d" $ng_file
sed -i "${mvport_num}i ${mvport}" $ng_file
sed -i "${https_num}d" $ng_file
sed -i "${https_num}i ${https}" $ng_file
sed -i "${http_num}d" $ng_file
sed -i "${http_num}i ${http}" $ng_file
sed -i "${cer_num}d" $ng_file
sed -i "${cer_num}i ${cer}" $ng_file
sed -i "${cer_key_num}d" $ng_file
sed -i "${cer_key_num}i ${cer_key}" $ng_file


\cp -rf ./key /drsBT/etc/
rm -rf ./key
cp -rf ./dat /drsBT/drs/drs-api/lib/
rm -rf ./dat
#mv ./login.jpg /drsBT/drs/drs-web/drs-web/image/all-images/
#mv ./logo.png /drsBT/drs/drs-web/drs-web/image/all-images/

\cp /drsBT/etc/service/drs-* /usr/lib/systemd/system/
systemctl daemon-reload

echo "系统更新完成,正在重启服务,请稍候重试......"
systemctl start solr
systemctl start drs-admin
systemctl start drs-api
#systemctl start drs-im
systemctl start drs-task
systemctl start drs-dynamic
#systemctl start drs-transcode
systemctl start nginx