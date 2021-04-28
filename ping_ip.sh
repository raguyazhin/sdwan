#!/bin/bash

# -i IPADDRESS

while getopts i: option 
do 
    case "${option}" 
    in 
        i) IPADDRESS=${OPTARG};;        
    esac 
done 

ping $IPADDRESS -c2 &> /dev/null ; 

if [ $? -eq 0 ]; then
    result='1'
else
    result='0'
fi

echo ${result}