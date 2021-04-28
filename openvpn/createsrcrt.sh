#!/bin/bash

# -n SERVER_CRT_NAME

while getopts n: option 
do 
    case "${option}" 
    in 
        n) SERVER_CRT_NAME=${OPTARG};;     
    esac 
done 

if [ -z $SERVER_CRT_NAME ]; then
    SERVER_CRT_NAME='server'
fi

cd /etc/openvpn/easy-rsa/

if [ ! -f "/etc/openvpn/easy-rsa/pki/dh.pem" ] 
then
    ./easyrsa gen-dh
fi

if [ ! -d "/etc/openvpn/server" ] 
then
    mkdir -p /etc/openvpn/server
fi

cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/server/

#sudo openvpn --genkey --secret /etc/openvpn/server/ta.key

./easyrsa build-server-full $SERVER_CRT_NAME nopass

#./easyrsa gen-req $SERVER_CRT_NAME nopass

mv /etc/openvpn/easy-rsa/pki/private/$SERVER_CRT_NAME.key /etc/openvpn/server/

#./easyrsa sign-req server $SERVER_CRT_NAME

mv /etc/openvpn/easy-rsa/pki/issued/$SERVER_CRT_NAME.crt /etc/openvpn/server/
cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/server/
rm /etc/openvpn/easy-rsa/pki/reqs/$SERVER_CRT_NAME.req

echo "success"