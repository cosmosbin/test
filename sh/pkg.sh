#!/bin/bash

#项目更新自动打包
#更新包命名样式: drsBT_update_20190606.tar.gz

exec 2>./pkg_err.log

ndate=`date +%Y%m%d`
g_path="./drsBT"
pkg_path="$g_path/drs"
mkdir -p "$pkg_path"/drs-admin
mkdir -p "$pkg_path"/drs-api
#mkdir -p "$pkg_path"/drs-im
mkdir -p "$pkg_path"/drs-solr
mkdir -p "$pkg_path"/drs-transcode
mkdir -p "$pkg_path"/drs-web

echo "正在备份项目文件,请稍候......"
\cp -rf /drsBT/drs/drs-admin/drs-admin.jar $pkg_path/drs-admin/
\cp -rf /drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar "$pkg_path"/drs-api/
#\cp -rf /drsBT/drs/drs-api/lib "$pkg_path"/drs-api/
#\cp -rf /drsBT/drs/drs-im/drs-im.jar "$pkg_path"/drs-im/
\cp -rf /drsBT/drs/drs-solr/drs-solr.jar "$pkg_path"/drs-solr/
\cp -rf /drsBT/drs/drs-transcode/drs-transcode.jar "$pkg_path"/drs-transcode/
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

#rm -rf "$pkg_path"/drs-admin/WEB-INF/classes/application*
#rm -rf "$pkg_path"/drs-api/WEB-INF/classes/application* 
#rm -rf "$pkg_path"/drs-im/WEB-INF/classes/application* 
#rm -rf "$pkg_path"/drs-solr/WEB-INF/classes/application* 
#rm -rf "$pkg_path"/drs-transcode/WEB-INF/classes/application* 
#rm -rf "$pkg_path"/drs-admin/*.war  
#rm -rf "$pkg_path"/drs-api/*.war  
#rm -rf "$pkg_path"/drs-im/*.war  
#rm -rf "$pkg_path"/drs-solr/*.war  
#rm -rf "$pkg_path"/drs-transcode/*.war  
#rm -rf "$pkg_path"/drs-api/WEB-INF/classes/dat/*  
#rm -rf "$pkg_path"/drs-web/drs-web/script/common.js
rm -rf "$pkg_path"/drs-web/drs-web/image/all-images/login.jpg 
rm -rf "$pkg_path"/drs-web/drs-web/image/all-images/logo.png 

echo "正在打包项目文件,请稍候......"
if [[ -e ./drsBT_update_"$ndate".tar.gz ]]; then
	rm -rf ./drsBT_update_"$ndate".tar.gz
fi
tar -zcf drsBT_update_"$ndate".tar.gz "$g_path"
rm -rf "$g_path"