#!/usr/bin/bash -f

echo $@

nevents=${1}
runnumber=${2}
segment=${3}
outbase=${4}
logbase=${5}
outdir=${6}
build=${7/./}
dbtag=${8}
inputs=(`echo ${9} | tr "," " "`)  # array of input files 
{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${5}

export ODBCINI=./odbc.ini
 
echo nevents ${1}
echo runnumber ${2}
echo segment ${3}
echo outbase ${4}
echo logbase ${5}
echo outdir ${6}
echo build ${7/./}
echo dbtag ${8}

sleep 60

ls > ${outbase}-${runnumber}-${segment}.root

ls -la

#./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started

} > stdout.log 2> stderr.log
#> ${logbase}.out 2>${logbase}.err 

