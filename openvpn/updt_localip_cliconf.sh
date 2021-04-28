#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

while getopts c:i: option 
do 
    case "${option}" 
    in 
        c) CLIENT_CRT_NAME=${OPTARG};;   
        i) INTERFACE_NAME=${OPTARG};;     
    esac 
done 

if [ -z $CLIENT_CRT_NAME ]; then
     echo "provide -n CLIENT_CRT_NAME"
     exit 1
fi

if [ -z $INTERFACE_NAME ]; then
     echo "provide -i INTERFACE_NAME"
     exit 1
fi
 
#echo ${CLI_CONF_PATH}/${CLIENT_CRT_NAME}.conf

inf_ip=$(get_ip_address $INTERFACE_NAME)

if [ $? -ne 0 ]; then
    ${APPPATH}/logger.sh "-1001: updt_localip_cliconf.sh get_ip_address Error occured while getting ip address for interface(${INTERFACE_NAME})"
    exit 1
fi

sed -i 's/local \([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/local '$inf_ip'/' ${CLI_CONF_PATH}/${CLIENT_CRT_NAME}.conf


