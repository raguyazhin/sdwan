#!/bin/bash

source /root/sdwan/path.sh

LOGFILE=$(date +"%d%m%Y").log

echo $(date +"%b %e %Y %T") $1  >> ${LOGPATH}/${LOGFILE} | uniq

