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
logdir=${11:-.}
{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}
hostname

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${7}

export ODBCINI=./odbc.ini

#______________________________________________________________________________________ started __
#
./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started
#_________________________________________________________________________________________________

echo ..............................................................................................
echo $@
echo .............................................................................................. 
echo nevents: $nevents
echo outbase: $outbase
echo logbase: $logbase
echo runnumb: $runnumber
echo segment: $segment
echo outdir:  $outdir
echo build:   $build
echo dbtag:   $dbtag
echo inputs:  ${inputs[@]}

echo .............................................................................................. 

ls ${inputs[@]} # there should be only one here... 

echo root.exe -q -b Fun4All_TrkrHitSet_Unpacker.C\(${nevents},${runnumber},\"${logbase}.root\",\"${dbtag}\",\"${inputs[0]}\",\"\"\)
     root.exe -q -b Fun4All_TrkrHitSet_Unpacker.C\(${nevents},${runnumber},\"${logbase}.root\",\"${dbtag}\",\"${inputs[0]}\",\"\"\)

ls -la

./stageout.sh ${logbase}.root ${outdir}

ls -la

echo "bdee bdee bdee, That's All Folks!"

}  > ${logbase}.out 2>${logbase}.err

mv ${logbase}.out ${logdir#file:/}
mv ${logbase}.err ${logdir#file:/}


