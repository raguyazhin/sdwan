#!/bin/bash

source /root/sdwan/path.sh

 while true
 do

	#cat /dev/null > ${DBPATH}/intf_ifplug_status

	for intf in ${USRCONFPATH}/* ${PHYINTFPATH}/*; do
		
		interface_name=${intf##*/}

		if [ -f "${intf}" ]; then

			if_plug_status=$(ifplugstatus ${interface_name} | awk {'print $2,$3,$4'})

			sed -i '/'${interface_name}'/d' ${DBPATH}/intf_ifplug_status; 
			echo "${interface_name}","$if_plug_status" &>> ${DBPATH}/intf_ifplug_status; 

		fi

	done

 sleep 5

 done
