
CLIENT_PATH="/etc/openvpn/client"
APPPATH="/root/sdwan"

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
str_add_single_rule=""
str_del_single_rule=""

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
                                str_add_single_rule+="ip route add $i via $tun_min dev $clif~"
                                str_del_single_rule+="ip route del $i via $tun_min dev $clif~"
                            else
                                str_add_rule+=" nexthop via $tun_min dev $clif weight 1"
                                str_del_rule+=" nexthop via $tun_min dev $clif weight 1"
                            fi

                        fi
                      
                    fi

                done

            fi

        done

        str_add_rule+="~"
        str_del_rule+="~"
        cli_cnt=0

    done

fi

#////////////////////////////////////////////////////////////////////////////////////////////////////

#echo -e "current del script\n ${str_del_rule}"
#echo -e "current add script\n ${str_add_rule}"

run_del_script=$(cat ${CLIENT_PATH}/load_bal_del_script);

IFS='~' read -ra SCRIPT <<< "$run_del_script"
for i in "${SCRIPT[@]}"; do
    ${i}
    echo -e ${i}
done

echo "${str_del_rule}" > ${CLIENT_PATH}/load_bal_del_script
echo "${str_add_rule}" > ${CLIENT_PATH}/load_bal_add_script

run_add_script=$(cat ${CLIENT_PATH}/load_bal_add_script);

IFS='~' read -ra SCRIPT <<< "$run_add_script"
for i in "${SCRIPT[@]}"; do
    ${i}
    echo -e ${i}
done

# echo -e ${str_del_rule} > ${CLIENT_PATH}/load_bal_del_script.sh
# chmod 0755 ${CLIENT_PATH}/load_bal_del_script.sh

# echo -e ${str_add_rule} > ${CLIENT_PATH}/load_bal_add_script.sh
# chmod 0755 ${CLIENT_PATH}/load_bal_add_script.sh

#${CLIENT_PATH}/load_bal_add_script.sh
echo "____________"
who
echo "____________"

