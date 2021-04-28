#!/bin/bash

source /root/sdwan/path.sh
source ${APPPATH}/functions.sh

# -k EASYRSA_KEY_SIZE
# -d EASYRSA_DIGEST 
# -e EASYRSA_CA_EXPIRE 
# -c EASYRSA_REQ_COUNTRY 
# -s EASYRSA_REQ_PROVINCE
# -y EASYRSA_REQ_CITY 
# -o EASYRSA_REQ_ORG 
# -u EASYRSA_REQ_OU 
# -m EASYRSA_REQ_EMAIL
# -n EASYRSA_REQ_CN

while getopts k:d:e:c:s:y:o:u:m:n: option 
do 
    case "${option}" 
    in 
        k) EASYRSA_KEY_SIZE=${OPTARG};; 
        d) EASYRSA_DIGEST=${OPTARG};; 
        e) EASYRSA_CA_EXPIRE=${OPTARG};; 
        c) EASYRSA_REQ_COUNTRY=${OPTARG};; 
        s) EASYRSA_REQ_PROVINCE=${OPTARG};; 
        y) EASYRSA_REQ_CITY=${OPTARG};; 
        o) EASYRSA_REQ_ORG=${OPTARG};; 
        u) EASYRSA_REQ_OU=${OPTARG};; 
        m) EASYRSA_REQ_EMAIL=${OPTARG};; 
        n) EASYRSA_REQ_CN=${OPTARG};;
    esac 
done 

if [ -z $EASYRSA_KEY_SIZE ]; then
    EASYRSA_KEY_SIZE='2048'
fi

if [ -z $EASYRSA_DIGEST ]; then
    EASYRSA_DIGEST='sha256'
fi

if [ -z $EASYRSA_CA_EXPIRE ]; then
    EASYRSA_CA_EXPIRE='3650'
fi

if [ -z $EASYRSA_REQ_COUNTRY ]; then
    EASYRSA_REQ_COUNTRY='IN'
fi

if [ -z $EASYRSA_REQ_PROVINCE ]; then
    EASYRSA_REQ_PROVINCE='TN'
fi

if [ -z $EASYRSA_REQ_CITY ]; then
    EASYRSA_REQ_CITY='CHENNAI'
fi

if [ -z $EASYRSA_REQ_ORG ]; then
    EASYRSA_REQ_ORG='EXAMPLE'
fi

if [ -z $EASYRSA_REQ_OU ]; then
    EASYRSA_REQ_OU='EXAMPLE'
fi

if [ -z $EASYRSA_REQ_EMAIL ]; then
    EASYRSA_REQ_EMAIL='EXAMPLE@gmail.com'
fi

if [ -z $EASYRSA_REQ_CN ]; then
    EASYRSA_REQ_CN='snmain'
fi

printf -v str '%s\n' 'if [ -z "$EASYRSA_CALLER" ]; then
	echo "You appear to be sourcing an Easy-RSA ''vars'' file." >&2
	echo "This is no longer necessary and is disallowed. See the section called" >&2
	echo "''How to use this file'' near the top comments for more details." >&2
	return 1
fi

#set_var EASYRSA	"${0%/*}"
#set_var EASYRSA_OPENSSL	"openssl"
#set_var EASYRSA_PKI		"$PWD/pki"
#set_var EASYRSA_DN	    "cn_only"
set_var EASYRSA_REQ_COUNTRY	"'$EASYRSA_REQ_COUNTRY'"
set_var EASYRSA_REQ_PROVINCE	"'$EASYRSA_REQ_PROVINCE'"
set_var EASYRSA_REQ_CITY	"'$EASYRSA_REQ_CITY'"
set_var EASYRSA_REQ_ORG	"'$EASYRSA_REQ_ORG'"
set_var EASYRSA_REQ_EMAIL	"'$EASYRSA_REQ_EMAIL'"
set_var EASYRSA_REQ_OU		"'$EASYRSA_REQ_OU'"
set_var EASYRSA_KEY_SIZE	'$EASYRSA_KEY_SIZE'
#set_var EASYRSA_ALGO		rsa
#set_var EASYRSA_CURVE		secp384r1
#set_var EASYRSA_CA_EXPIRE	'$EASYRSA_CA_EXPIRE'
#set_var EASYRSA_CERT_EXPIRE	1080
#set_var EASYRSA_CERT_RENEW	30
#set_var EASYRSA_CRL_DAYS	180
#set_var EASYRSA_NS_SUPPORT	"no"
#set_var EASYRSA_NS_COMMENT	"Easy-RSA Generated Certificate"
#set_var EASYRSA_TEMP_FILE	"$EASYRSA_PKI/extensions.temp"
#set_var EASYRSA_EXT_DIR	"$EASYRSA/x509-types"
#set_var EASYRSA_SSL_CONF	"$EASYRSA/openssl-easyrsa.cnf"
set_var EASYRSA_REQ_CN		"'$EASYRSA_REQ_CN'"
set_var EASYRSA_DIGEST		"'$EASYRSA_DIGEST'"
set_var EASYRSA_BATCH		"yes"'

echo "$str" > /etc/openvpn/easy-rsa/vars

cd /etc/openvpn/easy-rsa/

./easyrsa init-pki

./easyrsa --batch build-ca nopass

sudo openvpn --genkey --secret /etc/openvpn/server/ta.key

echo "SUCCESS"


