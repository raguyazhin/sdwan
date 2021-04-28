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

echo $NEIGHBOR_IP
echo ${#arr_neighbor_ip[@]}
echo ${#arr_remote_as[@]}

if [ ${#arr_neighbor_ip[@]} != ${#arr_remote_as[@]} ]; then
    echo "provide -n NEIGHBOR_IP and -a REMOTE_AS same count"
    exit 1
fi

str='router bgp '$LOCAL_AS'\n'
str=$str'bgp router-id '$ROUTER_ID'\n'
str=$str'bgp log-neighbor-changes''\n'

for (( i=0; i<${#arr_neighbor_ip[@]}; i++ ))
do

   str=$str'neighbor '${arr_neighbor_ip[$i]}' remote-as '${arr_remote_as[$i]}'\n'

done

str=$str'!''\n'
str=$str'address-family ipv4 unicast''\n'

for (( i=0; i<${#arr_networks[@]}; i++ ))
do

   str=$str'network '${arr_networks[$i]}'\n'

done

str=$str'exit-address-family''\n'

echo -ne "$str" > ${APPPATH}/bgp_config

echo "$str"


 #systemctl reload frr  ## Reloading the service