#!/bin/bash

source /root/sdwan/path.sh

file_str=""

# -p PORT
# -t PROTOCOL 
# -m MODE 
# -d TUN_TYPE 
# -u TUN_NAME
# -c CIPHER
# -a AUTH 
# -r TUN_NETWORK 
# -l LOCAL_NETWORK
# -n SERVER_CRT_NAME

while getopts p:t:m:d:u:c:a:r:l:n: option 
do 
    case "${option}" 
    in 
        p) PORT=${OPTARG};; 
        t) PROTOCOL=${OPTARG};; 
        m) MODE=${OPTARG};; 
        d) TUN_TYPE=${OPTARG};; 
        u) TUN_NAME=${OPTARG};;
        c) CIPHER=${OPTARG};; 
        a) AUTH=${OPTARG};; 
        r) TUN_NETWORK=${OPTARG};; 
        l) LOCAL_NETWORK=${OPTARG};; 
        n) SERVER_CRT_NAME=${OPTARG};; 
    esac 
done 

if [ -z $PORT ]; then
    echo "provide -p Port Eg.1194"
    exit 1
fi

if [ -z $PROTOCOL ]; then
    PROTOCOL='udp'
fi

if [ -z $MODE ]; then
    echo "provide -m Mode"
    exit 1
fi

if [ -z $TUN_TYPE ]; then
    TUN_TYPE='tun'
fi

if [ -z $TUN_NAME ]; then
    TUN_NAME=$SERVER_CRT_NAME
fi

if [ -z $CIPHER ]; then
    CIPHER='AES-256-CBC'
fi

if [ -z $AUTH ]; then
    AUTH='SHA256'
fi

if [ -z $TUN_NETWORK ]; then
    echo "provide -r Tunnel Network (0.0.0.0/24)"
    exit 1
fi

if [ -z $LOCAL_NETWORK ]; then
    echo "provide -l Local Network (0.0.0.0/24,0.0.0.0/24)"
    exit 1
fi

if [ -z $SERVER_CRT_NAME ]; then
    SERVER_CRT_NAME='server'
fi

get_address () {
	ipcalc $1 | grep Address | awk '{$1=$1};1' | cut -d' ' -f2
}

get_netmask () {
	ipcalc $1 | grep Netmask | awk '{$1=$1};1' | cut -d' ' -f2
}

get_hostmin () {
	ipcalc $1 | grep HostMin | awk '{$1=$1};1' | cut -d' ' -f2
}

get_network () {
	ipcalc $1 $2 | grep Network | awk '{$1=$1};1' | cut -d' ' -f2
}

get_next_ip () {
	echo $(echo "$1" | cut -d. -f1).$(echo "$1" | cut -d. -f2).$(echo "$1" | cut -d. -f3).$(($(echo "$1" | cut -d. -f4) + 1))
}

get_last_ip () {
	echo $(echo "$1" | cut -d. -f1).$(echo "$1" | cut -d. -f2).$(echo "$1" | cut -d. -f3).$(($(echo "$1" | cut -d. -f4) + 99))
}

NETMASK=$(get_netmask $TUN_NETWORK)
HOSTMIN=$(get_hostmin $TUN_NETWORK)

POOL_FIRST_IP=$(get_next_ip $HOSTMIN)
POOL_LAST_IP=$(get_last_ip $HOSTMIN)

if [ ! -d "/var/log/myvpn/" ] 
then
    mkdir -p /var/log/myvpn/
fi

#////////////////////////////////////////////////////////////////////////////////////////////////////////////


file_str+="#change with your port\n"
file_str+="port $PORT\n\n"

file_str+="#You can use udp or tcp\n"
file_str+="proto $PROTOCOL\n\n"

file_str+="dev $TUN_NAME\n"
file_str+="dev-type $TUN_TYPE\n\n"

file_str+="#Certificate Configuration\n\n"

file_str+="#ca certificate\n"
file_str+="ca /etc/openvpn/server/ca.crt\n\n"

file_str+="#Server Certificate\n"
file_str+="cert /etc/openvpn/server/$SERVER_CRT_NAME.crt\n\n"

file_str+="#Server Key and keep this is secret\n"
file_str+="key /etc/openvpn/server/$SERVER_CRT_NAME.key\n\n"

file_str+="#See the size a dh key in /etc/openvpn/keys/\n"
file_str+="dh /etc/openvpn/server/dh.pem\n\n"

file_str+="tls-auth /etc/openvpn/server/ta.key 0\n\n"

file_str+="#tls-crypt /etc/openvpn/server/ta.key 0\n\n"

file_str+="cipher $CIPHER\n\n"

file_str+="auth $AUTH\n\n"

file_str+="# You can uncomment this out on\n"
file_str+="# non-Windows systems.\n"
file_str+="user nobody\n"
file_str+="group nogroup\n\n"

file_str+="#Internal IP will get when already connect\n"
file_str+="#server 10.1.1.0 255.255.255.0\n\n"

file_str+="mode server\n"
file_str+="tls-server\n"
file_str+="#dev tun\n"

file_str+='topology "subnet"\n'
file_str+='push "topology subnet"\n'
file_str+="ifconfig $HOSTMIN $NETMASK\n"
file_str+="push \"route-gateway $HOSTMIN\"\n"
file_str+="ifconfig-pool $POOL_FIRST_IP $POOL_LAST_IP $NETMASK\n\n"

file_str+="client-config-dir /etc/openvpn/server/ccd/$SERVER_CRT_NAME\n"

echo -e "${file_str}" > /etc/openvpn/$SERVER_CRT_NAME.conf

# #////////////////////////////////////////////////////////////////////////////////////////////////////////////

# file_str=""
# ccd_cnt=0

# CCDPATH="/etc/openvpn/server/ccd/$SERVER_CRT_NAME"

# if [ -z "$(ls -A $CCDPATH)" ]; then

# 	${APPPATH}/logger.sh "-1001: createsrvconf no ccd file found on ${CCDPATH}"

# else

#     for ccdp in ${CCDPATH}/*; do

#         ccdf=${ccdp##*/}

#         ccd_cnt=$(($ccd_cnt+1))

#         cli_gw=$(cat ${ccdp} | grep 'ifconfig-push' | cut -d' ' -f2)
#         cli_ip=$(cat ${ccdp} | grep 'iroute' | cut -d' ' -f2)
#         cli_mask=$(cat ${ccdp} | grep 'ifconfig-push' | cut -d' ' -f3)

#         NETWORK=$(get_network $cli_ip $cli_mask)

#         if [ $ccd_cnt -eq 1 ]; then
#             file_str+="ip route add $NETWORK scope global nexthop via $cli_gw dev $SERVER_CRT_NAME weight 1"
#         else
#             file_str+=" nexthop via $cli_gw dev $SERVER_CRT_NAME weight 1"
#         fi

#     #echo 'route' $cli_ip $cli_mask $cli_gw >> /etc/openvpn/$SERVER_CRT_NAME.conf

#     done

# fi

# echo -e $file_str

# #////////////////////////////////////////////////////////////////////////////////////////////////////////////

# file_str=""
# ccd_cnt=0

# for i in $(echo $LOCAL_NETWORK | sed "s/,/ /g")
# do

#     ccd_cnt=$(($ccd_cnt+1))

#     ip=$(get_address $i)
#     mask=$(get_netmask $i)

#     NETWORK=$(get_network $ip $mask)

#     if [ $ccd_cnt -eq 1 ]; then
#         file_str+="ip route add $NETWORK scope global nexthop via $ip dev $ccdf weight 1"
#     else
#         file_str+=" nexthop via $cli_gw dev $ccdf weight 1"
#     fi

#     echo 'push "route '$ip' '$mask'"' >> /etc/openvpn/$SERVER_CRT_NAME.conf

# done

# #////////////////////////////////////////////////////////////////////////////////////////////////////////////

echo '#this line will redirect all traffic through our OpenVPN
#push "redirect-gateway def1"


#Provide DNS servers to the client, you can use goolge DNS

push "dhcp-option DNS 172.20.10.52"
#push "dhcp-option DNS 8.8.4.4"

#Enable multiple client to connect with same key

duplicate-cn

keepalive 20 60
comp-lzo
persist-key
persist-tun
#nobind
#explicit-exit-notify 1

#daemon

log-append /var/log/myvpn/openvpn.log
status /var/log/openvpn/openvpn-status.log

#Log Level
verb 3' >> /etc/openvpn/$SERVER_CRT_NAME.conf

echo "success"