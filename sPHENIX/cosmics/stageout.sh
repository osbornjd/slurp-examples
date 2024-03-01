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

echo stageout ${filename} ${destination} `date`

./cups.py -r ${runnumber} -s ${segment} -d test stageout ${filename} ${destination}

# Once it has been moved... and perhaps we place some error checking here... we remove it.

ecaho Remove ${filename} `date`
rm ${filename}

#dbtag=${dstname##*_}
#echo ${dbtag}

#echo ${base#*-}      # run-segment
#runnumber_segment=${base#*-}   
#segment=${runnumber_segment#*-}
#runnumber=${runnumber_segment%-*}


