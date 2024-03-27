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
    # TPC files
    if [[ $b =~ "TPC_ebdc" ]]; then
       l=${b%%_cosmics*}  # handle either cosmic events or calibrations
       l=${l%%_calib*}
       echo ${f} >> ${l/TPC_ebdc/tpc}.list
       echo Add ${f} to ${l/TPC_ebdc/tpc}.list
       inputlist="${f} ${inputlist}"
    fi
    # TPOT files
    if [[ $b =~ "TPOT_ebdc" ]]; then
       echo ${f} >> tpot.list 
       echo Add ${f} to tpot.list
       inputlist="${f} ${inputlist}"
    fi
    if [[ $b =~ "GL1_cosmics" ]]; then
       echo ${f} >> gl1.list
       echo Add ${f} to gl1.list
       inputlist="${f} ${inputlist}"
    fi
    if [[ $b =~ "cosmics_intt" ]]; then
       l=${b#*cosmics_}
       l=${l%%-}
       echo ${f} >> ${l}.list
       echo Add ${f} to ${l}.list
       inputlist="${f} ${inputlist}"
    fi
    if [[ $b =~ "cosmics_mvtx" ]]; then
       l=${b#*cosmics_}
       l=${l%%-}
       echo ${f} >> ${l}.list
       echo Add ${f} to ${l}.list
       inputlist="${f} ${inputlist}"
    fi
    
done

./cups.py -r ${runnumber} -s ${segment} -d ${outbase} inputs --files ${inputlist}
#______________________________________________________________________________________________

touch gl1.list
touch intt0.list
touch intt1.list
touch intt2.list
touch intt3.list
touch intt4.list
touch intt5.list
touch intt6.list
touch intt7.list
touch mvtx0.list
touch mvtx1.list
touch mvtx2.list
touch mvtx3.list
touch mvtx4.list
touch mvtx5.list
touch tpot.list

ls -la *.list

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

