#!/bin/bash

source /root/sdwan/path.sh

#===========================================================================================================================#

cat /dev/null > ${DBPATH}/chkintf

for file in ${PHYINTFPATH}/*
do
  echo ${file##*/} &>> ${DBPATH}/chkintf
done

for file in $(cat ${INTFFILEPATH})
do
  echo ${file} &>> ${DBPATH}/chkintf
done

for file in $(ls -l /sys/class/net/ | grep virtual | awk '{print $9}')
do
  echo ${file} &>> ${DBPATH}/chkintf
done

#===========================================================================================================================#

for phyintf in ${PHYINTFPATH}/*
do

	interface_enable=$(cat ${phyintf} | grep 'enable' | cut -d'=' -f2)

	if [ ${interface_enable^^} == "YES" ]; then

		intf=${phyintf##*/}

		${APPPATH}/create_tracker.sh -p ${PHYINTFPATH} -n ${intf} -u 0

	fi

done

for usrintf in $(ls -l /sys/class/net/ | grep -v virtual | awk '{print $9}')
do
		
	if !(grep -Fxq $usrintf ${DBPATH}/chkintf)
	then

		echo $usrintf;

		${APPPATH}/updt_intf_status.sh -p ${USRCONFPATH} -n ${usrintf}
		${APPPATH}/create_tracker.sh -p ${USRCONFPATH} -n ${usrintf} -u 1

	fi

done

${APPPATH}/interface_writer.sh