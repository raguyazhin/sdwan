#!/bin/bash

source /root/sdwan/path.sh

# - n) INTERFACE 

while getopts n: option 
do 
    case "${option}" 
    in 
        n) INTERFACE=${OPTARG};; 
    esac 
done 

if [ -z $INTERFACE ]; then
    echo "provide -n INTERFACE NAME"
    exit 1
fi

RT_ID=$(cat ${INTF_RT_TABLE_ID_PATH} | grep ${INTERFACE} | cut -d',' -f2)

#===============================================================================================================

echo 1 > /proc/sys/net/ipv4/ip_forward
for f in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo 0 > $f ; done

#===============================================================================================================

IF=${INTERFACE}

IFT=$(cat ${INTFPATH}/wan/${IF} | grep 'interfacetype' | cut -d'=' -f2)
IPT=$(cat ${INTFPATH}/wan/${IF} | grep 'iptype' | cut -d'=' -f2)
IP=$(cat ${INTFPATH}/wan/${IF} | grep 'ipaddress' | cut -d'=' -f2)
GW=$(cat ${INTFPATH}/wan/${IF} | grep 'gateway' | cut -d'=' -f2)
NET=$(cat ${INTFPATH}/wan/${IF} | grep 'network' | cut -d'=' -f2)

TABLE=${RT_ID}

ip route flush table ${TABLE}

ip route add ${NET} dev ${IF} src ${IP} table ${TABLE}
ip route add default via ${GW} table ${TABLE}

ip rule del from all fwmark 0x${RT_ID} lookup ${TABLE} 2>/dev/null
ip rule del from all fwmark 0x${RT_ID} 2>/dev/null

ip rule del from ${IP}

ip rule add from ${IP} table ${TABLE}
ip rule add fwmark ${RT_ID} table ${TABLE}

iptables -t mangle -N MARK${RT_ID}
iptables -t mangle -A MARK${RT_ID} -j MARK --set-mark ${RT_ID}
iptables -t mangle -A MARK${RT_ID} -j CONNMARK --save-mark

iptables -t nat -N ${IF^^}_OUT_IF
iptables -t nat -A ${IF^^}_OUT_IF -j SNAT --to-source ${IP}

iptables -t nat -A POSTROUTING -o ${IF} -j ${IF^^}_OUT_IF

iptables -t nat -N ${IF^^}_IN_IF
iptables -t nat -A ${IF^^}_IN_IF -j MARK --set-mark ${RT_ID}
iptables -t nat -A ${IF^^}_IN_IF -j CONNMARK --save-mark

iptables -t nat -A PREROUTING -i ${IF} -j ${IF^^}_IN_IF

#===============================================================================================================

intf_route_del_file=${IF}".sh"

echo "#!/bin/bash" > ${ROUTEDELPATH}/${intf_route_del_file}

echo "ip route delete ${NET} dev ${IF} src ${IP} table ${TABLE}" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "ip route delete default via ${GW} table ${TABLE}" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "ip rule del from all fwmark 0x${RT_ID} lookup ${TABLE} 2>/dev/null" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "ip rule del from all fwmark 0x${RT_ID} 2>/dev/null" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "ip rule del from ${IP}" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "ip rule delete from ${IP} table ${TABLE}" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "ip rule delete fwmark ${RT_ID} table ${TABLE}" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "iptables -t mangle -D MARK${RT_ID} -j MARK --set-mark ${RT_ID}" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "iptables -t mangle -D MARK${RT_ID} -j CONNMARK --save-mark" >> ${ROUTEDELPATH}/${intf_route_del_file}
# echo "iptables -t mangle -X MARK${RT_ID}" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "iptables -t nat -D ${IF^^}_OUT_IF -j SNAT --to-source ${IP}" >> ${ROUTEDELPATH}/${intf_route_del_file}
# echo "iptables -t nat -X ${IF^^}_OUT_IF" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "iptables -t nat -D POSTROUTING -o ${IF} -j ${IF^^}_OUT_IF" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "iptables -t nat -D ${IF^^}_IN_IF -j MARK --set-mark ${RT_ID}" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "iptables -t nat -D ${IF^^}_IN_IF -j CONNMARK --save-mark" >> ${ROUTEDELPATH}/${intf_route_del_file}
# echo "iptables -t nat -X ${IF^^}_IN_IF" >> ${ROUTEDELPATH}/${intf_route_del_file}

echo "iptables -t nat -D PREROUTING -i ${IF} -j ${IF^^}_IN_IF" >> ${ROUTEDELPATH}/${intf_route_del_file}

#===============================================================================================================

${APPPATH}/route_probability_writer.sh

#===============================================================================================================

if [ "$(ls -A ${INTFPATH}/lan)" ]; then

	for lanintf in ${INTFPATH}/lan/*; do

		LAN_IF=${lanintf##*/}

		# Restore mark on packets belonging to existing connections.
		iptables -t mangle -A PREROUTING -i ${LAN_IF} -p tcp -m tcp -m state --state ESTABLISHED,RELATED -j CONNMARK --restore-mark
		echo "iptables -t mangle -D PREROUTING -i ${LAN_IF} -p tcp -m tcp -m state --state ESTABLISHED,RELATED -j CONNMARK --restore-mark" >> ${ROUTEDELPATH}/${intf_route_del_file}

	done

fi

#===============================================================================================================

DNS=$(cat ${INTFPATH}/wan/${IF} | grep 'dns_1' | cut -d'=' -f2)

iptables -t mangle -A PREROUTING -p tcp --dport 53 -d ${DNS} -j MARK${RT_ID}
iptables -t mangle -A PREROUTING -p udp --dport 53 -d ${DNS} -j MARK${RT_ID}

echo "iptables -t mangle -D PREROUTING -p tcp --dport 53 -d ${DNS} -j MARK${RT_ID}" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "iptables -t mangle -D PREROUTING -p udp --dport 53 -d ${DNS} -j MARK${RT_ID}" >> ${ROUTEDELPATH}/${intf_route_del_file}

#===============================================================================================================

echo "iptables -t mangle -X MARK${RT_ID}" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "iptables -t nat -X ${IF^^}_OUT_IF" >> ${ROUTEDELPATH}/${intf_route_del_file}
echo "iptables -t nat -X ${IF^^}_IN_IF" >> ${ROUTEDELPATH}/${intf_route_del_file}

#===============================================================================================================

chmod 0755 ${ROUTEDELPATH}/${intf_route_del_file}

#===============================================================================================================

iptables-save > /etc/iptables/rules.v4

ip route flush cache