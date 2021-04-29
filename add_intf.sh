#!/bin/bash

source /root/sdwan/path.sh

chkintf=$(cat ${INTFFILEPATH} | grep ${1})

if [ -z ${chkintf} ]; then

	intfs=$(cat ${INTFFILEPATH})

	for intf in $intfs; do

		currintfs="${currintfs}${intf}\n"

	done

	currintfs="${1}\n"${currintfs::-2}

	echo -e "${currintfs}"  &> ${INTFFILEPATH}

fi