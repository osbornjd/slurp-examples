#!/usr/bin/bash

{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}
hostname

#this_script=$BASH_SOURCE
#this_script=`readlink -f $this_script`
#this_dir=`dirname $this_script`
#echo rsyncing from $this_dir
#echo running: $this_script $*

# This is actually going to be a pfn...
lfn=${10}

echo source /opt/sphenix/core/bin/sphenix_setup.sh -n ${8}
source /opt/sphenix/core/bin/sphenix_setup.sh -n ${8}

export ODBCINI=./odbc.ini

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

#$$$ls -la

outputfile=${6}
dstfile=${6%.*}
dstname=${dstfile%%-*}



echo cups.py -v -t production_status -r $2 -s $3 --dstname=${dstname} started
     cups.py -v -t production_status -r $2 -s $3 --dstname=${dstname} started

echo running root.exe -q -b Fun4All_Year1.C\($1,\"${lfn}\",\"$6\",\"$7\",\"$9\"\) 

echo cups.py -t production_status -r $2 -s $3 --dstname=${dstname} running
     cups.py -v -t production_status -r $2 -s $3 --dstname=${dstname} running

root.exe -q -b  Fun4All_Year1.C\($1,\"$lfn\",\"$6\",\"$7\",\"$9\"\)

echo cups.py -t production_status -r $2 -s $3 --dstname=${dstname} exitcode --exit $?
     cups.py -v -t production_status -r $2 -s $3 --dstname=${dstname} exitcode --exit $?

runnumber=$(printf "%08d" $2)
sequence=$(printf "%04d" $3)
logbase=${dstfile}

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

touch stderr.log
ls -la

echo "script done"

cp stdout.log ${dstfile}.out
cp stderr.log ${dstfile}.err

} >&stdout.log 2>stderr.log


