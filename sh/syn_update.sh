#!/bin/bash

#远程更新
#必需安装sshpass工具(yum install sshpass)
#首次运行更新主机与远程更新机必需通过信任许可,请执行scp及ssh命令信任远程更新机.
#pkg.sh update.sh update_mar.sh syn_update.sh三个文件必需放在同一路径下.
#如果主机与远程更新机日期不一致将导致更新包无法找到.

exec 2>./syn_update_err.log

login(){
	login=`echo $?`
	if [[ $login != "0" ]]; then
		case $login in
		5 )
			echo "用户名或密码错误!"
			exit;;
		6 )
			echo "请先信任远程主机的ECDSA key(执行$1 xxx.xxx.xxx.xxx 选择yes)."
			exit;;
		255 )
			echo "无法连接远程主机."
			exit;;
		* )
			echo "未知异常退出,请重试!"
			exit;;
		esac
	fi
}

rm -rf ./*.log
if [[ -z $1 || -z $2 ]]; then
	echo "please input IP and PWD,E.G (syn_update.sh 192.168.10.58 123)"
	exit
fi

##判断ssh及scp完全可用,否则中断执行.
if [[ -z $3 ]]; then
	port="22"
else
	port=$3
fi
sshpass -p "$2" ssh -p "$port" root@"$1" "uname" 1>/dev/null
login

os=`sshpass -p "$2" ssh -p "$port" root@"$1" "uname"`
ndate=`date +%Y%m%d`

./pkg.sh

echo "正在复制更新包到远程主机,请稍候......"
sshpass -p "$2" scp -P "$port" ./drsBT_update_"$ndate".tar.gz "$1":/root/
if [[ $os = "SunOS" ]]; then
	sshpass -p "$2" scp -P "$port" ./update_mar.sh "$1":/root/update.sh
	api_jar="/SYSVOL/NAS/drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar"
else
	sshpass -p "$2" scp -P "$port" ./update.sh "$1":/root/
	api_jar="/drsBT/drs/drs-api/drs-api2-0.0.1-SNAPSHOT.jar"
fi


if [[ ! -e "$api_jar" ]]; then
	sshpass -p "$2" scp -P "$port" ./drs-base.tar.gz "$1":/root/
fi

sshpass -p "$2" ssh -p "$port" root@"$1" "chmod 700 /root/update.sh"
#sshpass -p "$2" ssh root@"$1" "cd /root"
sshpass -p "$2" ssh -p "$port" root@"$1" "/root/update.sh /root/drsBT_update_'$ndate'.tar.gz"
sshpass -p "$2" ssh -p "$port" root@"$1" "rm -rf /root/drsBT_update_'$ndate'.tar.gz"
sshpass -p "$2" ssh -p "$port" root@"$1" "rm -rf /root/update.sh"
sshpass -p "$2" ssh -p "$port" root@"$1" "rm -rf /root/drs-base.tar.gz"
sshpass -p "$2" ssh -p "$port" root@"$1" "cat /root/update_err.log" > ./update_err.log
sshpass -p "$2" ssh -p "$port" root@"$1" "cat /root/db_err.log" > ./db_err.log