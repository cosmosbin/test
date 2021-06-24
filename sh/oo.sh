#!/bin/bash

os=`grep Ubuntu /proc/version`
if [[ $os != '' ]]; then
    soffice=`which soffice`
else
    system_ver=`cat /etc/redhat-release |awk '{print($4)}'`
    if [[ $system_ver > 8 ]]; then
        soffice='/opt/libreoffice5.2/program/soffice'
    else
        soffice='/drsBT/libreoffice5.1/program/soffice'
    fi
fi

if [[ -n $1 ]]; then
        if [[ $1 = "start" ]]; then
                $soffice "--accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager" --nologo --headless --nofirststartwizard &
        elif [[ $1 = "stop" ]]; then
                pid=(`ps -ef |grep office|grep -v grep|awk '{print($2)}'`)
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
