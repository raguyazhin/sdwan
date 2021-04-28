#!/bin/bash

# -t TABLE_NAME
# -c CHAIN_NAME
# -l LINE_NUMBER

while getopts t:c:l: option 
do 
    case "${option}" 
    in 
        t) TABLE_NAME=${OPTARG};; 
        c) CHAIN_NAME=${OPTARG};;
        l) LINE_NUMBER=${OPTARG};;    
    esac 
done 


if [ -z $TABLE_NAME ]; then
    echo "provide -t IP Table Name ( Filter NAT mangle )"
    exit 1
fi

if [ -z $CHAIN_NAME ]; then
    echo "provide -c IP Table Chain ( INPUT OUTPUT FORWARD )"
    exit 1
fi

if [ -z $LINE_NUMBER ]; then
    echo "provide -l Line Number"
    exit 1
fi

iptables -t ${TABLE_NAME} -D ${CHAIN_NAME} ${LINE_NUMBER}