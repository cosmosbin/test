#!/bin/bash

pg_pid="/drsBT/pgsql/data/postmaster.pid"
if [[ -n $1 ]]; then
        if [[ $1 = "start" ]]; then
        	if [[ -e $pg_pid ]]; then
        		/usr/bin/rm -rf $pg_pid
        	fi
            /bin/su postgres -c '/drsBT/pgsql/bin/pg_ctl -D /drsBT/pgsql/data/ start'
        elif [[ $1 = "stop" ]]; then
                /bin/su postgres -c '/drsBT/pgsql/bin/pg_ctl -D /drsBT/pgsql/data/ stop -m fast'
        else
                echo "please input 'start' or 'stop'!!"
        fi
else
        echo "please input a parameter,E.G ('*.sh start' or '*.sh stop')"
fi
