source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

# cli_loc_network="172.27.1.0/24"
# file_name="AC1B010018"

route_add_file="${TUNROUTEPATH}/${file_name}_AR"
route_del_file="${TUNROUTEPATH}/${file_name}_DR"

tun_ips=$(cat ${DBPATH}/tunnelips | grep $cli_loc_network | cut -d'|' -f1)

route_add=""
route_del=""
pre_add_route=""

for ip in $tun_ips
do

    echo $ip
    ping_result=$(${APPPATH}/ping_ip.sh -i $ip)

    if [ $ping_result = "1" ]; then
        srv_crt_name=$(cat ${DBPATH}/tunnelips | grep $ip | cut -d'|' -f3)
        route_add+="nexthop via $ip dev $srv_crt_name weight 1 "
        route_del+="nexthop via $ip dev $srv_crt_name weight 1 "
    fi

done

if [ "$route_add" ]; then
    route_add="ip route add $cli_loc_network scope global $route_add"
    route_del="ip route del $cli_loc_network scope global $route_del"
fi

if [ -f "${route_add_file}" ]; then
    pre_add_route=$(cat ${route_add_file} | grep $cli_loc_network | cut -d'|' -f2)
fi

if [ "$pre_add_route" !=  "$route_add" ]; then

    if [ -f "${route_del_file}" ]; then
        pre_del_route=$(cat ${route_del_file} | grep $cli_loc_network | cut -d'|' -f2)
    fi
    
    echo $pre_del_route
    ${pre_del_route}

    echo $route_add
    ${route_add}

fi

route_add="$cli_loc_network|$route_add\n"
route_del="$cli_loc_network|$route_del\n"

echo -e "$route_add" > $route_add_file
echo -e "$route_del" > $route_del_file