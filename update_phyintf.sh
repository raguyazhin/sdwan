#!/bin/bash

source /root/sdwan/path.sh

# -n interfacename=enp1s0
# -t interfacetype=LAN
# -p iptype=STATIC
# -a ipaddress=192.168.50.1
# -s subnetmask=255.255.255.0
# -g gateway=192.168.50.1
# -d dns=127.0.0.1
# -b dns=127.0.0.1
# -e enable=YES

while getopts n:i:t:p:a:s:g:d:b:e:c: option 
do 
    case "${option}" 
    in 
        n) DISPLAY_NAME=${OPTARG};; 
        i) INTERFACE_NAME=${OPTARG};;
        t) INTERFACE_TYPE=${OPTARG};;    
        p) IP_TYPE=${OPTARG};;
        a) IP_ADDRESS=${OPTARG};;    
        s) SUBNET_MASK=${OPTARG};;   
        g) GATEWAY=${OPTARG};;    
        d) DNS_1=${OPTARG};; 
        b) DNS_2=${OPTARG};;
        e) ENABLE=${OPTARG};;
        c) STATUS=${OPTARG};;
    esac 
done 

if [ -z $DISPLAY_NAME ]; then
    echo "provide -n DISPLAY_NAME"
    exit 1
fi

if [ -z $INTERFACE_NAME ]; then
    echo "provide -i INTERFACE_NAME"
    exit 1
fi

if [ -z $INTERFACE_TYPE ]; then
    echo "provide -t INTERFACE_TYPE"
    exit 1
fi

if [ -z $IP_TYPE ]; then
    echo "provide -p IP_TYPE"
    exit 1
fi

if [ $IP_TYPE == "STATIC" ]; then

    if [ -z $IP_ADDRESS ]; then
        echo "provide -a IP_ADDRESS"
        exit 1
    fi

    if [ -z $SUBNET_MASK ]; then
        echo "provide -s SUBNET_MASK"
        exit 1
    fi

fi

if [ -z $DNS_1 ]; then
    DNS_1='8.8.8.8'
fi 

if [ -z $DNS_2 ]; then
    DNS_2='8.8.8.8'
fi

if [ -z $ENABLE ]; then
    ENABLE=$(cat ${PHYINTFPATH}/$INTERFACE_NAME | grep 'enable' | cut -d'=' -f2)
fi

if [ -z $STATUS ]; then

    if [ $ENABLE == "NO" ]; then
        STATUS='3'
    else
        STATUS=$(cat ${PHYINTFPATH}/$INTERFACE_NAME | grep 'status' | cut -d'=' -f2)
    fi
fi

echo 'displayname='$DISPLAY_NAME > ${PHYINTFPATH}/$INTERFACE_NAME
echo 'interfacename='$INTERFACE_NAME >> ${PHYINTFPATH}/$INTERFACE_NAME
echo 'interfacetype='${INTERFACE_TYPE^^} >> ${PHYINTFPATH}/$INTERFACE_NAME
echo 'iptype='${IP_TYPE^^} >> ${PHYINTFPATH}/$INTERFACE_NAME

if [ ${IP_TYPE^^} == "STATIC" ]; then
    echo 'ipaddress='$IP_ADDRESS >> ${PHYINTFPATH}/$INTERFACE_NAME
    echo 'subnetmask='$SUBNET_MASK >> ${PHYINTFPATH}/$INTERFACE_NAME
else 
    echo 'ipaddress=0.0.0.0' >> ${PHYINTFPATH}/$INTERFACE_NAME
    echo 'subnetmask=0.0.0.0' >> ${PHYINTFPATH}/$INTERFACE_NAME
fi

if [ ! -z $GATEWAY ]; then
    echo 'gateway='$GATEWAY >> ${PHYINTFPATH}/$INTERFACE_NAME
else
    echo 'gateway=0.0.0.0' >> ${PHYINTFPATH}/$INTERFACE_NAME
fi

echo 'dns_1='$DNS_1 >> ${PHYINTFPATH}/$INTERFACE_NAME
echo 'dns_2='$DNS_2 >> ${PHYINTFPATH}/$INTERFACE_NAME
echo 'status='$STATUS >> ${PHYINTFPATH}/$INTERFACE_NAME
echo 'enable='$ENABLE >> ${PHYINTFPATH}/$INTERFACE_NAME
    
${APPPATH}/interface_writer.sh

ip addr flush $INTERFACE_NAME && ifup $INTERFACE_NAME

#ip addr flush enp1s0 && ifup enp1s0
#ifdown --force enp1s0 && ifup enp1s0

