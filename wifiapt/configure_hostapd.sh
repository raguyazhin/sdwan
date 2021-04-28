#!/bin/bash

source /root/sdwan/path.sh

INTERFACE=$(cat ${WIFI_APD_CONFIG_PATH} | grep 'INTERFACE' | cut -d'=' -f2)
SSID=$(cat ${WIFI_APD_CONFIG_PATH} | grep 'SSID' | cut -d'=' -f2)
PASSPHRASE=$(cat ${WIFI_APD_CONFIG_PATH} | grep 'PASSPHRASE' | cut -d'=' -f2)

if [ -z $INTERFACE ]; then
     echo "provide INTERFACE In ${WIFI_APD_CONFIG_PATH}"
     exit 1
fi

if [ -z $SSID ]; then
     echo "provide SSID In ${WIFI_APD_CONFIG_PATH}"
     exit 1
fi

if [ -z $PASSPHRASE ]; then
     echo "provide PASSPHRASE In ${WIFI_APD_CONFIG_PATH}"
     exit 1
fi

# echo $SSID
# echo $PASSPHRASE

str='interface='$INTERFACE'\n'
str=$str'driver=nl80211''\n'
str=$str'channel=11''\n'

str=$str'ssid='$SSID'\n'
str=$str'wpa=2''\n'
str=$str'wpa_passphrase='$PASSPHRASE'\n'
str=$str'wpa_key_mgmt=WPA-PSK''\n'
str=$str'wpa_pairwise=TKIP CCMP''\n'
str=$str'country_code=IN''\n'
str=$str'wpa_group_rekey=600''\n'
str=$str'wpa_gmk_rekey=86400''\n'
str=$str'hw_mode=g''\n'
str=$str'ieee80211n=1''\n'
str=$str'beacon_int=100''\n'
str=$str'dtim_period=2''\n'
str=$str'max_num_sta=255''\n'
str=$str'rts_threshold=-1''\n'
str=$str'fragm_threshold=-1''\n'
str=$str'logger_syslog=-1''\n'
str=$str'logger_syslog_level=2''\n'
str=$str'logger_stdout=-1''\n'
str=$str'logger_stdout_level=2''\n'
str=$str'\n\n'

echo -ne "$str" > /etc/hostapd/hostapd.conf

systemctl restart hostapd.service