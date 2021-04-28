#!/bin/bash

source /root/sdwan/path.sh

while true
do

	${APPPATH}/tunnel_ping.sh

	parallel -j0 ::: ${TUNTRACKERPATH}/*sh
	
done