#!/bin/bash

#####################################################################
# * 20210129弃用原先的drs-solr项目，改用新的drs-task项目,修改日志输出格 #
#   分别存放于/drsBT/log/项目名/下                                    #
# * 20210205修改更改端口方法，不进行全局替换,只对mvport、http、https这3 #
#   条进行精准替换，防止出现替换掉其他端口。                            #
# * 20210219弃用drs-transcode项目，添加drs-dynamic项目                #
# * 20210402添加archive函数，增加日志归档功能.                         #
# * 20210420添加ubuntu系统crontab差异判断.                            #
#####################################################################

list_smf(){
	smf_state=`systemctl status $1 |grep Active|awk '{print($2,$3)}'`
	atv=`echo $smf_state|grep ^active`
	if [[ $atv = "" ]]; then
		smf_state="\033[7m"$smf_state"\033[0m"
	fi
	case "$1" in
	drs-admin )
		admin_port=`sed -n '/tomcat/,/port/p' /drsBT/drs/drs-admin/config/application-test.yml|grep port|awk '{print $2}'`
		if [[ -z $admin_port ]]; then
			mvport="8888"
		fi
		echo -e "  "0"  "drs-admin"       "$smf_state"  $admin_port";;
	drs-api )
		api_port=`sed -n '/tomcat/,/port/p' /drsBT/drs/drs-api/config/application-test.yml|grep port|awk '{print $2}'`
		if [[ -z $api_port ]]; then
			api_port="8885"
		fi
        echo -e "  "1"  "drs-api"       "$smf_state"  $api_port";;
	#drs-im )
	#	im_port=`sed -n '/tomcat/,/port/p' /drsBT/drs/drs-im/config/application-test.yml|grep port|awk '{print $2}'`
	#	if [[ -z $im_port ]]; then
	#		im_port="8886"
	#	fi
    #   echo -e "  "2"  "drs-im"       "$smf_state"  $im_port";;
	#drs-solr )
    #    echo -e "  "2"  "drs-solr"       "$smf_state"  8887";;
    
    drs-task )
        echo -e "  "2"  "drs-task"       "$smf_state"  8887";;
	drs-dynamic )
		echo -e "  "3"  "drs-dynamic"       "$smf_state"  8889";;
	pgsql )
		echo -e "  "4"  "pgsql"       "$smf_state"  5432";;
	nginx )
		ng_port=`grep "mvport" $ngcon |awk '{print($3)}'`
		if [[ -z $ng_port ]]; then
			ng_port="8088"
		fi
		echo -e "  "5"  "nginx"       "$smf_state"  $ng_port";;
	solr )
        echo -e "  "6"  "solr"       "$smf_state"  8983";;
	redis )
        echo -e "  "7"  "redis"       "$smf_state"  6379";;
	rabbitmq )
        echo -e "  "8"  "rabbitmq"       "$smf_state"  5672";;
    rabbitmq-server )
        echo -e "  "8"  "rabbitmq"       "$smf_state"  5672";;
    proftpd )
		pd_port=`grep "mvport" /drsBT/proftpd/etc/proftpd.conf |awk '{print($3)}'`
		if [[ -z $pd_port ]]; then
			pd_port="21"
		fi
		echo -e "  "9"  "proftpd"       "$smf_state"  $pd_port";;
    esac
}

mvport(){
	#ip=`sed -n '/^var BASE_URL/p' /drsBT/drs/drs-web/drs-web/script/common.js |awk 'BEGIN {FS=":"} {print substr($2,3)}'`

	#ssl_open=`sed -n '/<!-- https mode -->/p' /drsBT/tomcat8/drs-api/conf/server.xml`
	#if [[ -n $ssl_open ]]; then
	#	str_ssl="https"
	#else
	#	str_ssl="http"
	#fi

	#mode=`sed -n '/^var BASE_URL/p' /drsBT/drs/drs-web/drs-web/script/common.js |awk 'BEGIN {FS=":"} {print substr($1,15)}'`
	#api_num=`sed -n '/^var BASE_URL/=' /drsBT/drs/drs-web/drs-web/script/common.js`
	#im_num=`sed -n '/^var base_path/=' /drsBT/drs/drs-web/drs-web/script/common.js`
	#im2_num=`sed -n '/^var WebSocketPath/=' /drsBT/drs/drs-web/drs-web/script/common.js`
	clear
	echo "           修改服务端口     "
	echo "============================="
	echo "请输入$1服务新的端口号:"
	read port
	no_num=`echo "$port"|sed -n "/^[1-9][0-9]*$/p"`
	use_port=`netstat -an|grep "\<$port\>.*LISTEN"`
	pass="1"
	while [[ $pass = "1" ]]; do
		if [[ -z "$no_num" || -n "$use_port" ]]; then
			echo "端口不正确或已被占用,请重新输入."
			read port
			use_port=`netstat -an|grep "\<$port\>.*LISTEN"`
			no_num=`echo "$port"|sed -n "/^[1-9][0-9]*$/p"`
		else
			pass="0"
		fi
	done

	#pj_num=`sed -n "/upstream $1/=" /drsBT/nginx/conf/nginx.conf`
	#let pj_num=$pj_num+1

	case $1 in
	#	drs-admin )
	#		sed -i "s/$admin_port/$port/g" /drsBT/tomcat8/drs-admin/conf/server.xml
	#		sed -i "$pj_num c server localhost:$port;" /drsBT/nginx/conf/nginx.conf
	#		;;
	#	drs-api )
			#web_api_port=`grep "api_port" /drsBT/drs/drs-web/drs-web/script/common.js |awk '{print($3)}'`
	#		sed -i "s/$api_port/$port/g" /drsBT/tomcat8/drs-api/conf/server.xml
			#sed -i "$api_num c var BASE_URL='$str_ssl://$ip:$port/drs-api';" /drsBT/drs/drs-web/drs-web/script/common.js
	#		sed -i "$pj_num c server localhost:$port;" /drsBT/nginx/conf/nginx.conf
	#		;;
	#	drs-im )
			#web_im_port=`grep "im_port" /drsBT/drs/drs-web/drs-web/script/common.js |awk '{print($3)}'`
	#		sed -i "s/$im_port/$port/g" /drsBT/tomcat8/drs-im/conf/server.xml
			#sed -i "$im_num c var base_path = '$str_ssl://$ip:$port/drs-im';" /drsBT/drs/drs-web/drs-web/script/common.js
			#sed -i "$im2_num c var WebSocketPath = 'ws://'+'$ip:$port/drs-im';" /drsBT/drs/drs-web/drs-web/script/common.js
	#		sed -i "$pj_num c server localhost:$port;" /drsBT/nginx/conf/nginx.conf
	#		;;
			#sed -i "s/$web_im_port/$port/g" /drsBT/drs/drs-web/drs-web/script/common.js;;
		nginx )
			#sed -i "s/$ng_port/$port/g" /drsBT/nginx/conf/nginx.conf;;
			#20210205修改更改端口方法，不进行全局替换，只对mvport、http、https这3条进行精准替换，防止出现替换掉其他端口。
			sed -i "s/mvport=.*${ng_port}/mvport= ${port}/" $ngcon
			sed -i "s/listen.*${ng_port} ssl;/listen ${port} ssl;/" $ngcon
			sed -i "s/listen.*${ng_port};/listen       ${port};/" $ngcon;;
		proftpd )
			sed -i "s/$pd_port/$port/g" /drsBT/proftpd/etc/proftpd.conf;;
	esac
	echo "$1服务端口已修改为:$port,请重启服务,按任意键返回."
	read
	main_smf
}

archive(){
	path_WAL='/drsBT/ftp/WAL/'
	pg_conf="/drsBT/pgsql/data/postgresql.conf"
	pg_hba="/drsBT/pgsql/data/pg_hba.conf"
	save_week=`grep archive.sh $cron_path|awk '{print($7)}'`
	week_year="`date +%Y%V`"
	level_num=`sed -n '/wal_level = /=' $pg_conf`
	mode_num=`sed -n '/archive_mode = /=' $pg_conf`
	cmd_num=`sed -n '/archive_command = /=' $pg_conf`
	send_num=`sed -n '/max_wal_senders = /=' $pg_conf`
	repl_num=`sed -n '/local   replication/=' $pg_hba`

	clear
	echo "   名称       状 态       保留周数"
	echo "---------------------------------" 
	if [[ -z $save_week ]]; then
		echo " 日志归档       否        "
		echo "---------------------------------" 
		echo "0 开启归档 1 返回"
	else
		echo " 日志归档       是       $save_week"
		echo "---------------------------------" 
		echo "0 关闭归档 1 返回"
	fi
	read arch_status
	case $arch_status in
		0 )
			if [[ -z $save_week ]]; then
				echo "请输入归档保存周数："
				read weeks
				sed -i "$level_num d" $pg_conf
				sed -i "$level_num i wal_level = replica" $pg_conf
				sed -i "$mode_num d" $pg_conf
				sed -i "$mode_num i archive_mode = on" $pg_conf
				sed -i "$cmd_num d" $pg_conf
				#引用变量时有多个''""时最好使用""，""里有包含特殊字符的要使用\进行转义。
				sed -i "${cmd_num}i archive_command = 'mkdir -p /drsBT/ftp/WAL/\`date +%Y%V\`/ && tar -zcf /drsBT/ftp/WAL/\`date +%Y%V\`/%f.tar.gz %p'" $pg_conf
				sed -i "$send_num d" $pg_conf
				sed -i "$send_num i max_wal_senders = 2" $pg_conf
				sed -i "$repl_num d" $pg_hba
				sed -i "$repl_num i local   replication     postgres                                trust" $pg_hba
				echo "0 0 * * 1 /drsBT/sh/archive.sh $weeks" >> $cron_path		
				systemctl stop pgsql
				systemctl start pgsql
				mkdir -p ${path_WAL}${week_year}
        		chown -R postgres:postgres $path_WAL
        		#数据库未启动完成一直等待
        		while :
        		do
        			if [[ -f "/tmp/.s.PGSQL.5432.lock" ]]; then
        				sleep 3
        				su postgres -c "/drsBT/pgsql/bin/pg_basebackup -Ft -Pv -z -D ${path_WAL}${week_year}/base"
        				break
        			fi
        		done
        		
			else
				sed -i 's/archive_mode =/#archive_mode =/' $pg_conf
				sed -i '/archive.sh/d' $cron_path
				systemctl stop pgsql
				systemctl start pgsql
			fi
			;;
		1 )
			pass
			;;
	esac
	server_smf 4
}

server_smf(){
	trap "server_smf $1" INT
	clear
	#echo $1
	echo "序号  服务名          状 态             端口"
	echo "---------------------------------------------"
   	list_smf ${g_smf[$1]}
echo "---------------------------------------------"
if [[ ${g_smf[$1]} = 'pgsql' ]]; then
	echo "0 关闭服务 1 启动服务 2 查看项目日志 3 查看服务日志 4 日志归档 5 返回 6 退出"
else
	echo "0 关闭服务 1 启动服务 2 查看项目日志 3 查看服务日志 4 修改端口 5 返回 6 退出"
fi

read s_id
s_num=`echo $s_id|sed -n "/^[0-6]$/p"`
while [[ -z $s_num ]]; do
	echo "请输入正确选项."
	read s_id
	s_num=`echo $s_id|sed -n "/^[0-6]$/p"`
done
s_name=${g_smf[$1]}
case $s_id in
	0 )
		systemctl stop ${g_smf[$1]}
		main_smf;;
	1 )
		systemctl start ${g_smf[$1]}
		main_smf;;
	2 )
		if [[ $1 -le 4 ]]; then
			#捕获CTL+C信号,并执行""中的命令
			#trap "server_smf $1" INT
			slog="/drsBT/log/"$s_name"/debug.log"
			tail -f $slog
		elif [[ $1 -eq 6 ]]; then
			#trap "server_smf $1" INT
			tail -f /drsBT/log/nginx/access.log
		else
			echo "暂时不提供该服务的项目日志,按任意键返回......"
			read tmp
			server_smf $1
		fi;;
	3 )
		#trap "server_smf $1" INT
		systemctl status -l $s_name;;
	4 )
		if [[ $1 = "5" || $1 = "9" ]]; then
			mvport $s_name
		elif [[ $1 = "4" ]]; then
			archive
		else
			echo "暂时不提供该服务的端口修改,按任意键返回......"
			read 
			server_smf $1
		fi
		;;
	5 )
		main_smf;;
	6 )
		clear
		exit 0;;
esac
}

main_smf(){
	clear
    echo "序号  服务名          状 态                  端口"
    echo "--------------------------------------------------"
    for i in ${g_smf[*]}; do
    	list_smf $i
    done
    echo "--------------------------------------------------"
    echo "选择服务序号进入服务管理(s HTTPS配置 r 刷新 q 退出)"
    read smf_id
    num=`echo $smf_id|sed -n "/^[0-9]$/p"`
    #只有输入值为0-9时num为0-9,否则为空.
    #echo $smf_id====$num
    while [[ $smf_id != "q" && $smf_id != "10" && $smf_id != "$num" && $smf_id != "r" && $smf_id != "s" ]]; do
		echo "请输入正确选项."
		read smf_id
		num=`echo $smf_id|sed -n "/^[0-9]$/p"`
    done
    if [[ $smf_id = "q" ]]; then
    	clear
    	exit
    elif [[ $smf_id = "r" ]]; then
    	main_smf
    #elif [[ $smf_id = "i" ]]; then
    #	/drsBT/sh/mvip.sh
    #    main_smf
    elif [[ $smf_id = "s" ]]; then
    	/drsBT/sh/mvssl.sh
        main_smf
    else
    	server_smf $smf_id
	fi
}

#exec 2>/drsBT/log/drs_err.log

os=`grep Ubuntu /proc/version`
if [[ $os != '' ]]; then
    rabbitmq='rabbitmq-server'
    ngcon='/etc/nginx/nginx.conf'
    cron_path=/var/spool/cron/crontabs/root
else
	rabbitmq='rabbitmq'
	ngcon='/drsBT/nginx/conf/nginx.conf'
	cron_path='/var/spool/cron/root'
fi

g_smf=(drs-admin drs-api drs-task drs-dynamic pgsql nginx solr redis $rabbitmq proftpd)
main_smf
