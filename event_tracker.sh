#!/bin/bash

source /root/sdwan/path.sh

while true
do

	#${APPPATH}/intf_ifplug_status.sh

	${APPPATH}/new_track.sh
	
	parallel -j0 ::: ${TRACKERPATH}/*sh

	#${APPPATH}/run_route_writer.sh

	ls /sys/class/net/
	
done