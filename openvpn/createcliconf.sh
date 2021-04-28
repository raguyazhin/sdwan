#!/bin/bash

source /root/sdwan/path.sh

# -p PORT
# -t PROTOCOL 
# -d TUN_TYPE 
# -u TUN_NAME 
# -c CIPHER
# -a AUTH 
# -n CLIENT_CRT_NAME
# -s SERVER_CRT_NAME
# -e REM_PEER_IP

while getopts p:t:d:u:c:a:n:s:e: option 
do 
    case "${option}" 
    in 
        p) PORT=${OPTARG};; 
        t) PROTOCOL=${OPTARG};; 
        d) TUN_TYPE=${OPTARG};; 
        u) TUN_NAME=${OPTARG};; 
        c) CIPHER=${OPTARG};; 
        a) AUTH=${OPTARG};; 
        n) CLIENT_CRT_NAME=${OPTARG};; 
        s) SERVER_CRT_NAME=${OPTARG};;  
        e) REM_PEER_IP=${OPTARG};;
    esac 
done 


if [ -z $CLIENT_CRT_NAME ]; then
    echo "provide -n CLIENT_CRT_NAME"
    exit 1
fi

if [ -z $SERVER_CRT_NAME ]; then
    echo "provide -s SERVER_CRT_NAME"
    exit 1
fi

if [ -z $REM_PEER_IP ]; then
    echo "provide -e REM_PEER_IP"
    exit 1
fi

if [ -z $PORT ]; then
    PORT='1192'
fi

if [ -z $PROTOCOL ]; then
    PROTOCOL='udp'
fi

if [ -z $TUN_TYPE ]; then
    TUN_TYPE='tun'
fi

if [ -z $TUN_NAME ]; then
    TUN_NAME=$CLIENT_CRT_NAME
fi

if [ -z $CIPHER ]; then
    CIPHER='AES-256-CBC'
fi

if [ -z $AUTH ]; then
    AUTH='SHA256'
fi

if [ ! -d "/var/log/myvpn/" ] 
then
    mkdir -p /var/log/myvpn/
fi

if [ ! -d "/etc/openvpn/client/$SERVER_CRT_NAME/$CLIENT_CRT_NAME" ] 
then
    mkdir -p /etc/openvpn/client/$SERVER_CRT_NAME/$CLIENT_CRT_NAME
fi

CLIENT_PATH="/etc/openvpn/client/$SERVER_CRT_NAME/$CLIENT_CRT_NAME"
CCDPATH="/etc/openvpn/server/ccd/$SERVER_CRT_NAME"

#////////////////////////////////////////////////////////////////////////////////////////////////////////////

echo 'client

lport 0

#change with your interface ip
local 0.0.0.0

remote '$REM_PEER_IP'

#change with your port
port '$PORT'

#You can use udp or tcp
proto '$PROTOCOL'
#proto tcp-server
#proto tcp-client

# "dev tun" will create a routed IP tunnel.
#dev myvpn
#dev-type tun

dev '$TUN_NAME'
dev-type '$TUN_TYPE'

remote-cert-tls server
resolv-retry infinite

#Certificate Configuration

#ca certificate
ca '$CLIENT_PATH'/ca.crt

#Client Certificate
cert '$CLIENT_PATH'/'$CLIENT_CRT_NAME'.crt

#Client Key and keep this is secret
key '$CLIENT_PATH'/'$CLIENT_CRT_NAME'.key

#See the size a dh key in /etc/openvpn/keys/
dh '$CLIENT_PATH'/dh.pem

tls-auth '$CLIENT_PATH'/ta.key 1

#tls-crypt '$CLIENT_PATH'/ta.key 1

cipher '$CIPHER'

auth '$AUTH'

# You can uncomment this out on
# non-Windows systems.
user nobody
group nogroup

#this line will redirect all traffic through our OpenVPN
#push "redirect-gateway def1"

#Provide DNS servers to the client, you can use goolge DNS
#push "dhcp-option DNS 8.8.4.4"

#Enable multiple client to connect with same key

keepalive 20 60
comp-lzo
persist-key
persist-tun
key-direction 1
#nobind
#explicit-exit-notify 1

#daemon

log-append /var/log/myvpn/openvpn.log
status /var/log/openvpn/openvpn-status.log

#Log Level
verb 3 

script-security 2
up '$CLIENT_PATH'/'$CLIENT_CRT_NAME'_add_route.sh
down '$CLIENT_PATH'/'$CLIENT_CRT_NAME'_del_route.sh

route-noexec' > $CLIENT_PATH/$CLIENT_CRT_NAME.conf

cp $CCDPATH/$CLIENT_CRT_NAME $CLIENT_PATH

pushd /etc/openvpn/client/$SERVER_CRT_NAME/
zip -r $WEB_APP_PATH/vpn_client_bundle/$CLIENT_CRT_NAME.zip $CLIENT_CRT_NAME/
popd

echo "SUCCESS"

# cd /etc/openvpn/client/$CLIENT_CRT_NAME
# ls -l




