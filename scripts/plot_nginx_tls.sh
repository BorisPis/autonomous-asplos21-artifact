#!/bin/bash
ARG=$1

[ -z $ARG ] && echo missing results directory argument && exit -1;

cd $TBASE/TestSuite/Tests/nginx
envsubst < nginx.conf | tee nginx.conf
envsubst < nginx_dbg.conf | tee nginx_dbg.conf
./plot.sh $ARG
gnuplot nginx3b_tls.gp
cp nginx3b_tls.eps $TBASE/Figures/nginx3b_tls.eps
cd -
