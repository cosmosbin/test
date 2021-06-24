#!/bin/bash

######################################################################################
# * postgresql日志自动归档,按周进行归档,周一全备后续增量,归档目录名202109(年周)           #
#   $1保存周数                                                                        #
######################################################################################

exec 2>./archive_err.log

if [[ -z $1 ]]; then
        echo "please input save weeks,E.G (archive.sh 2)"
        exit
fi

path_WAL='/drsBT/ftp/WAL/'
week_day=`date +%w`
week_year=`date +%Y%V`

if [[ $week_day = '1' ]]; then
        mkdir -p ${path_WAL}${week_year}
        chown -R postgres:postgres $path_WAL
        su postgres -c "/drsBT/pgsql/bin/pg_basebackup -Ft -Pv -z -D ${path_WAL}${week_year}/base"
fi

wal_temp='/drsBT/ftp/wal_temp'
let week_save=$week_year-$1+1
for (( i = 0; i < $1; i++ )); do
        mkdir -p $wal_temp
        let week_temp=$week_year-$i
        mv ${path_WAL}$week_temp $wal_temp/
done
rm -rf ${path_WAL}*
mv $wal_temp/* ${path_WAL}
rm -rf $wal_temp
