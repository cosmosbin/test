#!/bin/bash

function getallfile(){
		for f1 in `ls $1`; do
			all_path=$1"/"$f1
			if [[ -d $all_path ]]; then
				getallfile $all_path
			else					
				d=`date -r $all_path +%Y%m%d`
				n=`date +%Y%m%d -d -1days` #保留天数
				t=`date +%Y%m%d`
				if [[ $d -eq $t ]]; then  #清空当天文件
					cat /dev/null > $all_path
					#echo "$d==$t"$all_path
				fi
				if [[ $d -lt $n ]]; then #删除大于保留天数的文件
					rm -rf $all_path
					#echo "$d<<$n"$all_path
				fi
				#if [[ $d -gt $n ]]; then  
					#echo "$d>>$n"$all_path
				#	rm -rf $all_path
				#fi
			fi
		done
}

if [ -n $1 -a -d $1 ]; then
	getallfile $1
else
	echo "please input a path."
fi