#!/bin/bash

source /root/sdwan/path.sh

for intf in ${USRCONFPATH}/* ${PHYINTFPATH}/*; do

    if [ -f "${intf}" ]; then

        #echo ${intf}
		
		current_status=$(cat ${intf} | grep 'status' | cut -d'=' -f2)
		previous_status=$(cat ${DBPATH}/intfs_status | grep "${intf##*/}" | cut -d',' -f2)

		current_ip=$(cat ${intf} | grep 'ipaddress' | cut -d'=' -f2)
		previous_ip=$(cat ${DBPATH}/intfs_status | grep "${intf##*/}" | cut -d',' -f3)

		if [ ${current_status} != 2 ]; then

			if [[ ${current_status} != ${previous_status} || ${current_ip} != ${previous_ip} ]]; then

				${APPPATH}/route_writer.sh -n ${intf##*/}
				${APPPATH}/logger.sh "-1001: run_route_writter current_status (${current_status}) previous_status (${previous_status}) current_ip (${current_ip}) previous_ip (${previous_ip})"
        		break

			fi

		fi

    fi

done

cat /dev/null > ${DBPATH}/intfs_status

for intf in ${USRCONFPATH}/* ${PHYINTFPATH}/*; do

    if [ -f "${intf}" ]; then

       echo ${intf##*/},$(cat ${intf} | grep 'status' | cut -d'=' -f2),$(cat ${intf} | grep 'ipaddress' | cut -d'=' -f2) &>> ${DBPATH}/intfs_status

    fi

done