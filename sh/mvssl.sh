#!/bin/bash

exec 2>./mvssl_err.log

mvts(){
	
	if [[ $s = "https" && -z $ssl_open ]]; then
		sed -i 's/<!-- http mode -->/<!-- http mode/' /drsBT/tomcat8/drs-"$1"/conf/server.xml
		sed -i 's/<!-- http end-->/http end-->/' /drsBT/tomcat8/drs-"$1"/conf/server.xml
		sed -i 's/<!-- https mode/<!-- https mode -->/' /drsBT/tomcat8/drs-"$1"/conf/server.xml
		sed -i 's/https end-->/<!-- https end-->/' /drsBT/tomcat8/drs-"$1"/conf/server.xml
		
		sed -i 's/#*[ \t]*ssl on;/ssl on;/' $ngcon
		sed -i 's/#*[ \t]*ssl_certificate \/drsBT\/etc\/key\/nginx\/nginx.crt;/ssl_certificate \/drsBT\/etc\/key\/nginx\/nginx.crt;/' $ngcon 
		sed -i 's/#*[ \t]*ssl_certificate_key \/drsBT\/etc\/key\/nginx\/nginx.key;/ssl_certificate_key \/drsBT\/etc\/key\/nginx\/nginx.key;/' $ngcon
		sed -i 's/http:\/\/drs-admin/https:\/\/drs-admin/' $ngcon
		sed -i 's/http:\/\/drs-api/https:\/\/drs-api/' $ngcon
		sed -i 's/http:\/\/drs-im/https:\/\/drs-im/' $ngcon
		sed -i 's/ws:\/\//wss:\/\//' /drsBT/drs/drs-web/drs-web/script/common.js
	fi
	if [[ $s = "http" && -n $ssl_open ]]; then
		sed -i 's/<!-- http mode/<!-- http mode -->/' /drsBT/tomcat8/drs-"$1"/conf/server.xml    
		sed -i 's/http end-->/<!-- http end-->/' /drsBT/tomcat8/drs-"$1"/conf/server.xml     
		sed -i 's/<!-- https mode -->/<!-- https mode/' /drsBT/tomcat8/drs-"$1"/conf/server.xml    
		sed -i 's/<!-- https end-->/https end-->/' /drsBT/tomcat8/drs-"$1"/conf/server.xml
		
		sed -i 's/ *ssl on;/#ssl on;/' $ngcon
		sed -i 's/ *ssl_certificate \/drsBT\/etc\/key\/nginx\/nginx.crt;/#ssl_certificate \/drsBT\/etc\/key\/nginx\/nginx.crt;/' $ngcon 
		sed -i 's/ *ssl_certificate_key \/drsBT\/etc\/key\/nginx\/nginx.key;/#ssl_certificate_key \/drsBT\/etc\/key\/nginx\/nginx.key;/' $ngcon
		sed -i 's/https:\/\/drs-admin/http:\/\/drs-admin/' $ngcon
		sed -i 's/https:\/\/drs-api/http:\/\/drs-api/' $ngcon
		sed -i 's/https:\/\/drs-im/http:\/\/drs-im/' $ngcon
		sed -i 's/wss:\/\//ws:\/\//' /drsBT/drs/drs-web/drs-web/script/common.js
	fi	
}

mvssl(){
		ng_port=`grep "mvport" $ngcon |awk '{print($3)}'`
		case $h in
			0 )
				s="https";;
			1 )
				s="http";;
		esac

		if [[ $str_ssl = $s ]]; then
			echo "当前已经是$str_ssl模式了,按任意键退出......"
			read
			exit
		fi
		
		echo "正在切换模式,请稍候......"
		#systemctl stop drs-admin
		#systemctl stop drs-api
		#systemctl stop drs-im
		systemctl stop nginx
		if [[ $s = "https" ]]; then
			sed -i "s/^#listen.*ssl;/listen ${ng_port} ssl;/" $ngcon
			sed -i "s/listen.*${ng_port};/#listen    ${ng_port};/" $ngcon
			#sed -i 's/#.*ssl on;/ssl on;/' $ngcon
			#sed -i 's/ws:\/\//wss:\/\//' /drsBT/drs/drs-web/drs-web/script/common.js
		else
			sed -i "s/^listen.*ssl;/#listen ${ng_port} ssl;/" $ngcon
			sed -i "s/#listen.*${ng_port};/listen    ${ng_port};/" $ngcon
			#sed -i 's/.*ssl on;/#ssl on;/' $ngcon
			#sed -i 's/wss:\/\//ws:\/\//' /drsBT/drs/drs-web/drs-web/script/common.js
		fi


		#mvts admin
		#mvts api
		#mvts im		
		#/drsBT/sh/mvip.sh "$s"
		
		#systemctl start drs-admin
		#systemctl start drs-api
		#systemctl start drs-im
		systemctl start nginx

		echo "已切换到$s模式,正在重启服务,请稍候重试......"
		sleep 3
		exit
}
#ssl_open=`sed -n '/<!-- https mode -->/p' /drsBT/tomcat8/drs-api/conf/server.xml`
#ssl_open=`sed -n '/#.*ssl on;/p' $ngcon`

os=`grep Ubuntu /proc/version`
if [[ $os != '' ]]; then
    ngcon='/etc/nginx/nginx.conf'
else
	ngcon='/drsBT/nginx/conf/nginx.conf'
fi

ssl_open=`sed -n '/^#listen.*ssl;/p' $ngcon`
clear
if [[ -z $ssl_open ]]; then
	echo "当前模式为 https "
	str_ssl="https"
else
	echo "当前模式为 http"
	str_ssl="http"
fi

echo "############# https与http模式切换 ##############"
echo "# 0 切换到 https 模式                          #"
echo "# 1 切换到 http 模式                           #"
echo "# q 退出                                       #"
echo "################################################"

read h
while [[ $h != "0" && $h != "1" && $h != "q" ]]; do
	echo "请输入正确选项!"
	read h
done

if [[ $h = "q" ]]; then
	exit
fi
mvssl