#!/bin/bash

source /root/sdwan/path.sh

VAR=0

while [ "$VAR" -eq 0 ]; 
do

	nxt_rt_id=$(shuf -i 2-230 -n 1)

	if grep -Fxq $nxt_rt_id ${RT_TABLE_ID_PATH}
	then
    	VAR=0
	else
    	echo $nxt_rt_id
		VAR=1
	fi

done

