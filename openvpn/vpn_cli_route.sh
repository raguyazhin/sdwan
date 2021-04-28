#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

# -s SERVER_CRT_NAME

while getopts s: option 
do 
    case "${option}" 
    in 
        s) SERVER_CRT_NAME=${OPTARG};; 
    esac 
done 

if [ -z $SERVER_CRT_NAME ]; then
    echo "provide -s Server Certificate Name"
    exit 1
fi

CLIENT_PATH="/etc/openvpn/client"

server_local_network=''

if [ -z "$(ls -A $CLIENT_PATH)" ]; then

 	${APPPATH}/logger.sh "-1001: no client file found on ${CLIENT_PATH}"

else

    for servfp in ${CLIENT_PATH}/*; do

        if [ -d $servfp ]; then

            for clifp in ${servfp}/*; do

                if [ -d $clifp ]; then

                    clif=${clifp##*/}

                    #echo $clifp;
                    #echo $clif;
                    server_local_network+=$(cat $clifp/$clif | grep 'SERVER_LOCAL_NETWORK' | cut -d' ' -f2)","

                fi

            done

        fi

    done

fi

#////////////////////////////////////////////////////////////////////////////////////////////////////

IFS=',' read -ra arr_srv_loc_network <<< $server_local_network

unique_srv_loc_network=($(echo "${arr_srv_loc_network[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

str_add_rule=""
str_del_rule=""
cli_cnt=0

if [ -z "$(ls -A $CLIENT_PATH)" ]; then

 	${APPPATH}/logger.sh "-1001: no client file found on ${CLIENT_PATH}"

else

    for i in "${unique_srv_loc_network[@]}"; do

        for servfp in ${CLIENT_PATH}/*; do

            if [ -d $servfp ]; then

                for clifp in ${servfp}/*; do

                    if [ -d $clifp ]; then

                        clif=${clifp##*/}

                        #echo $clifp;
                        #echo $clif;

                        down_cli_tun=$(grep -w "${clif}" ${CLIENT_PATH}/load_bal_route)

                        if [ -z $down_cli_tun ]; then

                            cli_cnt=$(($cli_cnt+1))

                            cli_local_network=$(cat $clifp/$clif | grep 'CLIENT_LOCAL_NETWORK' | cut -d' ' -f2)
                            server_local_network=$(cat $clifp/$clif | grep 'SERVER_LOCAL_NETWORK' | cut -d' ' -f2)
                            tun_min=$(cat $clifp/$clif | grep 'TUN_HOST_MIN' | cut -d' ' -f2)

                            if [ $cli_cnt -eq 1 ]; then
                                str_add_rule+="ip route add $i scope global nexthop via $tun_min dev $clif weight 1"
                                str_del_rule+="ip route del $i scope global nexthop via $tun_min dev $clif weight 1"
                            else
                                str_add_rule+=" nexthop via $tun_min dev $clif weight 1"
                                str_del_rule+=" nexthop via $tun_min dev $clif weight 1"
                            fi

                        fi
                      
                    fi

                done

            fi

        done

        str_add_rule+="\n"
        str_del_rule+="\n"
        cli_cnt=0

    done

fi

#////////////////////////////////////////////////////////////////////////////////////////////////////

${CLIENT_PATH}/load_bal_del_script.sh

echo -e ${str_del_rule} > ${CLIENT_PATH}/load_bal_del_script.sh
chmod 0755 ${CLIENT_PATH}/load_bal_del_script.sh

${str_add_rule}
#echo -e ${str_del_rule}



