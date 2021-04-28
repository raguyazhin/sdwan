#!/bin/bash

source /root/sdwan/path.sh

while getopts i:t: option 
do 
    case "${option}" 
    in 
        i) INTERFACE_NAME=${OPTARG};;  
        t) INTERFACE_TYPE=${OPTARG};;     
    esac 
done 

if [ -z $INTERFACE_NAME ]; then
     echo "provide -i INTERFACE_NAME"
     exit 1
fi

if [ -z $INTERFACE_TYPE ]; then
     echo "provide -t INTERFACE_TYPE"
     exit 1
fi

if [ ! -d ${APPPATH}"/archive/usrconf" ] 
then
    mkdir -p ${ARCHIVEPATH}
fi

if [ -f ${USRCONFPATH}/${INTERFACE_NAME} ] 
then

    mv  ${USRCONFPATH}/${INTERFACE_NAME} ${ARCHIVEPATH}

    ${APPPATH}/delete_intf.sh ${INTERFACE_NAME}
    ${APPPATH}/remove_tracker.sh -n ${INTERFACE_NAME}
    ${APPPATH}/remove_intf.sh -n ${INTERFACE_NAME} -t ${INTERFACE_TYPE}
    ${APPPATH}/logger.sh "-1001: delete_usrconf.sh interface(${INTERFACE_NAME}) deleted from application"

fi
 




