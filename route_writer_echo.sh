#!/bin/bash

source /root/sdwan/path.sh

if [ -z "$(ls -A $INTFPATH/wan)" ]; then

	echo 'iptables -F'
	echo 'iptables -X'
	echo 'iptables -t nat -F'
	echo 'iptables -t nat -X'
	echo 'iptables -t filter -F'
	echo 'iptables -t filter -X'
	echo 'iptables -t mangle -F'
	echo 'iptables -t mangle -X'
	
	${APPPATH}/logger.sh "-1001: route_writer No WAN Interface found on ${INTFPATH}"

	echo 'iptables-save > /etc/iptables/rules.v4'
	exit 1
fi


#INTFPATH='/root/sdwan_test/intf'

# You need these system settings.
echo 1 > /proc/sys/net/ipv4/ip_forward
for f in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo 0 > $f ; done

# Clear iptables/netfilter settings.

echo 'iptables -F'
echo 'iptables -X'
echo 'iptables -t nat -F'
echo 'iptables -t nat -X'
echo 'iptables -t filter -F'
echo 'iptables -t filter -X'
echo 'iptables -t mangle -F'
echo 'iptables -t mangle -X'

###############################################################################################################

i=0

for wanintf in ${INTFPATH}/wan/*; do

	i=$((i+1))
	
	IF=${wanintf##*/}
	IFT=$(cat ${INTFPATH}/wan/${IF} | grep 'interfacetype' | cut -d'=' -f2)
	IPT=$(cat ${INTFPATH}/wan/${IF} | grep 'iptype' | cut -d'=' -f2)
	IP=$(cat ${INTFPATH}/wan/${IF} | grep 'ipaddress' | cut -d'=' -f2)
	GW=$(cat ${INTFPATH}/wan/${IF} | grep 'gateway' | cut -d'=' -f2)
	NET=$(cat ${INTFPATH}/wan/${IF} | grep 'network' | cut -d'=' -f2)
	
	TABLE=$i

	echo "ip route flush table ${TABLE}"

	echo "ip route add ${NET} dev ${IF} src ${IP} table ${TABLE}"
	echo "ip route add default via ${GW} table ${TABLE}"

	echo "ip rule del from all fwmark 0x${i} lookup ${TABLE} 2>/dev/null"
	echo "ip rule del from all fwmark 0x${i} 2>/dev/null"

	echo "ip rule del from ${IP}"

	echo "ip rule add from ${IP} table ${TABLE}"
	echo "ip rule add fwmark ${i} table ${TABLE}"

	echo "iptables -t mangle -N MARK${i}"
	echo "iptables -t mangle -A MARK${i} -j MARK --set-mark ${i}"
	echo "iptables -t mangle -A MARK${i} -j CONNMARK --save-mark"

	echo "iptables -t nat -N ${IF^^}_OUT_IF"
	echo "iptables -t nat -A ${IF^^}_OUT_IF -j SNAT --to-source ${IP}"

	echo "iptables -t nat -A POSTROUTING -o ${IF} -j ${IF^^}_OUT_IF"

	echo "iptables -t nat -N ${IF^^}_IN_IF"
	echo "iptables -t nat -A ${IF^^}_IN_IF -j MARK --set-mark ${i}"
	echo "iptables -t nat -A ${IF^^}_IN_IF -j CONNMARK --save-mark"

	echo "iptables -t nat -A PREROUTING -i ${IF} -j ${IF^^}_IN_IF"
	
done

###############################################################################################################

rowwan=$i

probability=$((100/$rowwan))

for lanintf in ${INTFPATH}/lan/*; do

	IF=${lanintf##*/}

	#echo ${lanintf##*/}
	
	for ((j=1;j<=$rowwan;j++));
	do

		if [ $j -eq $rowwan ]; then
			probability=$((100-$(($probability*$(($j-1))))))
		fi

		echo "iptables -t mangle -A PREROUTING -i ${IF} -p tcp -m tcp -m state --state NEW -m statistic --mode random --probability 0.${probability} -j MARK${j}"
		
	done

	# Restore mark on packets belonging to existing connections.
	echo "iptables -t mangle -A PREROUTING -i ${IF} -p tcp -m tcp -m state --state ESTABLISHED,RELATED -j CONNMARK --restore-mark"

done

###############################################################################################################

for lanintf in ${INTFPATH}/lan/*; do

	IF=${lanintf##*/}

	for ((j=1;j<=$rowwan;j++));
	do

		if [ $j -eq $rowwan ]; then
			probability=$((100-$(($probability*$(($j-1))))))
		fi

		echo "iptables -t mangle -A PREROUTING -i ${IF} -p udp -m udp -m statistic --mode random --probability 0.${probability} -j MARK${j}"
		
	done

done

###############################################################################################################

i=0

for wanintf in ${INTFPATH}/wan/*; do

	i=$((i+1))

	IF=${wanintf##*/}
	DNS=$(cat ${INTFPATH}/wan/${IF} | grep 'dns_1' | cut -d'=' -f2)

	echo "iptables -t mangle -A PREROUTING -p tcp --dport 53 -d ${DNS} -j MARK${i}"
	echo "iptables -t mangle -A PREROUTING -p udp --dport 53 -d ${DNS} -j MARK${i}"

done

#echo "iptables-save > /etc/iptables/rules.v4"

#"ip route flush cache"