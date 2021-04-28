#!/bin/bash

source /root/sdwan/path.sh

# - n) INTERFACE 
# - t) INTERFACE_TYPE

while getopts n:t: option 
do 
    case "${option}" 
    in 
        n) INTERFACE=${OPTARG};; 
        t) INTERFACE_TYPE=${OPTARG};;
    esac 
done 

if [ -z $INTERFACE ]; then
    echo "provide -n INTERFACE NAME"
    exit 1
fi

if [ -z $INTERFACE_TYPE ]; then
    echo "provide -t INTERFACE TYPE"
    exit 1
fi

INTFFILE=${INTFPATH}/${INTERFACE_TYPE,,}/${INTERFACE}

if [ -e ${INTFFILE} ]; then
    rm -f ${INTFFILE}
fi