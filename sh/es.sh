#!/bin/bash


export JAVA_HOME=/drsBT/jdk1.8/
export JRE_HOME=$JAVA_HOME/jre
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib

if [[ -n $1 ]]; then
        if [[ $1 = "start" ]]; then

                /bin/su es -c '/drsBT/es661/bin/elasticsearch'
        elif [[ $1 = "stop" ]]; then
                pid=(`ps -ef |grep elasticsearch|grep -v grep|awk '{print($2)}'`)
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
