#!/bin/bash

source /root/sdwan/path.sh

# -i INTERFACE
# -s SIZE 
# -c COUNT 
# -w TIMEOUT 
# -q GATEWAY

while getopts i:s:c:w:q: option 
do 
    case "${option}" 
    in 
        i) INTERFACE=${OPTARG};; 
        s) SIZE=${OPTARG};; 
        c) COUNT=${OPTARG};; 
        w) TIMEOUT=${OPTARG};; 
        q) GATEWAY=${OPTARG};;        
    esac 
done 

if [ -z $INTERFACE ]; then
    echo "provide -i INTERFACE NAME"
    exit 1
fi

if [ -z $SIZE ]; then
    SIZE=56
fi

if [ -z $COUNT ]; then
    COUNT=3
fi

if [ -z $TIMEOUT ]; then
    TIMEOUT=3
fi

if [ -z $GATEWAY ]; then
    GATEWAY="8.8.8.8"
fi

ping -I ${INTERFACE} -s ${SIZE} -c ${COUNT} -W ${TIMEOUT} -q ${GATEWAY} &> ${PINGPATH}/ping-${INTERFACE}.log