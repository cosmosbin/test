#!/bin/bash

exec 2>./mvip_err.log

clear
aip=(`ifconfig |grep netmask|awk '{print($2)}'`)
n=0
for i in ${aip[*]}; do
	echo $n" "$i
	let n++
done
echo "请选择访问资源站的IP项;或输入自定义IP或域名;q退出."
read sip
if [[ $sip = "q" ]]; then
	echo "没有选择任何有效选项,请后续单独执行mvip.sh配置.按任意键退出."
	read
	exit
fi

if [[ -n $1 ]]; then
	cp /drsBT/etc/conf/common_https.js ./common.js
else
	cp /drsBT/etc/conf/common_http.js ./common.js
fi

isnum=`echo "$sip"|sed -n "/^[0-9][0-9]*$/p"`
if [[ -n $isnum ]]; then
	if [ $sip -ge 0 -a $sip -lt $n ]; then
		sed -i "s/mvip/${aip[$sip]}/g" ./common.js
		eip=${aip[$sip]}
	else
		sed -i "s/mvip/$sip/g" ./common.js
		eip=$sip
	fi
else
	sed -i "s/mvip/$sip/g" ./common.js
	eip=$sip	
fi
cp -rf ./common.js /drsBT/drs/drs-web/drs-web/script/
rm -rf ./common.js
if [[ -n $1 ]]; then
	echo "资源站访问IP修改成功,重启后请使用https://$eip:8088/drs-web/访问!按任意键退出."
else
	echo "资源站访问IP修改成功,重启后请使用http://$eip:8088/drs-web/访问!按任意键退出."
fi

read



