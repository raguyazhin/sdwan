#!/bin/bash

source /root/sdwan/path.sh

# - n) INTERFACE 
# - t) INTERFACE_TYPE
# - y) IP_TYPE
# - i) IPADDRESS
# - m) SUBNETMASK
# - g) GATEWAY
# - d) DNS_1
# - f) DNS_2
# - w) NETWORK

while getopts n:t:y:i:m:g:d:f:w: option 
do 
    case "${option}" 
    in 
        n) INTERFACE=${OPTARG};; 
        t) INTERFACE_TYPE=${OPTARG};;
        y) IP_TYPE=${OPTARG};;
        i) IPADDRESS=${OPTARG};;  
        m) SUBNETMASK=${OPTARG};;  
        g) GATEWAY=${OPTARG};;  
        d) DNS_1=${OPTARG};;  
        f) DNS_2=${OPTARG};;  
        w) NETWORK=${OPTARG};; 
    esac 
done 

if [ -z $INTERFACE ]; then
    echo "provide -n INTERFACE NAME"
    exit 1
fi

if [ -z $INTERFACE_TYPE ]; then
    echo "provide -t INTERFACE TYPE"
    exit 1
fi

INTFFILE=${INTFPATH}/${INTERFACE_TYPE,,}/${INTERFACE}

echo interfacename=${INTERFACE} &> ${INTFFILE}
echo interfacetype=${INTERFACE_TYPE} &>> ${INTFFILE}

if [ $IP_TYPE ]; then
    echo iptype=${IP_TYPE} &>> ${INTFFILE}
fi

if [ $IPADDRESS ]; then
    echo ipaddress=${IPADDRESS} &>> ${INTFFILE}
fi

if [ $SUBNETMASK ]; then
    echo subnetmask=${SUBNETMASK} &>> ${INTFFILE}
fi

if [ $GATEWAY ]; then
    echo gateway=${GATEWAY} &>> ${INTFFILE}
fi

if [ $DNS_1 ]; then
    echo dns_1=${DNS_1} &>> ${INTFFILE}
fi

if [ $DNS_2 ]; then
    echo dns_2=${DNS_2} &>> ${INTFFILE}
fi

if [ $NETWORK ]; then
    echo network=${NETWORK} &>> ${INTFFILE}
fi
