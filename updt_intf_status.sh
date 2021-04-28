#!/bin/bash

source /root/sdwan/path.sh

# -p INTFPATH
# -n INTERFACE
# -i IPADDRESS 
# -m SUBNETMASK
# -g GATEWAY
# -s STATUS 
# -e ENABLE

while getopts p:n:i:m:g:d:f:s:e: option 
do 
    case "${option}" 
    in 
        p) INTFPATH=${OPTARG};; 
        n) INTERFACE=${OPTARG};; 
        i) IPADDRESS=${OPTARG};;  
        m) SUBNETMASK=${OPTARG};;  
        g) GATEWAY=${OPTARG};;  
        d) DNS_1=${OPTARG};;  
        f) DNS_2=${OPTARG};;  
        s) STATUS=${OPTARG};;  
        e) ENABLE=${OPTARG};; 
    esac 
done 


if [ -z $INTFPATH ]; then
    echo "provide -p INTERFACE PATH"
    exit 1
fi

if [ -z $INTERFACE ]; then
    echo "provide -n INTERFACE NAME"
    exit 1
fi

if [ -z $STATUS ]; then
    STATUS=0
fi

if [ -z $ENABLE ]; then
    ENABLE="YES"
fi

if [ -e ${INTFPATH}/${INTERFACE} ]; then

    if [ $IPADDRESS ]; then
        sed -i 's/ipaddress=\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/ipaddress='$IPADDRESS'/' ${INTFPATH}/${INTERFACE}
    fi

    if [ $SUBNETMASK ]; then
        sed -i 's/subnetmask=\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/subnetmask='$SUBNETMASK'/' ${INTFPATH}/${INTERFACE}
    fi

    if [ $GATEWAY ]; then
         sed -i 's/gateway=\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/gateway='$GATEWAY'/' ${INTFPATH}/${INTERFACE}
    fi

    if [ $DNS_1 ]; then
         sed -i 's/dns_1=\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/dns_1='$DNS_1'/' ${INTFPATH}/${INTERFACE}
    fi

     if [ $DNS_2 ]; then
         sed -i 's/dns_2=\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/dns_2='$DNS_2'/' ${INTFPATH}/${INTERFACE}
    fi

    sed -i 's/status=[0-9]/status='$STATUS'/' ${INTFPATH}/${INTERFACE}

    sed -i 's/enable=YES\|enable=NO/enable='$ENABLE'/' ${INTFPATH}/${INTERFACE}

else

    echo displayname=${INTERFACE} &> ${INTFPATH}/${INTERFACE}	
	echo interfacename=${INTERFACE} &>> ${INTFPATH}/${INTERFACE}
	echo interfacetype=WAN &>> ${INTFPATH}/${INTERFACE}
	echo iptype=DHCP &>> ${INTFPATH}/${INTERFACE}
	echo ipaddress=0.0.0.0 &>> ${INTFPATH}/${INTERFACE}
	echo subnetmask=0.0.0.0 &>> ${INTFPATH}/${INTERFACE}
	echo gateway=0.0.0.0 &>> ${INTFPATH}/${INTERFACE}
	echo dns_1=8.8.8.8 &>> ${INTFPATH}/${INTERFACE}
    echo dns_2=8.8.8.8 &>> ${INTFPATH}/${INTERFACE}
	echo status=0 &>> ${INTFPATH}/${INTERFACE}
	echo enable=YES &>> ${INTFPATH}/${INTERFACE}

fi
