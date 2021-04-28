#!/bin/bash

APPPATH=$(dirname "$0")

# -l LOCAL_AS
# -r ROUTER_ID 
# -n NEIGHBOR_IP 
# -a REMOTE_AS
# -b NETWORKS


while getopts l:r:n:a:b: option 
do 
    case "${option}" 
    in 
        l) LOCAL_AS=${OPTARG};; 
        r) ROUTER_ID=${OPTARG};; 
        n) NEIGHBOR_IP=${OPTARG};; 
        a) REMOTE_AS=${OPTARG};; 
        b) NETWORKS=${OPTARG};;
    esac 
done 

arr_neighbor_ip=($(echo $NEIGHBOR_IP | tr "," "\n"))
arr_remote_as=($(echo $REMOTE_AS | tr "," "\n"))
arr_networks=($(echo $NETWORKS | tr "," "\n"))

if [ ${#arr_neighbor_ip[@]} != ${#arr_remote_as[@]} ]; then
    echo "provide -n NEIGHBOR_IP and -a REMOTE_AS same count"
    exit 1
fi

printf -v str '%s\n' 'frr version 6.0.2
frr defaults traditional
hostname sdnserver
log stdout
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
password zebra
enable password zebra
!
router bgp '$LOCAL_AS'
bgp router-id '$ROUTER_ID'
bgp log-neighbor-changes'

echo "$str"

for (( i=0; i<${#arr_neighbor_ip[@]}; i++ ))
do

    printf -v str '%s' 'neighbor '${arr_neighbor_ip[$i]}' remote-as '${arr_remote_as[$i]}
    echo "$str"

done

printf -v str '%s\n' '!
address-family ipv4 unicast'

echo "$str"

for (( i=0; i<${#arr_networks[@]}; i++ ))
do

    printf -v str '%s' 'network '${arr_networks[$i]}
    echo "$str"

done


echo "$str"

 #systemctl reload frr  ## Reloading the service