#!/bin/bash

APPPATH=$(dirname "$0")

# -l LOCAL_AS
# -r ROUTER_ID 
# -n NEIGHBOR_IP 
# -a VARIANCE
# -b NETWORKS


while getopts l:r:n:a:b: option 
do 
    case "${option}" 
    in 
        l) LOCAL_AS=${OPTARG};; 
        r) ROUTER_ID=${OPTARG};; 
        n) NEIGHBOR_IP=${OPTARG};; 
        a) VARIANCE=${OPTARG};; 
        b) NETWORKS=${OPTARG};;
    esac 
done 

arr_neighbor_ip=($(echo $NEIGHBOR_IP | tr "," "\n"))
#arr_remote_as=($(echo $REMOTE_AS | tr "," "\n"))
arr_networks=($(echo $NETWORKS | tr "," "\n"))

# if [ ${#arr_neighbor_ip[@]} != ${#arr_remote_as[@]} ]; then
#     echo "provide -n NEIGHBOR_IP and -a REMOTE_AS same count"
#     exit 1
# fi

str='router eigrp '$LOCAL_AS'\n'
str=$str'eigrp router-id '$ROUTER_ID'\n'

# printf -v str '%s\n' 'router eigrp '$LOCAL_AS'
# eigrp router-id '$ROUTER_ID''


for (( i=0; i<${#arr_neighbor_ip[@]}; i++ ))
do

   str=$str'neighbor '${arr_neighbor_ip[$i]}'\n'

done

for (( i=0; i<${#arr_networks[@]}; i++ ))
do

    str=$str'network '${arr_networks[$i]}'\n'

done

str=$str'variance '$VARIANCE'\n'

echo -ne "$str" >  ${APPPATH}/eigrp_config

 #systemctl reload frr  ## Reloading the service