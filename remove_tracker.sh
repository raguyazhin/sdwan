#!/bin/bash

source /root/sdwan/path.sh

# - n) INTERFACE 

while getopts n: option 
do 
    case "${option}" 
    in 
        n) INTERFACE=${OPTARG};; 
    esac 
done 

if [ -z $INTERFACE ]; then
    echo "provide -n INTERFACE NAME"
    exit 1
fi

INTFFILE=${TRACKERPATH}/${INTERFACE}.sh

if [ -e ${INTFFILE} ]; then
    rm -f ${INTFFILE}
fi
