#!/bin/bash
ARG=$1

[ -z $ARG ] && echo missing results directory argument && exit -1;

cd $TBASE/TestSuite/Tests/ssl/iperf_tx
./plot.sh $ARG
gnuplot breakdown.gp
cp breakdown.eps $TBASE/Figures/iperf_breakdown.eps
cd -
