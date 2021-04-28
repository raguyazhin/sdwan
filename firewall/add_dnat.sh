#!/bin/bash

source /root/sdwan/path.sh
source /root/sdwan/functions.sh

while getopts i:p:d:e:t:f:r: option 
do 
    case "${option}" 
    in 

        i) INTERFACE=${OPTARG};; 
        p) PROTOCOL=${OPTARG};;
        d) PUBLIC_IP=${OPTARG};;
        e) PUBLIC_PORT=${OPTARG};;
        t) LOCAL_IP=${OPTARG};; 
        f) LOCAL_PORT=${OPTARG};; 
        r) REMOTE_IP_NETWORK=${OPTARG};;
        
    esac 
done 

policy=""

if [ -z $INTERFACE ]; then
    echo "provide -i INTERFACE"
    exit 1
fi

if [ -z $PROTOCOL ]; then
    echo "provide -p PROTOCOL"
    exit 1
fi

if [ -z $LOCAL_IP ]; then
    echo "provide -t LOCAL_IP"
    exit 1
fi

policy+="-p $PROTOCOL -i $INTERFACE "

if [ "${REMOTE_IP_NETWORK^^}" != "ANY" ]; then
    policy+="-s $REMOTE_IP_NETWORK "
fi

if [ $PUBLIC_IP ]; then
    policy+="-d $PUBLIC_IP "
fi

if [ $PUBLIC_PORT ]; then
    policy+="--dport $PUBLIC_PORT "
fi

policy+="-j DNAT "

if [[ $LOCAL_IP ]] && [[ $LOCAL_PORT ]]; then
    policy+="--to-destination $LOCAL_IP:$LOCAL_PORT "
elif [ $LOCAL_IP ]; then
    policy+="--to-destination $LOCAL_IP "
fi

echo "iptables -t nat -A PREROUTING $policy -m state --state NEW,RELATED,ESTABLISHED"