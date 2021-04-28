#!/bin/bash

while getopts n: option 
do 
    case "${option}" 
    in 
        n) CLIENT_CRT_NAME=${OPTARG};;     
    esac 
done 

if [ -z $CLIENT_CRT_NAME ]; then
     echo "provide -n CLIENT_CRT_NAME"
     exit 1
fi
 

echo $CLIENT_CRT_NAME

CCDPATH='/etc/openvpn/server/ccd'

if [ -f ${CCDPATH}/${CLIENT_CRT_NAME} ] 
then
    rm $CCDPATH/$CLIENT_CRT_NAME
fi
 

if [ ! -d "/etc/openvpn/client/deleted" ] 
then
    mkdir -p /etc/openvpn/client/deleted
fi

if [ -d /etc/openvpn/client/$CLIENT_CRT_NAME ] 
then
    rm -rf /etc/openvpn/client/deleted/$CLIENT_CRT_NAME
    mv /etc/openvpn/client/$CLIENT_CRT_NAME /etc/openvpn/client/deleted/$CLIENT_CRT_NAME
fi




