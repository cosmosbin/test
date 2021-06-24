#!/bin/bash

#$1 http模式,$2 api端口,$3 im端口,无参任何参数 手动修改所有项.


exec 2>./mvip_err.log

mvip(){
		sed -i "$api_num c var BASE_URL='$mode://$ip:$api_port/drs-api';" /drsBT/drs/drs-web/drs-web/script/common.js
		sed -i "$im_num c var base_path = '$mode://$ip:$im_port/drs-im';" /drsBT/drs/drs-web/drs-web/script/common.js
		sed -i "$im2_num c var WebSocketPath = 'ws://'+'$ip:$im_port/drs-im';" /drsBT/drs/drs-web/drs-web/script/common.js
}

clear
api_num=`sed -n '/^var BASE_URL/=' /drsBT/drs/drs-web/drs-web/script/common.js`
im_num=`sed -n '/^var base_path/=' /drsBT/drs/drs-web/drs-web/script/common.js`
im2_num=`sed -n '/^var WebSocketPath/=' /drsBT/drs/drs-web/drs-web/script/common.js`
ip=`sed -n '/^var BASE_URL/p' /drsBT/drs/drs-web/drs-web/script/common.js |awk 'BEGIN {FS=":"} {print substr($2,3)}'`

if [[ -z $1 ]]; then
	aip=(`ifconfig |grep netmask|awk '{print($2)}'`)
	n=0
	for i in ${aip[*]}; do
		echo $n" "$i
		let n++
	done
	echo "请选择访问资源站的IP项;或输入自定义IP或域名;q退出."
	read sip

	if [[ $sip = "q" || -z $sip ]]; then
		echo "没有选择任何有效选项,请后续单独执行mvip.sh配置.按任意键退出."
		read
		exit
	fi
	isnum=`echo "$sip"|sed -n "/^[0-9][0-9]*$/p"`
	if [ $sip -ge 0 -a $sip -lt $n ]; then
		ip=${aip[$sip]}
	else
		ip=$sip
	fi

	#echo "请输入http或https服务模式(默认http):"
	#read mode
	#if [[ -z $mode ]]; then
	#	mode="http"
	#fi

	ssl_open=`sed -n '/<!-- https mode -->/p' /drsBT/tomcat8/drs-api/conf/server.xml`
	if [[ -n $ssl_open ]]; then
		mode="https"
	else
		mode="http"
	fi

	#echo "请输入api端口号(默认8885):"
	#read api_port
	#if [[ -z $api_port ]]; then
	#	api_port="8885"
	#fi	

	api_port=`grep "mvport" /drsBT/tomcat8/drs-api/conf/server.xml |awk '{print($3)}'`

	#echo "请输入im端口号(默认8886):"
	#read im_port
	#if [[ -z $im_port ]]; then
	#	im_port="8886"
	#fi
	im_port=`grep "mvport" /drsBT/tomcat8/drs-im/conf/server.xml |awk '{print($3)}'`
	mvip
	echo "资源站访问WEB配置修改成功,请重启服务后重试!按任意键退出."
	read
else
	mode=$1
	
	if [[ -n $2 ]]; then
		api_port=$2
	else
		api_port=`grep "mvport" /drsBT/tomcat8/drs-api/conf/server.xml |awk '{print($3)}'`
	fi

	if [[ -n $3 ]]; then
		im_port=$3
	else
		im_port=`grep "mvport" /drsBT/tomcat8/drs-im/conf/server.xml |awk '{print($3)}'`
	fi
	mvip
fi








