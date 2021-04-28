#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

# -n CLIENT_CRT_NAME
# -S SERVER_CRT_NAME
# -l CLIENT_LOCAL_NETWORK
# -r TUN_NETWORK

while getopts n:s:l:r:t: option 
do 
    case "${option}" 
    in 
        n) CLIENT_CRT_NAME=${OPTARG};; 
        s) SERVER_CRT_NAME=${OPTARG};;  
        l) CLIENT_LOCAL_NETWORK=${OPTARG};;    
        r) TUN_NETWORK=${OPTARG};;    
        t) SERVER_LOCAL_NETWORK=${OPTARG};; 
    esac 
done 

if [ -z $CLIENT_CRT_NAME ]; then
    echo "provide -n CLIENT_CRT_NAME"
    exit 1
fi

if [ -z $SERVER_CRT_NAME ]; then
    echo "provide -s Server Certificate Name"
    exit 1
fi

if [ -z $CLIENT_LOCAL_NETWORK ]; then
    echo "provide -l Client lan network (0.0.0.0/24)"
    exit 1
fi

if [ -z $TUN_NETWORK ]; then
    echo "provide -r Tunnel Network (0.0.0.0/24)"
    exit 1
fi

CLIENT_PATH="/etc/openvpn/client/$SERVER_CRT_NAME/$CLIENT_CRT_NAME"
CCDPATH="/etc/openvpn/server/ccd/$SERVER_CRT_NAME"

#////////////////////////////////////////////////////////////////////////////////////////

if [ ! -d ${CCDPATH} ]; then
    mkdir -p ${CCDPATH}
fi

TUN_CHK_NETWORK=$(echo "$TUN_NETWORK" | cut -d. -f1).$(echo "$TUN_NETWORK" | cut -d. -f2).$(echo "$TUN_NETWORK" | cut -d. -f3)

if [ ! -f ${CCDPATH}/${CLIENT_CRT_NAME} ]; then

    i=0
    for ccdp in ${CCDPATH}/*; do

        ccdf=${ccdp##*/}

        if [ ! -z $(cat ${CCDPATH}/${ccdf} | grep 'ifconfig-push '$TUN_CHK_NETWORK | cut -d' ' -f2) ]; then
            cli_ip[i]=$(ip2ascii $(cat ${CCDPATH}/${ccdf} | grep 'ifconfig-push '$TUN_CHK_NETWORK | cut -d' ' -f2))
        fi
        i+=1 

    done

    max_ip=0
    for v in ${cli_ip[@]}; do
        #echo $v
        if (( $v > $max_ip )); then max_ip=$v; fi; 
    done

    if [ $max_ip == 0 ]; then
        NEXT_IP=$(($(ip2ascii $(get_hostmin $TUN_NETWORK)) + 100))
        NEXT_IP=$(ascii2ip $NEXT_IP)
    else 
        NEXT_IP=$(ascii2ip $(($max_ip + 1)))
    fi

    NETMASK=$(get_mask $TUN_NETWORK)

    echo 'ifconfig-push' $NEXT_IP $NETMASK > ${CCDPATH}/${CLIENT_CRT_NAME}

else
    
    if [ ! -z $(cat ${CCDPATH}/${CLIENT_CRT_NAME} | grep 'ifconfig-push '$TUN_CHK_NETWORK | cut -d' ' -f2) ]; then

        echo $(cat ${CCDPATH}/${CLIENT_CRT_NAME} | grep 'ifconfig-push') > ${CCDPATH}/${CLIENT_CRT_NAME}

    else

        i=0
        for ccdp in ${CCDPATH}/*; do

            ccdf=${ccdp##*/}

            if [ ! -z $(cat ${CCDPATH}/${ccdf} | grep 'ifconfig-push '$TUN_CHK_NETWORK | cut -d' ' -f2) ]; then
                cli_ip[i]=$(ip2ascii $(cat ${CCDPATH}/${ccdf} | grep 'ifconfig-push '$TUN_CHK_NETWORK | cut -d' ' -f2))
            fi
            i+=1 

        done

        max_ip=0
        for v in ${cli_ip[@]}; do
            #echo $v
            if (( $v > $max_ip )); then max_ip=$v; fi; 
        done

        if [ $max_ip == 0 ]; then
            NEXT_IP=$(($(ip2ascii $(get_hostmin $TUN_NETWORK)) + 100))
            NEXT_IP=$(ascii2ip $NEXT_IP)
        else 
            NEXT_IP=$(ascii2ip $(($max_ip + 1)))
        fi

        NETMASK=$(get_mask $TUN_NETWORK)

        echo -e 'ifconfig-push' $NEXT_IP $NETMASK > ${CCDPATH}/${CLIENT_CRT_NAME}

    fi

fi

for i in $(echo $CLIENT_LOCAL_NETWORK | sed "s/,/ /g"); do

    IP=$(get_address $i)
    MASK=$(get_mask $i)

    echo -e 'iroute' $IP $MASK >> ${CCDPATH}/${CLIENT_CRT_NAME}

done

for i in $(echo $SERVER_LOCAL_NETWORK | sed "s/,/ /g")
do
    ip=$(get_address $i)
    mask=$(get_mask $i)

    echo -e '#push "route '$ip' '$mask'"' >> ${CCDPATH}/${CLIENT_CRT_NAME}

done

HOST_MIN=$(get_hostmin $TUN_NETWORK)

echo -e '#CLIENT_LOCAL_NETWORK' $CLIENT_LOCAL_NETWORK >> ${CCDPATH}/${CLIENT_CRT_NAME}
echo -e '#SERVER_LOCAL_NETWORK' $SERVER_LOCAL_NETWORK >> ${CCDPATH}/${CLIENT_CRT_NAME}
echo -e '#TUN_NETWORK' $TUN_NETWORK >> ${CCDPATH}/${CLIENT_CRT_NAME}
echo -e '#TUN_HOST_MIN' $HOST_MIN >> ${CCDPATH}/${CLIENT_CRT_NAME}
echo -e '#SERVER_CRT_NAME' $SERVER_CRT_NAME >> ${CCDPATH}/${CLIENT_CRT_NAME}

#////////////////////////////////////////////////////////////////////////////////////////

cd /etc/openvpn/easy-rsa/

if [ ! -f "/etc/openvpn/easy-rsa/pki/dh.pem" ] 
then
    ./easyrsa gen-dh
fi

if [ ! -d "$CLIENT_PATH" ] 
then
    mkdir -p $CLIENT_PATH
fi


cp /etc/openvpn/easy-rsa/pki/dh.pem $CLIENT_PATH/

cp /etc/openvpn/server/ta.key $CLIENT_PATH/

#./easyrsa gen-req $CLIENT_CRT_NAME nopass

./easyrsa build-client-full $CLIENT_CRT_NAME nopass

mv /etc/openvpn/easy-rsa/pki/private/$CLIENT_CRT_NAME.key $CLIENT_PATH/

#./easyrsa sign-req client $CLIENT_CRT_NAME

mv /etc/openvpn/easy-rsa/pki/issued/$CLIENT_CRT_NAME.crt $CLIENT_PATH/
cp /etc/openvpn/easy-rsa/pki/ca.crt $CLIENT_PATH/
rm /etc/openvpn/easy-rsa/pki/reqs/$CLIENT_CRT_NAME.req


echo "SUCCESS"