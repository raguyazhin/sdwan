#!/bin/bash

# -p CLIENT_PACKAGE_PATH
# -n CLIENT_PACKAGE_NAME

while getopts p:n: option 
do 
    case "${option}" 
    in 
        p) CLIENT_PACKAGE_PATH=${OPTARG};; 
        n) CLIENT_PACKAGE_NAME=${OPTARG};;
    esac 
done 

if [ -z $CLIENT_PACKAGE_PATH ]; then
    echo "provide -p Client Package Path"
    exit 1
fi

if [ -z $CLIENT_PACKAGE_NAME ]; then
    echo "provide -n Client Package Name"
    exit 1
fi

unzip -o -d /tmp/ $CLIENT_PACKAGE_PATH/$CLIENT_PACKAGE_NAME.zip > /dev/null 2>&1

#cat /tmp/greams/greams

server_crt_name=$(cat /tmp/$CLIENT_PACKAGE_NAME/$CLIENT_PACKAGE_NAME | grep 'SERVER_CRT_NAME' | cut -d' ' -f2)

if [ -z $server_crt_name ]; then
    echo "Client Package File Not Valid"
    exit 1
fi

if [ ! -d "/etc/openvpn/client/$server_crt_name" ]; then
    mkdir -p /etc/openvpn/client/$server_crt_name
fi

cp /tmp/$CLIENT_PACKAGE_NAME/$CLIENT_PACKAGE_NAME.conf /etc/openvpn/

cp -r /tmp/$CLIENT_PACKAGE_NAME /etc/openvpn/client/$server_crt_name/

echo "$server_crt_name","$CLIENT_PACKAGE_NAME"
