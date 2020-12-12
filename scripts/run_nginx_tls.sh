#!/bin/bash

source parameters.sh
cd $TBASE/TestSuite/Tests/nginx/
envsubst < nginx.conf | tee nginx.conf
envsubst < nginx_dbg.conf | tee nginx_dbg.conf
cd -
$TBASE/TestSuite/Tests/nginx/run_nginx_tls.sh
