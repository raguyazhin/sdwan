#!/bin/bash

source /root/sdwan/path.sh

# -d DESTINATION_NETWORK
# -g GATEWAY 
# -a ADMINISTRATIVE_DISTANCE
# -i INTERFACE

while getopts d:g:i:a: option 
do 
    case "${option}" 
    in 
        d) DESTINATION_NETWORK=${OPTARG};; 
        g) GATEWAY=${OPTARG};;
        i) INTERFACE=${OPTARG};;
        a) ADMINISTRATIVE_DISTANCE=${OPTARG};;
    esac 
done 

if [ -z $DESTINATION_NETWORK ]; then
    echo "provide -d DESTINATION_NETWORK"
    exit 1
fi

if [ -z $GATEWAY ]; then
    echo "provide -g GATEWAY"
    exit 1
fi

echo $DESTINATION_NETWORK
echo $GATEWAY

ip_route_command=$ip_route_command" $DESTINATION_NETWORK via $GATEWAY"

if [ ! -z $INTERFACE ]; then

       ip_route_command=$ip_route_command" dev $INTERFACE"

fi

if [ ! -z $ADMINISTRATIVE_DISTANCE ]; then

       ip_route_command=$ip_route_command" metric $ADMINISTRATIVE_DISTANCE"

fi


ip_route_command="ip route add $ip_route_command"
    
echo ${ip_route_command}