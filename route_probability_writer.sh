#!/bin/bash

source /root/sdwan/path.sh

declare -a wan_intf

${ROUTEDELPATH}/probability_del_file.sh
cat /dev/null > ${ROUTEDELPATH}/probability_del_file.sh

if [ "$(ls -A ${INTFPATH}/wan)" ]; then

	rowwan=$(ls $INTFPATH/wan | wc -l)

	if [ "$(ls -A ${INTFPATH}/lan)" ]; then

		for lanintf in ${INTFPATH}/lan/*; do

			j=0

			LAN_IF=${lanintf##*/}

			wan_intf=($(ls -A ${INTFPATH}/wan/))

			calc() { bc -l <<< "scale=3; $@"; }

			#for ((i = rowwan ; i >= 1 ; i--)); do
			for ((i = 0 ; i < rowwan ; i++)); do

				WAN_IF=${wan_intf[j]} 
				WAN_IF_RT_ID=$(cat ${INTF_RT_TABLE_ID_PATH} | grep ${WAN_IF} | cut -d',' -f2)

				# iptables -t mangle -A PREROUTING -i ${LAN_IF} -p tcp -m tcp -m state --state NEW -m statistic --mode random --probability $(calc 1/$i) -j MARK${WAN_IF_RT_ID}			
				# echo "iptables -t mangle -D PREROUTING -i ${LAN_IF} -p tcp -m tcp -m state --state NEW -m statistic --mode random --probability $(calc 1/$i) -j MARK${WAN_IF_RT_ID}" >> ${ROUTEDELPATH}/probability_del_file.sh

				
				# iptables -t mangle -A PREROUTING -i ${LAN_IF} -p udp -m udp -m statistic --mode random --probability $(calc 1/$i) -j MARK${WAN_IF_RT_ID}			
				# echo "iptables -t mangle -D PREROUTING -i ${LAN_IF} -p udp -m udp -m statistic --mode random --probability $(calc 1/$i) -j MARK${WAN_IF_RT_ID}" >> ${ROUTEDELPATH}/probability_del_file.sh

				iptables -t mangle -A PREROUTING -i ${LAN_IF} -p tcp -m tcp -m state --state NEW -m statistic --mode nth --every $rowwan --packet $i -j MARK${WAN_IF_RT_ID}
				echo "iptables -t mangle -D PREROUTING -i ${LAN_IF} -p tcp -m tcp -m state --state NEW -m statistic --mode nth --every $rowwan --packet $i -j MARK${WAN_IF_RT_ID}" >> ${ROUTEDELPATH}/probability_del_file.sh

				
				iptables -t mangle -A PREROUTING -i ${LAN_IF} -p udp -m udp -m state --state NEW -m statistic --mode nth --every $rowwan --packet $i -j MARK${WAN_IF_RT_ID}
				echo "iptables -t mangle -D PREROUTING -i ${LAN_IF} -p udp -m udp -m state --state NEW -m statistic --mode nth --every $rowwan --packet $i -j MARK${WAN_IF_RT_ID}" >> ${ROUTEDELPATH}/probability_del_file.sh

				j=$((j+1))

			done

		done

	fi

fi

chmod 0755 ${ROUTEDELPATH}/probability_del_file.sh