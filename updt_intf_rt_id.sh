#!/bin/bash

source /root/sdwan/path.sh

if [ ${2^^} == "A" ]; then

    intf_name=$(cat ${INTF_RT_TABLE_ID_PATH} | grep ${1} | cut -d',' -f1)
    
    if [ -z $intf_name ]; then

        # rt_id=$(cat ${INTF_RT_TABLE_ID_PATH} | grep ${intf_name} | cut -d',' -f2)

        # sed -i "/${intf_name},[0-9]/d" ${INTF_RT_TABLE_ID_PATH}
        # sed -i "/${rt_id}/d" ${RT_TABLE_ID_PATH}

        rt_id=$( echo ${1} | cut -d',' -f2)

        intfs=$(cat ${INTF_RT_TABLE_ID_PATH})

        for intf in $intfs; do

            currintfs="${currintfs}${intf}\n"

        done

        currintfs="${1}\n"${currintfs::-2}

        echo -e "${currintfs}"  &> ${INTF_RT_TABLE_ID_PATH}
        echo $rt_id &>> ${RT_TABLE_ID_PATH}

    fi

elif [ ${2^^} == "D" ]; then

    intf_name=$( echo ${1} | cut -d',' -f1)

    if [ $intf_name ]; then
    
        rt_id=$(cat ${INTF_RT_TABLE_ID_PATH} | grep ${intf_name} | cut -d',' -f2)

        sed -i "/${intf_name},[0-9]/d" ${INTF_RT_TABLE_ID_PATH}
        sed -i "/${rt_id}/d" ${RT_TABLE_ID_PATH}

    fi

fi
