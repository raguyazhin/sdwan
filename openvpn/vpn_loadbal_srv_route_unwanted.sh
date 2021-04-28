#!/bin/bash

# -s SERVER_CRT_NAME
# -c CLI_LOCAL_NETWORK


while getopts s:c: option 
do 
    case "${option}" 
    in 
        s) SERVER_CRT_NAME=${OPTARG};; 
        c) CLI_LOCAL_NETWORK=${OPTARG};; 
    esac 
done 

if [ -z $SERVER_CRT_NAME ]; then
    echo "provide -s Server Certificate Name"
    exit 1
fi

if [ -z $CLI_LOCAL_NETWORK ]; then
    echo "provide -c Client Local Network eg: 0.0.0.0/24,0.0.0.0/20"
    exit 1
fi

IFS=',' read -ra arr_cli_loc_network <<< $CLI_LOCAL_NETWORK

unique_cli_loc_network=($(echo "${arr_cli_loc_network[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

file_str=""
ccd_cnt=0

CCDPATH="/etc/openvpn/server/ccd/$SERVER_CRT_NAME"

if [ -z "$(ls -A $CCDPATH)" ]; then

 	${APPPATH}/logger.sh "-1001: createsrvconf no ccd file found on ${CCDPATH}"

else

    for i in "${unique_cli_loc_network[@]}"
    do

        for ccdp in ${CCDPATH}/*; do

            ccdf=${ccdp##*/}

            ccd_cnt=$(($ccd_cnt+1))
          
            cli_ip=$(cat ${ccdp} | grep 'iroute' | cut -d' ' -f2)
            cli_gw=$(cat ${ccdp} | grep 'ifconfig-push' | cut -d' ' -f2)

            if [ $ccd_cnt -eq 1 ]; then
                file_str+="ip route add $i scope global nexthop via $cli_gw dev $SERVER_CRT_NAME weight 1"
            else
                file_str+=" nexthop via $cli_gw dev $SERVER_CRT_NAME weight 1"
            fi

        done

        file_str+="\n"
        ccd_cnt=0

    done

fi

echo -e $file_str
