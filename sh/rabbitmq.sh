#!/bin/bash

export HOME=/drsBT/rabbitmq/
if [[ -n $1 ]]; then
        if [[ $1 = "start" ]]; then
                /drsBT/rabbitmq/sbin/rabbitmq-server
        elif [[ $1 = "stop" ]]; then
                pid=(`ps -ef |grep erlang|grep -v grep|awk '{print($2)}'`)
                for (( i = 0; i < ${#pid[*]}; i++ )); do
                        kill -9 ${pid[$i]}
                        echo ${pid[$i]}" killed!!"
                done
        else
                echo "please input 'start' or 'stop'!!"
        fi
else
        echo "please input a parameter,E.G ('*.sh start' or '*.sh stop')"
fi
