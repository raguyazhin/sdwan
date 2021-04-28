#!/bin/bash

source /root/sdwan/path.sh
source /root/sdwan/functions.sh

while getopts i:p:t:f:d:e: option 
do 
    case "${option}" 
    in 

        i) INTERFACE=${OPTARG};; 
        p) PROTOCOL=${OPTARG};;
        t) LOCAL_IP=${OPTARG};; 
        f) LOCAL_PORT=${OPTARG};; 
        d) PUBLIC_IP=${OPTARG};;
        e) PUBLIC_PORT=${OPTARG};;
        
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

policy+="-p $PROTOCOL -o $INTERFACE "

if [ $LOCAL_IP ]; then
    policy+="-s $LOCAL_IP "
fi

if [ $LOCAL_PORT ]; then
    policy+="--dport $LOCAL_PORT "
fi

policy+="-j SNAT "

if [[ $PUBLIC_IP ]] && [[ $PUBLIC_PORT ]]; then
    policy+="--to-source $PUBLIC_IP:$PUBLIC_PORT "
elif [ $PUBLIC_IP ]; then
    policy+="--to-source $PUBLIC_IP "
fi

echo "iptables -t nat -A POSTROUTING $policy -m state --state NEW,RELATED,ESTABLISHED"