#!/bin/bash

exec 2>./uninstall.log

echo "警告:卸载程序将删除资源站所有服务及用户数据,确定要卸载资源站?(y/n)"
read warning
if [[ $warning != "y" ]]; then
	echo "已退出卸载......"
	exit
fi

systemctl stop drs-admin
systemctl stop drs-api
systemctl stop drs-task
systemctl stop drs-dynamic
systemctl stop pgsql
systemctl stop nginx
systemctl stop solr
systemctl stop redis
systemctl stop rabbitmq
systemctl stop proftpd
systemctl stop oo

pid=(`ps -ef |grep "drsBT"|grep -v grep|awk '{print($2)}'`)
		for (( i = 0; i < ${#pid[*]}; i++ )); do
			kill -9 ${pid[$i]}
			#echo ${pid[$i]}" killed!!"
		done

systemctl disable drs-admin
systemctl disable drs-api
systemctl disable drs-task
systemctl disable drs-dynamic
systemctl disable pgsql
systemctl disable nginx
systemctl disable solr
systemctl disable redis
systemctl disable rabbitmq
systemctl disable proftpd
systemctl disable oo

sed -i '/drsBT/d' /etc/ld.so.conf
sed -i '/drsBT/d' /var/spool/cron/root

#rm -rf /usr/bin/erl
rm -rf /drsBT
userdel postgres