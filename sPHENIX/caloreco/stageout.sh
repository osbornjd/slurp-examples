#!/usr/bin/bash

filename=`basename ${1}`   # must be a local file
destination=${2}

echo stageout ${filename} ${destination} start `date`

# decode filename
base=${filename/.root/}
dstname=${base%%-*}
dsttype=`echo ${dstname} | cut -d'_' -f1,2`
build=`echo ${dstname} | cut -d'_' -f3`
dbtag=`echo ${dstname} | cut -d'_' -f4`
runnumber=`echo ${base} | cut -d'-' -f2`
segment=`echo ${base} | cut -d'-' -f3`

ls -la

echo ./cups.py -r ${runnumber} -s ${segment} --dsttype ${dsttype} -d ${build}_${dbtag}  stageout ${filename} ${destination}
     ./cups.py -r ${runnumber} -s ${segment} --dsttype ${dsttype} -d ${build}_${dbtag}  stageout ${filename} ${destination}

echo stageout ${filename} ${destination} finish `date`



