#!/bin/bash

# -s SERVER_CRT_NAME
# -l SERVER_LOCAL_NETWORK
# -r TUN_NETWORK 

while getopts s:l:r: option 
do 
    case "${option}" 
    in 
        s) SERVER_CRT_NAME=${OPTARG};; 
        l) SERVER_LOCAL_NETWORK=${OPTARG};; 
        r) TUN_NETWORK=${OPTARG};; 
    esac 
done 

if [ -z $SERVER_CRT_NAME ]; then
    echo "provide -s Server Certificate Name"
    exit 1
fi

if [ -z $SERVER_LOCAL_NETWORK ]; then
    echo "provide -l Server Local Network eg: 0.0.0.0/24,0.0.0.0/20"
    exit 1
fi

get_hostmin () {
	ipcalc $1 | grep HostMin | awk '{$1=$1};1' | cut -d' ' -f2
}

IFS=',' read -ra arr_srv_loc_network <<< $SERVER_LOCAL_NETWORK

unique_srv_loc_network=($(echo "${arr_srv_loc_network[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

file_str=""
str_rule=""
ccd_cnt=0

HOSTMIN=$(get_hostmin $TUN_NETWORK)

CCDPATH="/etc/openvpn/server/ccd/$SERVER_CRT_NAME"

if [ -z "$(ls -A $CCDPATH)" ]; then

 	${APPPATH}/logger.sh "-1001: createsrvconf no ccd file found on ${CCDPATH}"

else

    for i in "${unique_srv_loc_network[@]}"
    do

        for ccdp in ${CCDPATH}/*; do

            ccdf=${ccdp##*/}
            ccd_cnt=$(($ccd_cnt+1))

            cli_ip=$(cat ${ccdp} | grep 'iroute' | cut -d' ' -f2)
            cli_gw=$(cat ${ccdp} | grep 'ifconfig-push' | cut -d' ' -f2)

            str_rule+="ip rule add from $cli_gw table $(($ccd_cnt+100))\n";
            str_rule+="ip route add $TUN_NETWORK dev $ccdf scope link table $(($ccd_cnt+100))\n";
          
            if [ $ccd_cnt -eq 1 ]; then
                file_str+="ip route add $i scope global nexthop via $HOSTMIN dev $ccdf weight 1"
            else
                file_str+=" nexthop via $HOSTMIN dev $ccdf weight 1"
            fi

        done

        file_str+="\n"
        ccd_cnt=0

    done

fi

echo -e $str_rule
echo -e $file_str
