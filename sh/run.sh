#!/bin/bash
exec 1>./run.log 2>>./run.log

./drsBT_centos7_ENV.sh ./drsBT_update_20200327.tar.gz

\cp -rf ./*.dat /drsBT/drs/drs-api/lib/dat/