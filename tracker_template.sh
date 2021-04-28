#!/bin/bash

enable=$(cat ${intfpath}/${intf} | grep 'enable' | cut -d'=' -f2)

if [ ${enable^^} == "YES" ]; then

    inf_gw=$(cat ${intfpath}/${intf} | grep 'gateway' | cut -d'=' -f2)

    if [[ -z $inf_gw || "$inf_gw" == "0.0.0.0"  ]]; then
        ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -s '2' -e ${enable}
    fi

    ipaddress=$(cat ${intfpath}/${intf} | grep 'ipaddress' | cut -d'=' -f2)
    inf_ip_type=$(cat ${intfpath}/${intf} | grep 'iptype' | cut -d'=' -f2)
    inf_type=$(cat ${intfpath}/${intf} | grep 'interfacetype' | cut -d'=' -f2)
    inf_dns_1=$(cat ${intfpath}/${intf} | grep 'dns_1' | cut -d'=' -f2)
    inf_dns_2=$(cat ${intfpath}/${intf} | grep 'dns_2' | cut -d'=' -f2)

    if [ -z $inf_type ]; then
        inf_type="WAN"
    fi

    if [ -z $inf_ip_type ]; then
        inf_ip_type="DHCP"
    fi

    if [ -z $inf_dns_1 ]; then
        inf_dns_1="8.8.8.8"
    fi

    if [ -z $inf_dns_2 ]; then
        inf_dns_2="8.8.8.8"
    fi

#--------------------------------------------------------------------------------------------------------

    if_plug_status=$(ifplugstatus ${intf} | awk {'print $2'})

    if [ "${if_plug_status^^}" != "LINK" ]; then
      
        if [ ${inf_ip_type} == "DHCP" ]; then
            ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -i '0.0.0.0' -m '0.0.0.0' -g '0.0.0.0' -s '0' -e ${enable}
        else
            ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -s '0' -e ${enable}
        fi

        if [ $updtintf -eq 1 ]; then
            ${APPPATH}/delete_intf.sh ${intf}
            ${APPPATH}/remove_tracker.sh -n ${intf} 
        fi

        ${APPPATH}/remove_intf.sh -n ${intf} -t ${inf_type}
        ${APPPATH}/logger.sh "-1001: $intf.sh ifplugstatus (${if_plug_status})"

        ifup ${intf} # once try to up the interface

        # if [ ${inf_type^^} == "WAN" ]; then
        #     ${APPPATH}/updt_intf_rt_id.sh "${intf}" "D"
        # fi

        if [ ${inf_type^^} == "WAN" ]; then
            ${APPPATH}/route_probability_writer.sh
        fi

        if [ -f "${ROUTEDELPATH}/${intf}.sh" ]; then
            ${ROUTEDELPATH}/${intf}.sh
        fi

        exit 1
 
    fi

#--------------------------------------------------------------------------------------------------------

    if [[ "$ipaddress" == "0.0.0.0" && "${inf_ip_type^^}" == "DHCP"  ]]; then

        if_plug_status=$(ifplugstatus ${intf} | awk {'print $2'})

        if [ "${if_plug_status^^}" == "LINK" ]; then
            ifdown --force ${intf} && ifup ${intf}
            sleep 30        
        fi

    elif [ "${inf_ip_type^^}" == "STATIC"  ]; then

        if [[ -z $inf_gw || "$inf_gw" == "0.0.0.0"  ]]; then

            if_plug_status=$(ifplugstatus ${intf} | awk {'print $2'})

            if [ "${if_plug_status^^}" == "LINK" ]; then
                ifdown --force ${intf} && ifup ${intf}
                sleep 5
            fi
            
        fi

    fi

#--------------------------------------------------------------------------------------------------------

    inf_ip=$(get_ip_address $intf)

    if [ $? -ne 0 ]; then
        ${APPPATH}/logger.sh "-1002: $intf.sh get_ip_address Error occured while getting ip address for interface(${intf})"
        exit 1
    fi
    
    inf_smask=$(get_netmask $intf)

    if [ $? -ne 0 ]; then
        ${APPPATH}/logger.sh "-1003: $intf.sh get_netmask Error occured while getting subnet mask for interface(${intf})"
        exit 1
    fi

    inf_gw=$(get_gateway $intf)

    if [ $? -ne 0 ]; then
        ${APPPATH}/logger.sh "-1004: $intf.sh get_gateway Error occured while getting gateway for interface(${intf})"
        exit 1
    fi

    inf_ntwrk=$(get_network $intf)

    if [ $? -ne 0 ]; then
        ${APPPATH}/logger.sh "-1005: $intf.sh get_network Error occured while getting network for interface(${intf})"
        exit 1
    fi

#--------------------------------------------------------------------------------------------------------

    if [ -z $inf_ip ]; then
        inf_ip='0.0.0.0'
    fi

    if [ -z $inf_smask ]; then
        inf_smask='0.0.0.0'
    fi

    if [ -z $inf_gw ]; then
        inf_gw=$(cat ${intfpath}/${intf} | grep 'gateway' | cut -d'=' -f2)
    fi

#--------------------------------------------------------------------------------------------------------


    if [[ $inf_gw && "$inf_gw" != "0.0.0.0" ]]; then

        ${APPPATH}/ping_intf.sh -i ${intf} -q ${inf_gw}

        pckt_loss=$(cat ${PINGPATH}/ping-${intf}.log | grep loss | awk '{print $6}' | sed 's/%//g')
        rtttime=$(cat ${PINGPATH}/ping-${intf}.log | grep rtt | cut -d '/' -f5)
        rtttime=${rtttime%.*}

        if [ -z $rtttime ]; then	

            if [ ${inf_ip_type} == "DHCP" ]; then
                ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -i '0.0.0.0' -m '0.0.0.0' -g '0.0.0.0' -s '0' -e ${enable}
            else
                ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -s '0' -e ${enable}
            fi

            if [ $updtintf -eq 1 ]; then
                ${APPPATH}/delete_intf.sh ${intf}
                ${APPPATH}/remove_tracker.sh -n ${intf} 
            fi

            ${APPPATH}/remove_intf.sh -n ${intf} -t ${inf_type}
            ${APPPATH}/logger.sh "-1006: interface(${intf}) - not pinging the gateway(${inf_gw})"

            # if [ ${inf_type^^} == "WAN" ]; then
            #     ${APPPATH}/updt_intf_rt_id.sh "${intf}" "D"
            # fi

            if [ ${inf_type^^} == "WAN" ]; then
                ${APPPATH}/route_probability_writer.sh
            fi

            if [ -f "${ROUTEDELPATH}/${intf}.sh" ]; then
                ${ROUTEDELPATH}/${intf}.sh
            fi

            exit 1

        else

            previous_ip=$(cat ${intfpath}/${intf} | grep 'ipaddress' | cut -d'=' -f2)
            previous_status=$(cat ${intfpath}/${intf} | grep 'status' | cut -d'=' -f2)

            ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -i ${inf_ip} -m ${inf_smask} -g ${inf_gw} -d ${inf_dns_1} -f ${inf_dns_2}  -s '1' -e ${enable}
            ${APPPATH}/updt_intf.sh -n ${intf} -t ${inf_type} -y ${inf_ip_type} -i ${inf_ip} -m ${inf_smask} -g ${inf_gw} -d ${inf_dns_1} -f ${inf_dns_2} -w ${inf_ntwrk}
            
            if [ ${inf_type^^} == "WAN" ]; then

                if [ -z "$(cat ${INTF_RT_TABLE_ID_PATH} | grep ${intf} | cut -d',' -f1)" ]; then

                    rt_id=$(${APPPATH}/get_rt_id.sh)
                    ${APPPATH}/updt_intf_rt_id.sh "${intf},${rt_id}" "A"

                fi
            fi

            if [ $updtintf -eq 1 ]; then
			    ${APPPATH}/add_intf.sh ${intf}
            fi

            if [ ${inf_type^^} == "WAN" ]; then

                if [[ ${previous_status} != '1' || ${previous_ip} != ${inf_ip} ]]; then
                    ${APPPATH}/route_writer.sh -n ${intf}
                    echo "route write ${intf}"
                fi

            fi
            
			${APPPATH}/logger.sh "-1007: $intf.sh interface detected (${intf})"

        fi

    else

        if [ ${inf_ip_type} == "DHCP" ]; then
            ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -i '0.0.0.0' -m '0.0.0.0' -g '0.0.0.0' -s '0' -e ${enable}
        else
            ${APPPATH}/updt_intf_status.sh -p ${intfpath} -n ${intf} -s '0' -e ${enable}
        fi

        if [ $updtintf -eq 1 ]; then
			${APPPATH}/delete_intf.sh ${intf}
            ${APPPATH}/remove_tracker.sh -n ${intf} 
        fi

        ${APPPATH}/remove_intf.sh -n ${intf} -t ${inf_type}
        ${APPPATH}/logger.sh "-1008: $intf.sh gateway not found for interface(${intf})"

        # if [ ${inf_type^^} == "WAN" ]; then
        #     ${APPPATH}/updt_intf_rt_id.sh "${intf}" "D"
        # fi

        if [ ${inf_type^^} == "WAN" ]; then
            ${APPPATH}/route_probability_writer.sh
        fi
        
        if [ -f "${ROUTEDELPATH}/${intf}.sh" ]; then
            ${ROUTEDELPATH}/${intf}.sh
        fi
        
        exit 1

    fi

fi

#--------------------------------------------------------------------------------------------------------