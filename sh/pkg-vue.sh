#!/bin/bash

#####################################################################
# * VUE项目更新自动打包                                              #
# * 更新包命名样式: drsVUE_update_20190606.tar.gz                    #
# * 20210129弃用原先的drs-solr项目，改用新的drs-task项目              #
#   将修改过的/drsBT/solr/bin/solr文件打包                           #
# * 20210219弃用drs-transcode项目，添加drs-dynamic项目，弃用solr的    #
#   drs-file库，drs-api2-0.0.1-SNAPSHOT.jar改为drs-api.jar          #
#####################################################################

exec 2>./pkg_err.log

ndate=`date +%Y%m%d`
g_path="./drsBT"
pkg_path="$g_path/drs"
pkg_name="./drsVUE_update_"$ndate".tar.gz"
mkdir -p "$pkg_path"/drs-admin
mkdir -p "$pkg_path"/drs-api
mkdir -p "$pkg_path"/drs-task
mkdir -p "$pkg_path"/drs-dynamic
#mkdir -p "$pkg_path"/drs-transcode
mkdir -p "$pkg_path"/drs-web

echo "正在备份项目文件,请稍候......"
\cp -rf /drsBT/drs/drs-admin/drs-admin.jar $pkg_path/drs-admin/
\cp -rf /drsBT/drs/drs-admin/config $pkg_path/drs-admin/
\cp -rf /drsBT/drs/drs-api/drs-api.jar "$pkg_path"/drs-api/
\cp -rf /drsBT/drs/drs-api/config "$pkg_path"/drs-api/
#\cp -rf /drsBT/drs/drs-task/* "$pkg_path"/drs-task/
\cp -rf /drsBT/drs/drs-task/drs-task.jar "$pkg_path"/drs-task/
\cp -rf /drsBT/drs/drs-task/config "$pkg_path"/drs-task/
\cp -rf /drsBT/drs/drs-dynamic/drs-dynamic.jar "$pkg_path"/drs-dynamic/
\cp -rf /drsBT/drs/drs-dynamic/config "$pkg_path"/drs-dynamic/
#\cp -rf /drsBT/drs/drs-transcode/drs-transcode.jar "$pkg_path"/drs-transcode/
#\cp -rf /drsBT/drs/drs-transcode/config "$pkg_path"/drs-transcode/
\cp -rf /drsBT/drs/drs-web/drs-web "$pkg_path"/drs-web/
\cp -rf /drsBT/etc "$g_path"
\cp -rf /drsBT/etc_mar "$g_path"
\cp -rf /drsBT/lib "$g_path"
\cp -rf /drsBT/lib_mar "$g_path"
\cp -rf /drsBT/sh "$g_path"
\cp -rf /drsBT/sh_mar "$g_path"
sed -i 's/postgres/drs/g' "$g_path"/etc/sql/*
sed -i '1i\set client_encoding=gbk;' "$g_path"/etc/sql/*
sed -i 's/postgres/drs/g' "$g_path"/etc_mar/sql/*
sed -i '1i\set client_encoding=gbk;' "$g_path"/etc_mar/sql/*
#创建更新包标记文件，用于drsVUE_centos8_install.sh中检查$1是否为更新包。
touch "$g_path"/etc/conf/update_pkg_sign

#20201209添加solr相关配置到更新包。 --path参数在目标路径下创建源目录并复制
\cp -rf --path /drsBT/solr/server/solr/drs-personal/conf/managed-schema ./
\cp -rf --path /drsBT/solr/server/solr/drs-group/conf/managed-schema ./
\cp -rf --path /drsBT/solr/server/solr/drs-public/conf/managed-schema ./
#\cp -rf --path /drsBT/solr/server/solr/drs-file/conf/managed-schema ./
#20210129修改solr相关内容以适应新solr项目需要
\cp -rf --path /drsBT/solr/bin/solr ./
#\cp -rf --path /drsBT/drs/drs-api/lib/logback.xml ./
#\cp -rf --path /drsBT/drs/drs-admin/lib/logback.xml ./
#\cp -rf --path /drsBT/drs/drs-task/lib/logback.xml ./
#\cp -rf --path /drsBT/drs/drs-transcode/lib/logback.xml ./
#20201231添加新增的lib库文件
\cp -rf --path /drsBT/drs/drs-api/lib/drs-spring-boot-starter-1.0.0.jar ./

echo "正在打包项目文件,请稍候......"
if [[ -e $pkg_name ]]; then
	rm -rf $pkg_name
fi
tar -zcf $pkg_name "$g_path"
rm -rf "$g_path"

echo $pkg_name > /dev/null >> md5
md5sum $pkg_name |awk '{print($1)}' >> md5