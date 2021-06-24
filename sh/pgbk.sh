#!/bin/bash

exec 2>./pgbk_err.log

db_name=`sed -n '/localhost:5432/p' /drsBT/drs/drs-api/config/application-test.yml|head -1|awk -F '/' '{print($4)}'`
if [[ -z $1 || -z $2 ]]; then
	echo "please input directory and save days,E.G (pgbk.sh /drsBT/bak/ 3 )"
	exit
fi
if [[ ! -d $1 ]]; then
	mkdir -p $1
	#echo "the directory cannot find."
	#exit
fi
chown -R postgres:postgres "$1"
time=`date +%Y%m%d%H%M%S`
##${db_name%?}获取到除最后一个字符的值，从文件中查询出来的结果一行的最后有一个回车制表符，
##这个会在变量拼接过程中断，无法拼接出完整变量值，只有去掉这个回车制表符才能得到完整值。
bk_cmd="/drsBT/pgsql/bin/pg_dump -O ${db_name%?} -f ${1}/${db_name%?}_${time}.bak"
/bin/su postgres -c "${bk_cmd}"

#if [[ $db_name=='drs-vue' ]]; then
#	/bin/su postgres -c "/drsBT/pgsql/bin/pg_dump -O drs-vue -f '$1''/drs-vue_''$time'.bak"
#else
#	/bin/su postgres -c "/drsBT/pgsql/bin/pg_dump -O drs-boot -f '$1''/drs-boot_''$time'.bak"
#fi

for f in `ls "$1"`; do
	save_days=`date +%Y%m%d -d -"$2"days`
	file_days=`date -r "$1""/""$f" +%Y%m%d`
	if [[ "$file_days" -lt "$save_days" ]]; then
		rm -rf "$1""/""$f"
	fi
done