#!/bin/bash

APPPATH="/root/sdwan"
WEB_APP_PATH="/var/www/html/wonderlantest/"

DBPATH=${APPPATH}/db

USRCONFPATH=${DBPATH}/usrconf
PHYINTFPATH=${DBPATH}/phyintf
INTFPATH=${DBPATH}/intf
INTFFILEPATH=${DBPATH}/intfs
TRACKERPATH=${DBPATH}/tracker

TUNTRACKERPATH=${DBPATH}/tuntracker
TUNROUTEPATH=${DBPATH}/tunroute

ROUTEDELPATH=${DBPATH}/delroute

PINGPATH=${DBPATH}/pinglog
LOGPATH=${DBPATH}/log
ARCHIVEPATH=${DBPATH}/archive/usrconf

RT_TABLE_ID_PATH=${DBPATH}/rtid
INTF_RT_TABLE_ID_PATH=${DBPATH}/intf_rt_id

WIFI_APD_CONFIG_PATH=${DBPATH}/hostapd_conf


CLI_CONF_PATH="/etc/openvpn"
