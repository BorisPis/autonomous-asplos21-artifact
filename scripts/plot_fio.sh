#!/bin/bash
ARG=$1

[ -z $ARG ] && echo missing results directory argument && exit -1;

cd $TBASE/TestSuite/Tests/fio
./plot5.sh $ARG
gnuplot breakdown.gp
cp breakdown.eps $TBASE/Figures/fio_breakdown.eps
cd -
