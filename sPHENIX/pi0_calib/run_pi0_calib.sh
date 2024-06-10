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
logdir=${12}

# run_pi0_calib.sh 0 42101 42103 42103 0 HST_CALO_PI0CALIB_run2pp_new_2024p001-00042101-00042103-42103-00 HST_CALO_PI0CALIB_run2pp_new_2024p001 /sphenix/data/data02/sphnxpro/calocalib/pi0hist new 2024p001 /sphenix/data/data02/sphnxpro/temp/CDB_PI0CALIB_run2pp-00042101-00042400-0000.root,/sphenix/lustre01/sphnxpro/physics/slurp/caloy2test/run_00042100_00042200/DST_CALO_run2pp_new_2024p001-00042101-0000.root,/sphenix/lustre01/sphnxpro/physics/slurp/caloy2test/run_00042100_00042200/DST_CALO_run2pp_new_2024p001-00042101-0001.root,/sphenix/lustre01/sphnxpro/physics/slurp/caloy2test/run_00042100_00042200/DST_CALO_run2pp_new_2024p001-00042101-0002.root,/sphenix/lustre01/sphnxpro/physics/slurp/caloy2test/run_00042100_00042200/DST_CALO_run2pp_new_2024p001-00042101-0003.root,/sphenix/lustre01/sphnxpro/physics/slurp/caloy2test/run_00042100_00042200/DST_CALO_run2pp_new_2024p001-00042101-0004.root file:///sphenix/data/data02/sphnxpro/calocalib/pi0logs


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
echo ${logdir}

# Add towers to the input list
for i in ${inputs[@]}; do
    if [[ $i =~ "DST_" ]]; then
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
echo ./cups.py -r ${runnumber} -s ${segment} -d PI0_CALIB --dstfile ${logbase} started 
     ./cups.py -r ${runnumber} -s ${segment} -d PI0_CALIB --dstfile ${logbase} started 

echo root.exe -q -b Fun4All_EMCal\(100,\"inputs.list\",${iteration},\"${LOCAL_CALIBRATION_FILE}\"\)
     root.exe -q -b Fun4All_EMCal\(100,\"inputs.list\",${iteration},\"${LOCAL_CALIBRATION_FILE}\"\)
#

#ls > ${outbase}-${runnumber}-${segment}.root
#ls > ${logbase}.root
# ./stageout.sh ${logbase}.root ${outdir}/

ls -la 
sleep 120

echo ./cups.py -r ${runnumber} -s ${segment} -d none --dstfile ${logbase} finished -e 0 
     ./cups.py -r ${runnumber} -s ${segment} -d none --dstfile ${logbase} finished -e 0 

cat inputs.list > ${logbase}.root
echo $LOCAL_CALIBRATION_FILE >> ${logbase}.root

./stageout.sh ${logbase}.root ${outdir}

} > ${logbase}.out 2> ${logbase}.err

mv ${logbase}.out ${logdir#file:/}
mv ${logbase}.err ${logdir#file:/}



