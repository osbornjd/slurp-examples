#!/usr/bin/bash

{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${5}

export ODBCINI=./odbc.ini
 
neventsper=100  # number of events per output file
nevents=${1}
outbase=${2}
logbase=${3}
runnumber=${4}
segment=${5}
outdir=${6}
build=${7/./}
dbtag=${8}
inputs=(`echo ${9} | tr "," " "`)  # array of input files 

echo ${inputs[@]}

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started

#______________________________________________________________________________________________
# Map input files into filelists
# TPC_ebdc23_cosmics-00030117-0009.evt test%%_cosmics*
inputlist=""
for f in "${inputs[@]}"; do
    b=$( basename $f )
    l=${b%%_cosmics*}
    echo ${f} >> ${l/TPC_ebdc/tpc}.list
    inputlist="${f} ${inputlist}"
done

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} inputs --files ${inputlist}
#______________________________________________________________________________________________

ls *.list

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} running

echo root.exe -q -b Fun4All_Stream_Combiner.C\(${nevents},${runnumber},\"${outbase}\",\"${outdir}\",${neventsper}\);
     root.exe -q -b Fun4All_Stream_Combiner.C\(${nevents},${runnumber},\"${outbase}\",\"${outdir}\",${neventsper}\); status_f4a=$?

ls -la 

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} exitcode -e ${status_f4a}

outputname="cosmics-${runnumber}-${segment}";

echo $outbase
echo $logbase

cp stderr.log ${logbase}.err
cp stdout.log ${logbase}.out

ls -la

echo "script done"
} > stdout.log 2>stderr.log







