#!/bin/bash

source /root/sdwan/path.sh

# -n NETWORK
# -m NETMASK
# -g GATEWAY
# -i INTERFACE
# -m METRIC


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

if [ -z $METRIC ]; then
    METRIC=''
fi

echo "ip route add $NETWORK/$NETMASK via $GATEWAY"

echo "ip route add $NETWORK/$NETMASK dev $INTERFACE"


# Source Base
# ip rule add from <source>/<mask> table <name>
# ip route add 1.2.3.4/24 via <router> dev eth4 table <name>
# <name> is either table name specified in /etc/iproute2/rt_tables or you can use numeric id ...