#!/usr/bin/bash

{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}
export ODBCINI=./odbc.ini

hostname

this_script=$BASH_SOURCE
this_script=`readlink -f $this_script`
this_dir=`dirname $this_script`
echo rsyncing from $this_dir
echo running: $this_script $*

lfn=${10}

source /opt/sphenix/core/bin/sphenix_setup.sh -n $8

cups.py -t production_status -r $2 -s $3 --dstname=DST_CALOR_auau23_${8/./}_${9} started

if [[ ! -z "$_CONDOR_SCRATCH_DIR" && -d $_CONDOR_SCRATCH_DIR ]]
then
    cd $_CONDOR_SCRATCH_DIR
    rsync -av $this_dir/* .
    getinputfiles.pl ${lfn}
    if [ $? -ne 0 ]
    then
	echo error from getinputfiles.pl $lfn, exiting
	exit -1
    fi
else
    echo condor scratch NOT set
    exit 1
fi
# arguments 
# $1: number of events
# $2: run number
# $3: sequence
# $4: lfn
# $5: raw data dir
# $6: output file
# $7: output dir
# $8: build tag
# $9: cdb tag

#echo 'here comes your environment'
#printenv
echo arg1 \(events\) : $1
echo arg2 \(runnumber\): $2
echo arg3 \(sequence\): $3
echo arg4 \(database source\): $4
echo arg5 \(raw data dir\): ${5}
echo arg6 \(output file\): $6
echo arg7 \(output dir\): $7
echo arg8 \(build tag\): $8
echo arg9 \(cdb tag\): $9
echo arg10 \(inputs\): ${10}

ls -la

echo running root.exe -q -b Fun4All_Year1.C\($1,\"${lfn}\",\"$6\",\"$7\",\"$9\"\) 

cups.py -t production_status -r $2 -s $3 --dstname=DST_CALOR_auau23_${8/./}_${9} running
root.exe -q -b  Fun4All_Year1.C\($1,\"$lfn\",\"$6\",\"$7\",\"$9\"\) | pull.py  

cups.py -t production_status -r $2 -s $3 --dstname=DST_CALOR_auau23_${8/./}_${9} exitcode --exit $?



# "$(name)_$(build)_$(tag)-$INT(run,%08d)-$INT(seg,%04d).out,$(name)_$(build)_$(tag)-$INT(run,%08d)-$INT(seg,%04d).err"
runnumber=$(printf "%08d" $2)
sequence=$(printf "%04d" $3)
logbase=DST_CALOR_auau23_${8/./}_${9}-${runnumber}-${sequence}

echo $runnumber
echo $sequence
echo $logbase

#cat stdout.log

build=${8/./}
dbtag=${9}

cat <<EOF > qatest.json
{
  "workflow" : "calorimeter ",
  "build"    : "${build}",
  "tag"      : "${dbtag}"
}
EOF

#./cups.py -r ${2} -s ${3} -d DST_CALOR_auau23_${build}_${dbtag} quality --qafile qatest.json

cp stdout.log ${logbase}.out
cp stderr.log ${logbase}.err

ls -la

} >stdout.log 2>stderr.log

echo "script done"
