#!/usr/bin/bash

nevents=${1}
outbase=${2}
logbase=${3}
runnumber=${4}
segment=${5}
outdir=${6}
build=${7/./}
dbtag=${8}
inputs=(`echo ${9} | tr "," " "`)  # array of input files 
ranges=(`echo ${10} | tr "," " "`)  # array of input files with ranges appended
neventsper=${11:-1000}
{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${5}

export ODBCINI=./odbc.ini
 
echo ${inputs[@]}

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started

#______________________________________________________________________________________________
# Map TPC input files into filelists
# TPC_ebdc23_cosmics-00030117-0009.evt test%%_cosmics*
inputlist=""
for f in "${inputs[@]}"; do
    b=$( basename $f )
    l=${b%%_cosmics*}  # handle either cosmic events or calibrations
    l=${l%%_calib*}
    echo ${f} >> ${l/TPC_ebdc/tpc}.list
    inputlist="${f} ${inputlist}"
done

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} inputs --files ${inputlist}
#______________________________________________________________________________________________

touch gl1.list
touch intt[0-7].list
touch mvtx[0-5].list
touch tpot.list


ls *.list

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} running

echo root.exe -q -b Fun4All_Stream_Combiner.C\(${nevents},${runnumber},\"${outbase}\",\"${outdir}\",${neventsper}\);
     root.exe -q -b Fun4All_Stream_Combiner.C\(${nevents},${runnumber},\"${outbase}\",\"${outdir}\",${neventsper}\); status_f4a=$?

ls -la 

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} exitcode -e ${status_f4a}

#???outputname="cosmics-${runnumber}-${segment}";

echo $outbase
echo $logbase

#cp stderr.log ${logbase}.err
#cp stdout.log ${logbase}.out

ls -la

echo "script done"
} > ${logbase}.out 2>${logbase}.err 

