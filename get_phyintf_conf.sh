#!/bin/bash

source /root/sdwan/path.sh

if [ -z "$(ls -A $PHYINTFPATH)" ]; then

    ${APPPATH}/phyintf_config.sh

else

    for phyintf in ${PHYINTFPATH}/*; do
        
        interface_name=${phyintf##*/}
        display_name=$(cat ${PHYINTFPATH}/${interface_name} | grep 'displayname' | cut -d'=' -f2)
        interface_type=$(cat ${PHYINTFPATH}/${interface_name} | grep 'interfacetype' | cut -d'=' -f2)
        ip_type=$(cat ${PHYINTFPATH}/${interface_name} | grep 'iptype' | cut -d'=' -f2)
        ip_address=$(cat ${PHYINTFPATH}/${interface_name} | grep 'ipaddress' | cut -d'=' -f2)
        subnet_mask=$(cat ${PHYINTFPATH}/${interface_name} | grep 'subnetmask' | cut -d'=' -f2)
        gate_way=$(cat ${PHYINTFPATH}/${interface_name} | grep 'gateway' | cut -d'=' -f2)
        dns_1=$(cat ${PHYINTFPATH}/${interface_name} | grep 'dns_1' | cut -d'=' -f2)
        dns_2=$(cat ${PHYINTFPATH}/${interface_name} | grep 'dns_2' | cut -d'=' -f2)
        status=$(cat ${PHYINTFPATH}/${interface_name} | grep 'status' | cut -d'=' -f2)
        enable=$(cat ${PHYINTFPATH}/${interface_name} | grep 'enable' | cut -d'=' -f2)
        type=$(cat ${DBPATH}/phyintf_type | grep ${interface_name} | cut -d',' -f2)
        if_plug_status=$(cat ${DBPATH}/intf_ifplug_status | grep ${interface_name} | cut -d',' -f2)

        phy_intf_data=$phy_intf_data$display_name,$interface_name,$interface_type,$ip_type,$ip_address,$subnet_mask,$gate_way,$dns_1,$dns_2,$type,$status,${if_plug_status^^},$enable,

    done

fi
    
phy_intf_data='Display Name,Interface Name,Interface Type,Protocol,IP Address,Subnet Mask,Gateway,DNS 1,DNS 2,Type,Status,Plug Status,Enable,'$phy_intf_data

echo ${phy_intf_data::-1}