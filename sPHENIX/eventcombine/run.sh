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

./cups.py -r ${runnumber} -s ${segment} -d DST_EVENT_auau23_${build}_${dbtag} started

hostname

event0=$(( nevents * ( segment ) ))
eventF=$(( nevents * ( segment + 1 ) - 1))



this_script=$BASH_SOURCE
this_script=`readlink -f $this_script`
this_dir=`dirname $this_script`
echo rsyncing from $this_dir
echo running: $this_script $*

if [[ ! -z "$_CONDOR_SCRATCH_DIR" && -d $_CONDOR_SCRATCH_DIR ]]
then
    cd $_CONDOR_SCRATCH_DIR
else
    echo condor scratch NOT set
    exit 1
fi

# Ensure the existence of the output directory
mkdir -p ${outputdir}/

# Map input files onto input filelists
#for f in "${inputs[@]}"; do
#    b=$( basename $f )
#    l=${b%%-*}.list
#    #echo Mapping $f onto $l
#    echo $f >> $l    
#done

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


./cups.py -r ${runnumber} -s ${segment} -d DST_EVENT_auau23_${build}_${dbtag} running

echo inputlist $inputlist
echo ./cups.py -r ${runnumber} -s ${segment} -d DST_EVENT_auau23_${build}_${dbtag} inputs --files ${inputlist}
./cups.py -r ${runnumber} -s ${segment} -d DST_EVENT_auau23_${build}_${dbtag} inputs --files ${inputlist}

ls -la

echo root.exe -q -b Fun4All_Combiner.C\(${nevents},\"${seb00}\",\"${seb01}\",\"${seb02}\",\"${seb03}\",\"${seb04}\",\"${seb05}\",\"${seb06}\",\"${seb07}\",\"${hcalwest}\",\"${hcaleast}\",\"${zdc}\",\"${mbd}\",\"${outputdir}\",\"${basefilename}\"\)
     root.exe -q -b Fun4All_Combiner.C\(${nevents},\"${seb00}\",\"${seb01}\",\"${seb02}\",\"${seb03}\",\"${seb04}\",\"${seb05}\",\"${seb06}\",\"${seb07}\",\"${hcalwest}\",\"${hcaleast}\",\"${zdc}\",\"${mbd}\",\"${outputdir}\",\"${basefilename}\"\)      | pull.py

# go to sleep for 2min
#sleep 120

status_f4a=$?

./cups.py -r ${runnumber} -s ${segment} -d DST_EVENT_auau23_${build}_${dbtag} exitcode -e ${status_f4a}


cat <<EOF > qatest.json
{
  "workflow" : "event combine",
  "build"    : "${build}",
  "tag"      : "${tag}"
}
EOF

#$$$$ ./cups.py -r ${runnumber} -s ${segment} -d DST_EVENT_auau23_${build}_${dbtag} quality --qafile qatest.json


echo "script done"

} > stdout.log 2>stderr.log



runnumber=$(printf "%08d" $runnumber)
segment=$(printf "%04i" $segment)
rootname=DST_EVENT_auau23_${build}_${dbtag}-${runnumber}-${segment}.prdf

ls -l *.log >> stdout.log

cp stderr.log ${rootname/prdf/err}
cp stdout.log ${rootname/prdf/out}

