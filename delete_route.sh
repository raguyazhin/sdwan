#!/bin/bash

source /root/sdwan/path.sh

# -n NETWORK
# -m NETMASK
# -g GATEWAY
# -i INTERFACE

while getopts n:m:g: option 
do 
    case "${option}" 
    in 
        n) NETWORK=${OPTARG};; 
        m) NETMASK=${OPTARG};; 
        g) GATEWAY=${OPTARG};; 
    esac 
done 

if [ -z $NETWORK ]; then
     echo "provide -n NETWORK"
     exit 1
fi

if [ -z $NETMASK ]; then
     echo "provide -m NETMASK"
     exit 1
fi

if [ -z $GATEWAY ]; then
    GATEWAY=''
fi

echo "ip route del $NETWORK/$NETMASK via $GATEWAY"

echo "ip route add $NETWORK/$NETMASK dev $INTERFACE"
