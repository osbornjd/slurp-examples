#!/usr/bin/bash -f

echo $@

nevents=${1}
runnumber=${2}
lastrun=${3}
segment=${4}
iteration=${5}
outbase=${7}
logbase=${6}
outdir=${8}
build=${9/./}
dbtag=${10}
inputs=(`echo ${11} | tr "," " "`)  # array of input files 
{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${5}

export ODBCINI=./odbc.ini
 
echo $nevents
echo $runnumber
echo $lastrun
echo $segment
echo $iteration
echo $outbase
echo $logbase
echo $outdir
echo $build
echo $dbtag
echo ${inputs[@]}  # array of input files 

# Add towers to the input list
for i in ${inputs[@]}; do
    if [[ $i =~ "DST_TRIGG" ]]; then
	echo $i >> inputs.list
	echo Add $i to inputs.list
    fi
    if [[ $i =~ "CDB_" ]]; then
	echo Local calibration file = $i
	LOCAL_CALIBRATION_FILE=$i
    fi
done

outputfilename=${logbase}.root

#./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started
echo ./cups.py -r ${runnumber} -s ${segment} -d PI0_CALIB --dstfile ${logbase} started --nsegments ${iteration}
     ./cups.py -r ${runnumber} -s ${segment} -d PI0_CALIB --dstfile ${logbase} started --nsegments ${iteration}

echo root.exe -q -b Fun4All_EMCal\(0,\"inputs.list\",${iteratopn},\"${LOCAL_CALIBRATION_FILE}\"\)
     root.exe -q -b Fun4All_EMCal\(0,\"inputs.list\",${iteratopn},\"${LOCAL_CALIBRATION_FILE}\"\)


#ls > ${outbase}-${runnumber}-${segment}.root
#ls > ${logbase}.root
# ./stageout.sh ${logbase}.root ${outdir}/

ls -la 

echo ./cups.py -r ${runnumber} -s ${segment} -d none --dstfile ${logbase} finished -e 0 --nsegments ${iteration}
     ./cups.py -r ${runnumber} -s ${segment} -d none --dstfile ${logbase} finished -e 0 --nsegments ${iteration}

touch ${logbase}.err

} >& ${logbase}.out 
#2>${logbase}.err 


