#!/bin/bash

source /root/sdwan/path.sh

rm -rf  ${ARCHIVEPATH}/*

rm -rf  ${INTFPATH}/lan/*
rm -rf  ${INTFPATH}/wan/*

rm -rf  ${LOGPATH}/*

rm -rf  ${PHYINTFPATH}/*

rm -rf  ${TRACKERPATH}/*

rm -rf  ${USRCONFPATH}/*

rm -rf  ${ROUTEDELPATH}/*

cat /dev/null > ${DBPATH}/chkintf
cat /dev/null > ${DBPATH}/intf_ifplug_status
cat /dev/null > ${INTFFILEPATH}
cat /dev/null > ${DBPATH}/intfs_status
cat /dev/null > ${DBPATH}/phyintf_type

rm -rf  ${PINGPATH}/*

${APPPATH}/phyintf_config.sh

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t filter -F
iptables -t filter -X
iptables -t mangle -F
iptables -t mangle -X

iptables-save > /etc/iptables/rules.v4

sudo ip route flush table main
sudo ip route flush cache

${APPPATH}/interface_writer.sh

systemctl restart networking

