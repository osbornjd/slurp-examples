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
logdir=${12}
histdir=${13:-/dev/null}
{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}

source /opt/sphenix/core/bin/sphenix_setup.sh -n ${7}

export ODBCINI=./odbc.ini

# Set state to started
./cups.py -r ${runnumber} -s ${segment} -d ${outbase} started

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
echo nper:    $neventsper
echo logdir:  $logdir
echo histdir: $histdir
echo .............................................................................................. 

inputlist=""
for f in "${inputs[@]}"; do
    echo "File $f"
    b=$( basename $f )
    if [[ $b =~ "GL1_cosmics" ]]; then
       echo ${f} >> gl1daq.list
       echo Add ${f} to gl1daq.list
       inputlist="${f} ${inputlist}"
    fi
    if [[ $b =~ "GL1_physics" ]]; then
       echo ${f} >> gl1daq.list
       echo Add ${f} to gl1daq.list
       inputlist="${f} ${inputlist}"
    fi
    if [[ $b =~ "GL1_beam" ]]; then
       echo ${f} >> gl1daq.list
       echo Add ${f} to gl1daq.list
       inputlist="${f} ${inputlist}"
    fi
    if [[ $b =~ "GL1_calib" ]]; then
       echo ${f} >> gl1daq.list
       echo Add ${f} to gl1daq.list
       inputlist="${f} ${inputlist}"
    fi
    
    if [[ $b =~ seb(00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20) ]]; then
       nn=${BASH_REMATCH[1]}
       echo ${f} >> seb${nn}.list
       echo Add ${f} to seb${nn}.list
       inputlist="${f} ${inputlist}"
    fi
done

# Register the input list and set state to running
./cups.py -r ${runnumber} -s ${segment} -d ${outbase} inputs --files ${inputlist}
./cups.py -r ${runnumber} -s ${segment} -d ${outbase} running

#echo "ls -l *.list"
#ls -l *.list

echo root.exe -q -b Fun4All_Prdf_Combiner.C\(${nevents},\"${ouddir}\",\"${outbase}\",${neventsper}\)
     root.exe -q -b Fun4All_Prdf_Combiner.C\(${nevents},\"${outdir}\",\"${outbase}\",${neventsper}\); status_f4a=$?


# Flag run as finished.  Increment nevents by zero
echo ./cups.py -v -r ${runnumber} -s ${segment} -d ${outbase} finished -e ${status_f4a} --nevents 0 --inc 
     ./cups.py -v -r ${runnumber} -s ${segment} -d ${outbase} finished -e ${status_f4a} --nevents 0 --inc 

echo "script done"
} >${logbase}.out 2>${logbase}.err

# Direct stageout
mv ${logbase}.out ${logdir#file:/}
mv ${logbase}.err ${logdir#file:/}

# Write only first 25MB to output logfiles
#dd if=stdout.log of=${logbase}.out seek=1 bs=25M
#dd if=stderr.log of=${logbase}.err seek=1 bs=25M

