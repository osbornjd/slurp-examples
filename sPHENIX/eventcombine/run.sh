#!/bin/env bash 

{

export USER="$(id -u -n)"
export LOGNAME=${USER}
export HOME=/sphenix/u/${USER}

source /opt/sphenix/core/bin/sphenix_setup.sh -n $8

export ODBCINI=./odbc.ini

nevents=${1}
basefilename=${2}
baselogname=${3}
outputdir=${4}
runnumber=${5}
segment=${6}
clusterid=${7}
procid=${8}
build=${9/./}
dbtag=${10}
inputs=(`echo ${11} | tr "," " "`)  # array of input files
ranges=(`echo ${12} | tr "," " "`)  # array of input files and ranges

echo basefilename ${basefilename}
echo baselogname  ${baselogname}

./cups.py -r ${runnumber} -s ${segment} -d ${basefilename} started

hostname

event0=$(( nevents * ( segment ) ))
eventF=$(( nevents * ( segment + 1 ) - 1))

# Ensure the existence of the output directory
mkdir -p ${outputdir}/

# Map input files onto input filelists
#
# sebII:  min ............. max | min ...... max | min ..................... max | min ........................... max |
# event:  min .... max | min ................................. max | min ....................... max | min ....... max |
#
# If min event is in the  file then use the file
# if max event is in the  file then use the file
# if min event is < the file min AND max event is > the file max then use the file

inputlist=""
for f in "${ranges[@]}"; do    
    a=( $(echo ${f} | tr ':' ' ') )
    fname=${a[0]}         # filename
    bname=$( basename $fname )  # basename
    lname=${bname%%-*}.list  # list name
    echo $f $fname $bname $lname
    mnevent=${a[1]}       # first event in file
    mxevent=${a[2]}       # last event in file
    if [[ $event0 -ge $mnevent && $event0 -le $mxevent ]]; then
          echo $fname $event0 'in' $mnevent $mxevent '[min in range]'
          echo $fname >> $lname
	  inputlist="${fname}(${mnevent}-${mxevent}) ${inputlist}"
          continue;
    fi
    if [[ $eventF -ge $mnevent && $eventF -le $mxevent ]]; then
          echo $fname $eventF 'in' $mnevent $mxevent '[max in range]'
          echo $fname >> $lname
	  inputlist="${fname}(${mnevent}-${mxevent}) ${inputlist}"
          continue;
    fi
    if [[ $event0 -le $mnevent && $eventF -ge $mxevent ]]; then
          echo $fname $eventF 'in' $mnevent $mxevent '[min,max includes range]'
          echo $fname >> $lname
	  inputlist="${fname}(${mnevent}-${mxevent}) ${inputlist}"
          continue;
    fi
    if [[ $nevents -le 0 ]]; then
          echo setting nevent to 0 triggers all: $fname $lname
          echo $fname >> $lname
	  inputlist="${fname} ${inputlist}"
          continue;
    fi
done

for inlist in *.list; do
   echo $inlist : `cat $inlist`
   cat $inlist | sort > $inlist.2
   mv $inlist.2 $inlist
done

seb00="beam_seb00.list"
seb01="beam_seb01.list"
seb02="beam_seb02.list"
seb03="beam_seb03.list"
seb04="beam_seb04.list"
seb05="beam_seb05.list"
seb06="beam_seb06.list"
seb07="beam_seb07.list"

zdc="beam_seb14.list"
mbd="beam_seb18.list"

hcaleast="beam_East.list"
hcalwest="beam_West.list"

ll1="beam_LL1.list"
gl1="GL1_beam_gl1daq.list"

# Mark state as running and provide input list
./cups.py -r ${runnumber} -s ${segment} -d ${basefilename} running
./cups.py -r ${runnumber} -s ${segment} -d ${basefilename} inputs --files ${inputlist}

echo root.exe -q -b Fun4All_Combiner.C\(${nevents},\"${seb00}\",\"${seb01}\",\"${seb02}\",\"${seb03}\",\"${seb04}\",\"${seb05}\",\"${seb06}\",\"${seb07}\",\"${hcalwest}\",\"${hcaleast}\",\"${zdc}\",\"${mbd}\",\"${outputdir}\",\"${basefilename}\"\) 

root.exe -q -b Fun4All_Combiner.C\(${nevents},\"${seb00}\",\"${seb01}\",\"${seb02}\",\"${seb03}\",\"${seb04}\",\"${seb05}\",\"${seb06}\",\"${seb07}\",\"${hcalwest}\",\"${hcaleast}\",\"${zdc}\",\"${mbd}\",\"${outputdir}\",\"${basefilename}\"\) 
status_f4a=$?

./cups.py -r ${runnumber} -s ${segment} -d ${basefilename} exitcode -e ${status_f4a}

echo "script done"
ls -la

} > stdout.log 2>stderr.log

cp stderr.log ${baselogname}.err 
cp stdout.log ${baselogname}.out



