#!/usr/bin/bash

filename=${1}
destination=${2}

# decode filename
#echo ${filename}         # filename
#echo ${filename/.root/}  # strip suffix
#echo ${filename%-*}      # strip segment

base=${filename/.root/}
dstname=${base%%-*}
dsttype=`echo ${dstname} | cut -d'_' -f1,2`
build=`echo ${dstname} | cut -d'_' -f3`
dbtag=`echo ${dstname} | cut -d'_' -f4`
runnumber=`echo ${base} | cut -d'-' -f2`
segment=`echo ${base} | cut -d'-' -f3`

echo stageout ${filename} ${destination} start `date`

./cups.py -r ${runnumber} -s ${segment} -d test stageout ${filename} ${destination}

#cp --verbose  ${filename} ${destination}  

./cups.py -r ${runnumber} -s ${segment} -d DST_TPCCOSMICS_${build}_${dbtag} catalog --ext root --path ${destination} --dataset ${build}_${dbtag} --hostname lustre --nevents 0

# Once it has been moved... and perhaps we place some error checking here... we remove it.

echo Remove ${filename} `date`
rm ${filename}




