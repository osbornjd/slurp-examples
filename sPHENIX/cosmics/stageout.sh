#!/usr/bin/bash

filename=`basename ${1}`   # must be a local file
destination=${2}

echo stageout ${filename} ${destination} start `date`

# decode filename
base=${filename/.root/}
dstname=${base%%-*}
dsttype=`echo ${dstname} | cut -d'_' -f1-3`
build=`echo ${dstname} | cut -d'_' -f4`
dbtag=`echo ${dstname} | cut -d'_' -f5`
runnumber=`echo ${base} | cut -d'-' -f2`
segment=`echo ${base} | cut -d'-' -f3`

nevents=$( root.exe -q -b GetEntries.C\(\"${filename}\"\) | awk 'if $0 ~/Number of Entries/{ print $4; } else { print "-1"; }' )

echo ./cups.py -r ${runnumber} -s ${segment} -d ${dstname}  stageout ${filename} ${destination} --dsttype ${dsttype} --dataset ${build}_${dbtag} --nevents ${nevents}
     ./cups.py -r ${runnumber} -s ${segment} -d ${dstname}  stageout ${filename} ${destination} --dsttype ${dsttype} --dataset ${build}_${dbtag} --nevents ${nevents}


echo stageout ${filename} ${destination} finish `date`




