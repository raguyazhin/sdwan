#!/bin/bash

source /root/sdwan/path.sh

intfs=$(cat ${INTFFILEPATH})

for intf in $intfs; do

	if [ $intf != $1 ]; then
		currintfs="${currintfs}${intf}\n"
	fi

done

currintfs=${currintfs::-2}

echo -e "${currintfs}"  &> ${INTFFILEPATH}