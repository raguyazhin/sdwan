#!/bin/bash

source /root/sdwan/path.sh

clinet=()

cat /dev/null > ${DBPATH}/tunnelips

for srvcrt in $(ls -d /etc/openvpn/client/*/)
do

    for clicrt in $(ls -d $srvcrt*/)
    do

        base_dir="$(basename $clicrt)"

        tun_ip=$(cat ${clicrt}/${base_dir} | grep 'ifconfig-push' | cut -d' ' -f2)
        cli_loc_network=$(cat ${clicrt}/${base_dir} | grep '#CLIENT_LOCAL_NETWORK' | cut -d' ' -f2)
        srv_crt_name=$(cat ${clicrt}/${base_dir} | grep '#SERVER_CRT_NAME' | cut -d' ' -f2)

        echo "$tun_ip|$cli_loc_network|$srv_crt_name" >> ${DBPATH}/tunnelips

        clinet+=($cli_loc_network)

    done

done

sorted_unique_ids=($(echo "${clinet[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

for value in "${sorted_unique_ids[@]}"
do

        #echo $value

        strip=${value//./ }
        strip=$(echo $strip | sed 's/\// /')

        hexip=$(printf '%02X' $strip) ; # ip address converted to hex and its used for file name.

        #echo $hexip

        ${APPPATH}/create_tun_tracker.sh -c ${value} -f ${hexip}

done

