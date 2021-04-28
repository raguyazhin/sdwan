#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

file_str=""
metric=0

if [ -z "$(ls -A $PHYINTFPATH)" ]; then	
	${APPPATH}/logger.sh "-1001: interface_writer no physical interface found on ${PHYINTFPATH}"
	#exit 1
fi

if [ -z "$(ls -A $USRCONFPATH)" ]; then	
	${APPPATH}/logger.sh "-1001: interface_writer no user interface found on ${USRCONFPATH}"
	#exit 1
fi

for usrintf in ${USRCONFPATH}/* ${PHYINTFPATH}/*; do
	
	interface_name=${usrintf##*/}

	if [ -f "${usrintf}" ]; then

		interface_type=$(cat ${usrintf} | grep 'interfacetype' | cut -d'=' -f2)
		ip_type=$(cat ${usrintf} | grep 'iptype' | cut -d'=' -f2)
		ip_status=$(cat ${usrintf} | grep 'status' | cut -d'=' -f2)

		interface_enable=$(cat ${usrintf} | grep 'enable' | cut -d'=' -f2)

		if [ ${interface_enable^^} == "YES" ]; then

			#file_str+="\nauto ${interface_name}\n"
			file_str+="allow-hotplug ${interface_name}\n\n"		

			if [ ${ip_type^^} == "STATIC" ]; then

				ip_address=$(cat ${usrintf} | grep 'ipaddress' | cut -d'=' -f2)
				subnet_mask=$(cat ${usrintf} | grep 'subnetmask' | cut -d'=' -f2)
				gate_way=$(cat ${usrintf} | grep 'gateway' | cut -d'=' -f2)

				file_str+="iface ${interface_name} inet static\n"
				file_str+="\t address ${ip_address}\n"
				file_str+="\t netmask ${subnet_mask}\n"		

				if [ ${interface_type^^} == "WAN" ]; then

					file_str+="\t gateway ${gate_way}\n"

				elif [ ${interface_type^^} == "LAN" ]; then

					lan_netwrk=$(get_network4lan ${ip_address} ${subnet_mask})

					file_str+="\t up /sbin/ip route add ${lan_netwrk} via ${gate_way} dev ${interface_name}\n"
					file_str+="\t down /sbin/ip route delete ${lan_netwrk} via ${gate_way} dev ${interface_name}\n"

				fi

			elif [ ${ip_type^^} == "DHCP" ]; then

				file_str+="iface ${interface_name} inet dhcp\n"

			fi

			if [ ${interface_type^^} == "WAN" ]
			then

				#echo ${interface_name}

				interface_metric=$(ip route show default | grep ^"default" | awk '{print $3, $5, $6, $7 }' | grep -w ${interface_name})

				#echo $interface_metric

				metric_data=$(echo $interface_metric | awk '{print $3}')
				metric_val=$(echo $interface_metric | awk '{print $4}')

				if [ ! -z $metric_data ]; then

					if [ ${metric_data^^} == "METRIC" ]; then

							file_str+="metric ${metric_val}\n"

					fi

				else

					metric=$(($metric+10))
					met_chk=1

					while [ $met_chk -eq 1 ]
					do
						result=$(echo $(ip route show default | grep ^"default" | awk '{print $6, $7 }') | grep "metric $metric")

						if [ -z "$result" ]; then

							file_str+="metric ${metric}\n"

							met_chk=0

						else

							metric=$(($metric+10))
							#echo $metric

						fi

					done

				fi
				
			fi

		fi	

	fi

done

file_str="# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface

auto lo
iface lo inet loopback

# The primary network interface

${file_str}

"

echo -e "${file_str}" > /etc/network/interfaces

