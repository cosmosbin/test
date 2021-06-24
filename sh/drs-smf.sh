#!/bin/bash

if [[ -n $1 && -n $2 ]]; then
	java="/drsBT/jdk1.8/bin/java"
	drs_path="/drsBT/drs/"$2
	if [[ $1 = "start" ]]; then
		cd "$drs_path"
		if [[ $2 = "drs-api" ]]; then
			"$java" -D"$2" -Xms4096m -Xmx4096m -Dloader.path="$drs_path"/lib,"$drs_path"/config -Xnoclassgc -XX:+DisableExplicitGC -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xloggc:/drsBT/log/"$2"/gc.log -jar "$drs_path"/"$2".jar >> /dev/null &
		else
			"$java" -D"$2" -Xms512m -Xmx512m -Dloader.path="$drs_path"/lib,"$drs_path"/config -Xnoclassgc -XX:+DisableExplicitGC -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xloggc:/drsBT/log/"$2"/gc.log -jar "$drs_path"/"$2".jar >> /dev/null &
		fi	
	elif [[ $1 = "stop" ]]; then
		pid=(`ps -ef |grep ".*-D$2"|grep -v grep|awk '{print($2)}'`)
		for (( i = 0; i < ${#pid[*]}; i++ )); do
			kill -9 ${pid[$i]}
			echo ${pid[$i]}" killed!!"
		done
		exit 0
	else
		echo "please input 'start' or 'stop'!!"
	fi
else
	echo "please input a parameter,E.G ('drs-smf.sh start drs-admin' or 'drs-smf.sh stop drs-admin')"
fi
