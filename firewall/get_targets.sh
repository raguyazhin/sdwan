#!/bin/bash

# -t TABLE_NAME

while getopts t:c:l: option 
do 
    case "${option}" 
    in 
        t) TABLE_NAME=${OPTARG};;  
    esac 
done 


if [ -z $TABLE_NAME ]; then
    echo "provide -t IP Table Name ( Filter NAT mangle )"
    exit 1
fi

chain=$(iptables -L -t ${TABLE_NAME} -n | grep Chain | cut -d" " -f2)
chain=$chain',RETURN,ACCEPT,DNAT,SNAT,DROP,REJECT,LOG,ULOG,MARK,MASQUERADE,REDIRECT,'

echo $(echo $chain | tr ' ' ',')

