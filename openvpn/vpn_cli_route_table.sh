#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

# -s SERVER_CRT_NAME
# -c CLIENT_CRT_NAME
# -t TABLE_ID

while getopts s:c:t: option 
do 
    case "${option}" 
    in 
        s) SERVER_CRT_NAME=${OPTARG};; 
        c) CLIENT_CRT_NAME=${OPTARG};; 
        t) TABLE_ID=${OPTARG};; 
    esac 
done 

if [ -z $SERVER_CRT_NAME ]; then
    echo "provide -s Server Certificate Name"
    exit 1
fi

if [ -z $CLIENT_CRT_NAME ]; then
    echo "provide -c Client Certificate Name"
    exit 1
fi

if [ -z $TABLE_ID ]; then
    echo "provide -t Table ID"
    exit 1
fi

CLIENT_PATH="/etc/openvpn/client"

cli_gw=$(cat ${CLIENT_PATH}/${SERVER_CRT_NAME}/${CLIENT_CRT_NAME}/${CLIENT_CRT_NAME} | grep 'ifconfig-push' | cut -d' ' -f2)
cli_snm=$(cat ${CLIENT_PATH}/${SERVER_CRT_NAME}/${CLIENT_CRT_NAME}/${CLIENT_CRT_NAME} | grep 'ifconfig-push' | cut -d' ' -f3)

tun_netwrk=$(get_network4lan $cli_gw $cli_snm)
tun_host_min=$(get_hostmin $tun_netwrk)

str_tab_rule="#!/bin/bash\n\n"

#str_tab_rule+="ip route add $tun_netwrk dev $CLIENT_CRT_NAME src $cli_gw table $TABLE_ID\n"
#str_tab_rule+="ip route add default via $tun_host_min table $TABLE_ID\n\n"

str_tab_rule+="if [ -e $CLIENT_PATH/load_bal_route ]; then\n"
str_tab_rule+='sed -i "/'$CLIENT_CRT_NAME'/d" '$CLIENT_PATH/load_bal_route'\n'
str_tab_rule+="fi\n\n"

str_tab_rule+="${CLIENT_PATH}/vpn_cli_route_template.sh\n"

echo -e $str_tab_rule > "$CLIENT_PATH/${SERVER_CRT_NAME}/${CLIENT_CRT_NAME}/${CLIENT_CRT_NAME}"_add_route.sh
chmod 0755 "$CLIENT_PATH/${SERVER_CRT_NAME}/${CLIENT_CRT_NAME}/${CLIENT_CRT_NAME}"_add_route.sh

str_tab_rule="#!/bin/bash\n\n"

# str_tab_rule+="ip route flush table $TABLE_ID\n"
# str_tab_rule+="ip route del $tun_netwrk dev $CLIENT_CRT_NAME src $cli_gw table $TABLE_ID\n"
# str_tab_rule+="ip route del default via $tun_host_min table $TABLE_ID\n\n"

str_tab_rule+='if [ -z $(grep "'${CLIENT_CRT_NAME}'" '$CLIENT_PATH/'load_bal_route) ]; then\n'
str_tab_rule+='echo "'${CLIENT_CRT_NAME}'" >> '$CLIENT_PATH'/load_bal_route\n'
str_tab_rule+="fi\n\n"

str_tab_rule+="${CLIENT_PATH}/vpn_cli_route_template.sh\n"

echo -e $str_tab_rule > "$CLIENT_PATH/${SERVER_CRT_NAME}/${CLIENT_CRT_NAME}/${CLIENT_CRT_NAME}"_del_route.sh
chmod 0755 "$CLIENT_PATH/${SERVER_CRT_NAME}/${CLIENT_CRT_NAME}/${CLIENT_CRT_NAME}"_del_route.sh

if [ ! -f "${CLIENT_PATH}/load_bal_route" ] then
    cat /dev/null > ${CLIENT_PATH}/load_bal_route
    chmod 0777 "${CLIENT_PATH}/load_bal_route"
fi

if [ ! -f "${CLIENT_PATH}/load_bal_add_script" ] then
    cat /dev/null > ${CLIENT_PATH}/load_bal_add_script
    chmod 0777 "${CLIENT_PATH}/load_bal_add_script"
fi

if [ ! -f "${CLIENT_PATH}/load_bal_del_script" ] then
    cat /dev/null > ${CLIENT_PATH}/load_bal_del_script
    chmod 0777 "${CLIENT_PATH}/load_bal_del_script"
fi

if [ ! -f "${CLIENT_PATH}/vpn_cli_route_template.sh" ] then
    cp ${APPPATH}/openvpn/vpn_cli_route_template.sh ${CLIENT_PATH}
    chmod 0777 "${CLIENT_PATH}/vpn_cli_route_template.sh"
fi

echo -e "$str_tab_rule"
