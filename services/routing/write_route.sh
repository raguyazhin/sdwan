#!/bin/bash

APPPATH=$(dirname "$0")

# -b BGP
# -e EIGRP 

while getopts b:e: option 
do 
    case "${option}" 
    in 
        b) BGP=${OPTARG};; 
        e) EIGRP=${OPTARG};; 
    esac 
done 

str='frr version 6.0.2''\n'
str=$str'frr defaults traditional''\n'
str=$str'hostname sdnserver''\n'
str=$str'log stdout''\n'
str=$str'log syslog informational''\n'
str=$str'no ipv6 forwarding''\n'
str=$str'service integrated-vtysh-config''\n'
str=$str'!''\n'
str=$str'password zebra''\n'
str=$str'enable password zebra''\n'
str=$str'!''\n\n'

if [ ${BGP} == 1 ];then
    str=$str$(cat ${APPPATH}/bgp_config)
fi

str=$str'\n''!''\n\n'

if [ ${EIGRP} == 1 ];then
    str=$str$(cat ${APPPATH}/eigrp_config)
fi  

str=$str'\n''!''\n\n'

str=$str'!''\n'
str=$str'line vty''\n'
str=$str'!''\n'

echo -ne "$str" > ${APPPATH}/route_config
