#!/bin/bash

source /root/sdwan/path.sh

file_count=$(ls -1q  ${USRCONFPATH}* | wc -l)

if [ $file_count != 0 ]; then
    for usrintf in ${USRCONFPATH}/*; do
        
        interface_name=${usrintf##*/}
        display_name=$(cat ${USRCONFPATH}/${interface_name} | grep 'displayname' | cut -d'=' -f2)
        interface_type=$(cat ${USRCONFPATH}/${interface_name} | grep 'interfacetype' | cut -d'=' -f2)
        ip_type=$(cat ${USRCONFPATH}/${interface_name} | grep 'iptype' | cut -d'=' -f2)
        ip_address=$(cat ${USRCONFPATH}/${interface_name} | grep 'ipaddress' | cut -d'=' -f2)
        subnet_mask=$(cat ${USRCONFPATH}/${interface_name} | grep 'subnetmask' | cut -d'=' -f2)
        gateway=$(cat ${USRCONFPATH}/${interface_name} | grep 'gateway' | cut -d'=' -f2)
        dns_1=$(cat ${USRCONFPATH}/${interface_name} | grep 'dns_1' | cut -d'=' -f2)
        dns_2=$(cat ${USRCONFPATH}/${interface_name} | grep 'dns_2' | cut -d'=' -f2)
        status=$(cat ${USRCONFPATH}/${interface_name} | grep 'status' | cut -d'=' -f2)
        enable=$(cat ${USRCONFPATH}/${interface_name} | grep 'enable' | cut -d'=' -f2)
        if_plug_status=$(cat ${DBPATH}/intf_ifplug_status | grep ${interface_name} | cut -d',' -f2)

        type='USB'

        usr_conf_data=$usr_conf_data$display_name,$interface_name,$interface_type,$ip_type,$ip_address,$subnet_mask,$gateway,$dns_1,$dns_2,$type,$status,${if_plug_status^^},$enable,

    done
fi
    
    usr_conf_data='Display Name,Interface Name,Interface Type,Protocol,IP Address,Subnet Mask,Gateway,DNS 1,DNS 2,Type,Status,Plug Status,Enable,'$usr_conf_data

    echo ${usr_conf_data::-1}
