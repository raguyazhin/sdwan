#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

# -i INTERFACE_NAME
# -s START_RANGE 
# -e END_RANGE 
# -g GATEWAY
# -l LEASE

while getopts i:s:e:g:l: option 
do 
    case "${option}" 
    in 
        i) INTERFACE_NAME=${OPTARG};; 
        s) START_RANGE=${OPTARG};; 
        e) END_RANGE=${OPTARG};; 
        g) GATEWAY=${OPTARG};; 
        d) DNS=${OPTARG};; 
        l) LEASE=${OPTARG};;
    esac 
done 

str=''

if [[ -z $INTERFACE_NAME && -z $START_RANGE && -z $END_RANGE && -z $GATEWAY && -z $LEASE ]]; then

    str=$str'log-dhcp''\n'
    str=$str'dhcp-authoritative''\n'
    str=$str'log-facility=/var/log/dnsmasq.log''\n'

    echo -ne "$str" > /etc/dnsmasq.conf

    service dnsmasq restart  ## Restarting the service
    
    exit 1
fi

arr_interface_name=($(echo $INTERFACE_NAME | tr "," "\n"))
arr_start_range=($(echo $START_RANGE | tr "," "\n"))
arr_end_range=($(echo $END_RANGE | tr "," "\n"))
arr_gateway=($(echo $GATEWAY | tr "," "\n"))
arr_lease=($(echo $LEASE | tr "," "\n"))

if [[ ${#arr_interface_name[@]} != ${#arr_start_range[@]} || ${#arr_interface_name[@]} != ${#arr_end_range[@]} || ${#arr_interface_name[@]} != ${#arr_gateway[@]} || ${#arr_interface_name[@]} != ${#arr_lease[@]} ]]; then
    echo "supplied values does not match with no of interfaces"
    exit 1
fi

# echo $INTERFACE_NAME 
# echo $START_RANGE
# echo $END_RANGE
# echo $GATEWAY
# echo $LEASE


for (( i=0; i<${#arr_interface_name[@]}; i++ ))
do

    INTERFACE_NETWORK=$(get_network ${arr_interface_name[$i]})
    SUBNET_MASK=$(get_netmask ${arr_interface_name[$i]})

    START_IP=$(echo "$INTERFACE_NETWORK" | cut -d. -f1).$(echo "$INTERFACE_NETWORK" | cut -d. -f2).$(echo "$INTERFACE_NETWORK" | cut -d. -f3).${arr_start_range[$i]}
    END_IP=$(echo "$INTERFACE_NETWORK" | cut -d. -f1).$(echo "$INTERFACE_NETWORK" | cut -d. -f2).$(echo "$INTERFACE_NETWORK" | cut -d. -f3).${arr_end_range[$i]}

    str=$str'interface='${arr_interface_name[$i]}'\n'
    str=$str'dhcp-range=interface:'${arr_interface_name[$i]}','$START_IP','$END_IP','$SUBNET_MASK','${arr_lease[$i]}'\n'
    str=$str'dhcp-option='${arr_interface_name[$i]}',3,'${arr_gateway[$i]}'\n\n'

    if [ $DNS ]; then
        str=$str'dhcp-option='${arr_interface_name[$i]}',6,'${DNS}'\n\n'
    fi

done

str=$str'bind-interfaces''\n'
str=$str'bogus-priv''\n'
str=$str'localise-queries''\n'
str=$str'log-queries''\n'
str=$str'log-dhcp''\n'
str=$str'dhcp-authoritative''\n'

str=$str'log-facility=/var/log/dnsmasq.log''\n'

echo -ne "$str" > /etc/dnsmasq.conf

service dnsmasq restart  ## Restarting the service

##### example dhcp-relay=10.0.1.254,172.16.5.251

##### cat /var/lib/misc/dnsmasq.leases  == view dhcp lease

